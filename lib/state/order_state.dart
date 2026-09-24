import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/order.dart';
import '../services/connectivity_service.dart';
import '../services/order_api.dart';
import '../services/storage.dart';
import '../utils/errors.dart';

/// Order history + offline order queue.
///
/// 1. A new order is saved on the phone first, as "pending".
/// 2. Then it is sent to the server. If that works it becomes "confirmed".
/// 3. If it fails (offline, timeout, server error) it stays pending and is
///    sent again when the internet comes back, when the app opens or
///    resumes, when the user pulls to refresh, and every 30 seconds.
class OrderState extends ChangeNotifier {
  OrderState(this._storage, this._api, this._connectivity) {
    _connectivity.addListener(_onConnectivityChanged);
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (_) => syncPending());
  }

  final Storage _storage;
  final OrderApi _api;
  final ConnectivityService _connectivity;
  late final Timer _retryTimer;

  String? _userId;
  List<Order> _orders = [];
  bool _syncing = false;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get syncing => _syncing;
  int get pendingCount =>
      _orders.where((o) => o.status == OrderStatus.pending).length;

  /// Loads the saved orders of the logged-in user.
  void setUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _orders = userId == null
        ? []
        : _storage.readList(_key(userId)).map(Order.fromJson).toList();
    if (userId != null) Future.microtask(syncPending);
  }

  /// [orderId] is created once per checkout. Placing the same id twice
  /// (double tap, retry) returns the existing order instead of a new one.
  Future<Order> placeOrder({
    required String orderId,
    required List<CartItem> items,
    required String name,
    required String phone,
    required String address,
    required String pincode,
  }) async {
    final userId = _userId;
    if (userId == null) throw const AppException('Please log in again.');
    if (items.isEmpty) throw const AppException('Your cart is empty.');

    final existing = _find(orderId);
    if (existing != null) return existing;

    final order = Order(
      id: orderId,
      userId: userId,
      // Copy the items so later cart changes don't affect this order.
      items: [
        for (final i in items) CartItem(product: i.product, quantity: i.quantity)
      ],
      name: name,
      phone: phone,
      address: address,
      pincode: pincode,
      createdAt: DateTime.now(),
    );
    _orders.insert(0, order);
    await _save();
    notifyListeners();

    await syncPending();
    return order;
  }

  /// Sends every pending order to the server, oldest first.
  Future<void> syncPending() async {
    final userId = _userId;
    if (_syncing || userId == null || !_connectivity.isOnline) return;
    final pending =
        _orders.where((o) => o.status == OrderStatus.pending).toList().reversed;
    if (pending.isEmpty) return;

    _syncing = true;
    notifyListeners();
    for (final order in pending) {
      if (!_connectivity.isOnline) break;
      try {
        await _api.submit(order);
        order.status = OrderStatus.confirmed;
        order.error = null;
      } catch (e) {
        order.error = friendlyError(e);
      }
      if (_userId != userId) break; // User logged out meanwhile.
      await _save();
      notifyListeners();
    }
    _syncing = false;
    notifyListeners();
  }

  void _onConnectivityChanged() {
    if (_connectivity.isOnline) syncPending();
  }

  Order? _find(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  String _key(String userId) => 'orders_$userId';

  Future<void> _save() async {
    final userId = _userId;
    if (userId == null) return;
    await _storage.writeList(_key(userId), _orders.map((o) => o.toJson()).toList());
  }

  @override
  void dispose() {
    _retryTimer.cancel();
    _connectivity.removeListener(_onConnectivityChanged);
    super.dispose();
  }
}
