import 'package:cloud_firestore/cloud_firestore.dart' hide Order;

import '../models/order.dart';

/// Sends orders to Firestore at users/{uid}/orders/{orderId}.
class OrderApi {
  static const timeout = Duration(seconds: 15);

  /// Safe to call many times for the same order: the order id is the
  /// document id, and the order is only written if it doesn't exist yet.
  /// So a retry after a lost response can never create a duplicate.
  Future<void> submit(Order order) async {
    final db = FirebaseFirestore.instance;
    final doc = db
        .collection('users')
        .doc(order.userId)
        .collection('orders')
        .doc(order.id);

    final data = order.toJson()
      ..remove('status')
      ..remove('error');

    await db.runTransaction((tx) async {
      final existing = await tx.get(doc);
      if (!existing.exists) tx.set(doc, data);
    }).timeout(timeout);
  }
}
