import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/order.dart';
import '../services/connectivity_service.dart';
import '../state/order_state.dart';
import '../utils/format.dart';
import '../widgets/common.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<OrderState>();
    final online = context.watch<ConnectivityService>().isOnline;
    final orders = state.orders;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order history'),
        actions: [
          if (state.pendingCount > 0)
            state.syncing
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton(
                    tooltip: 'Send pending orders',
                    icon: const Icon(Icons.sync),
                    onPressed: online ? state.syncPending : null,
                  ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: state.syncPending,
        child: orders.isEmpty
            ? ListView(children: const [
                SizedBox(height: 80),
                EmptyView(icon: Icons.receipt_long_outlined, message: 'No orders yet'),
              ])
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: orders.length,
                itemBuilder: (_, i) => _OrderCard(order: orders[i]),
              ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final pending = order.status == OrderStatus.pending;

    return Card(
      child: ExpansionTile(
        shape: const Border(),
        title: Text('Order #${order.id.substring(0, 8).toUpperCase()}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${formatDate(order.createdAt)} • ${order.itemCount} items'),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(pending ? 'Pending' : 'Confirmed'),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  backgroundColor: pending ? Colors.orange : Colors.green,
                  side: BorderSide.none,
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                Text(rupees(order.total),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            if (pending && order.error != null)
              Text(order.error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text('${item.product.name} × ${item.quantity}')),
                  Text(rupees(item.total)),
                ],
              ),
            ),
          const Divider(),
          Text('Deliver to: ${order.name}, ${order.phone}'),
          Text('${order.address} - ${order.pincode}'),
        ],
      ),
    );
  }
}
