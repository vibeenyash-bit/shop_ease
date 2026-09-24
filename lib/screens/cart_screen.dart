import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cart_state.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? EmptyView(
              icon: Icons.shopping_cart_outlined,
              message: 'Your cart is empty',
              action: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Start shopping'),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (_, i) {
                final item = cart.items[i];
                return Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: ProductImage(url: item.product.image, size: 72),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text('${rupees(item.product.price)} each',
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          QuantityButtons(
                            quantity: item.quantity,
                            onAdd: () => cart.add(item.product),
                            onRemove: () => cart.decrease(item.product.id),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          tooltip: 'Remove',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => cart.remove(item.product.id),
                        ),
                        Text(rupees(item.total),
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total (${cart.count} items)',
                              style: const TextStyle(color: Colors.grey)),
                          Text(rupees(cart.total),
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                      style: FilledButton.styleFrom(minimumSize: const Size(150, 50)),
                      child: const Text('Checkout'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
