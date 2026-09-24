import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_ease/models/cart_item.dart';
import 'package:shop_ease/models/order.dart';
import 'package:shop_ease/models/product.dart';
import 'package:shop_ease/services/connectivity_service.dart';
import 'package:shop_ease/services/order_api.dart';
import 'package:shop_ease/services/storage.dart';
import 'package:shop_ease/state/cart_state.dart';
import 'package:shop_ease/state/order_state.dart';
import 'package:shop_ease/utils/format.dart';

/// Fake server: stores orders by id, like Firestore does.
class FakeOrderApi implements OrderApi {
  final Map<String, Order> server = {};
  int calls = 0;
  int failNext = 0;

  @override
  Future<void> submit(Order order) async {
    calls++;
    if (failNext > 0) {
      failNext--;
      throw TimeoutException('slow network');
    }
    server.putIfAbsent(order.id, () => order);
  }
}

const rice = Product(
    id: 'p1', name: 'Rice', category: 'Grocery', price: 450, image: '', description: '');
const milk = Product(
    id: 'p2', name: 'Milk', category: 'Grocery', price: 60, image: '', description: '');

void main() {
  late Storage storage;
  late ConnectivityService connectivity;
  late FakeOrderApi api;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = await Storage.open();
    connectivity = ConnectivityService();
    api = FakeOrderApi();
  });

  Future<Order> place(OrderState orders, String id) => orders.placeOrder(
        orderId: id,
        items: [CartItem(product: rice, quantity: 2)],
        name: 'Asha',
        phone: '9876543210',
        address: '12 MG Road, Bengaluru',
        pincode: '560001',
      );

  test('rupee format uses Indian grouping', () {
    expect(rupees(129900), '₹1,29,900');
  });

  test('cart totals and cart survives an app restart', () {
    final cart = CartState(storage)..setUser('u1');
    cart.add(rice);
    cart.add(rice);
    cart.add(milk);
    expect(cart.count, 3);
    expect(cart.total, 450 * 2 + 60);

    cart.decrease('p2');
    expect(cart.quantityOf('p2'), 0);

    final reopened = CartState(storage)..setUser('u1');
    expect(reopened.count, 2);
    expect(reopened.total, 900);
  });

  test('offline order is pending, then syncs when back online', () async {
    connectivity.setOnline(false);
    final orders = OrderState(storage, api, connectivity)..setUser('u1');

    final order = await place(orders, 'order-1');
    expect(order.status, OrderStatus.pending);
    expect(api.calls, 0);

    connectivity.setOnline(true);
    await pumpEventQueue();
    expect(orders.orders.single.status, OrderStatus.confirmed);
    expect(api.server.length, 1);
    orders.dispose();
  });

  test('pending order survives an app restart', () async {
    connectivity.setOnline(false);
    final orders = OrderState(storage, api, connectivity)..setUser('u1');
    await place(orders, 'order-1');
    orders.dispose();

    final reopened = OrderState(storage, api, connectivity)..setUser('u1');
    expect(reopened.orders.single.status, OrderStatus.pending);
    reopened.dispose();
  });

  test('timeout keeps order pending; retry does not duplicate it', () async {
    api.failNext = 1;
    final orders = OrderState(storage, api, connectivity)..setUser('u1');

    final order = await place(orders, 'order-1');
    expect(order.status, OrderStatus.pending);
    expect(order.error, isNotNull);

    // Double tap on "Place order" uses the same id: still one order.
    await place(orders, 'order-1');
    await orders.syncPending();
    await orders.syncPending();

    expect(orders.orders.length, 1);
    expect(orders.orders.single.status, OrderStatus.confirmed);
    expect(api.server.length, 1);
    orders.dispose();
  });
}
