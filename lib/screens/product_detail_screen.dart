import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/cart_state.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final quantity = cart.quantityOf(product.id);

    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: ListView(
        children: [
          ProductImage(url: product.image, size: 300),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.category, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(rupees(product.price),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 16),
                Text(product.description, style: const TextStyle(fontSize: 16, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: quantity == 0
              ? FilledButton(
                  onPressed: () => cart.add(product),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  child: const Text('Add to cart'),
                )
              : Row(
                  children: [
                    QuantityButtons(
                      quantity: quantity,
                      onAdd: () => cart.add(product),
                      onRemove: () => cart.decrease(product.id),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.push(
                            context, MaterialPageRoute(builder: (_) => const CartScreen())),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                        child: const Text('Go to cart'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
