import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/storage.dart';

/// The cart is saved on every change, so it is still there after
/// closing and reopening the app. Each user has their own cart.
class CartState extends ChangeNotifier {
  CartState(this._storage);

  final Storage _storage;
  String? _userId;
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;
  int get count => _items.fold(0, (sum, item) => sum + item.quantity);
  int get total => _items.fold(0, (sum, item) => sum + item.total);

  /// Loads the saved cart of the logged-in user.
  void setUser(String? userId) {
    if (userId == _userId) return;
    _userId = userId;
    _items.clear();
    if (userId != null) {
      _items.addAll(_storage.readList(_key(userId)).map(CartItem.fromJson));
    }
  }

  int quantityOf(String productId) => _find(productId)?.quantity ?? 0;

  void add(Product product) {
    final item = _find(product.id);
    if (item == null) {
      _items.add(CartItem(product: product, quantity: 1));
    } else {
      item.quantity++;
    }
    _save();
  }

  void decrease(String productId) {
    final item = _find(productId);
    if (item == null) return;
    item.quantity--;
    if (item.quantity <= 0) _items.remove(item);
    _save();
  }

  void remove(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _save();
  }

  void clear() {
    _items.clear();
    _save();
  }

  CartItem? _find(String productId) {
    for (final item in _items) {
      if (item.product.id == productId) return item;
    }
    return null;
  }

  String _key(String userId) => 'cart_$userId';

  void _save() {
    notifyListeners();
    final userId = _userId;
    if (userId != null) {
      _storage.writeList(_key(userId), _items.map((e) => e.toJson()).toList());
    }
  }
}
