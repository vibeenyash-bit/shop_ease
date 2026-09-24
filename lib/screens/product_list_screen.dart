import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../state/auth_state.dart';
import '../state/cart_state.dart';
import '../state/order_state.dart';
import '../state/product_state.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) context.read<ProductState>().load();
    });
    // Coming back to the app: try sending pending orders.
    _lifecycle = AppLifecycleListener(
      onResume: () => context.read<OrderState>().syncPending(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (yes == true && mounted) await context.read<AuthState>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ProductState>();
    final cartCount = context.watch<CartState>().count;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopEase'),
        actions: [
          IconButton(
            tooltip: 'Orders',
            icon: const Icon(Icons.receipt_long_outlined),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
          ),
          IconButton(
            tooltip: 'Cart',
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const CartScreen())),
          ),
          IconButton(tooltip: 'Logout', icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              onChanged: state.search,
              decoration: const InputDecoration(
                hintText: 'Search products',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
          if (state.fromCache)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text('Showing saved products. Pull down to refresh.',
                  style: TextStyle(color: Colors.orange)),
            ),
          Expanded(child: _body(state)),
        ],
      ),
    );
  }

  Widget _body(ProductState state) {
    if (state.loading && !state.hasProducts) return const LoadingView();
    if (state.error != null && !state.hasProducts) {
      return ErrorView(message: state.error!, onRetry: state.load);
    }
    final products = state.products;
    return RefreshIndicator(
      onRefresh: state.load,
      child: products.isEmpty
          ? ListView(children: const [
              SizedBox(height: 80),
              EmptyView(icon: Icons.search_off, message: 'No products found'),
            ])
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: products.length,
              itemBuilder: (_, i) => _ProductCard(product: products[i]),
            ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();
    final quantity = cart.quantityOf(product.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: ProductImage(url: product.image)),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(rupees(product.price),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                height: 40,
                child: quantity == 0
                    ? FilledButton.tonal(
                        onPressed: () => cart.add(product),
                        child: const Text('Add to cart'),
                      )
                    : Center(
                        child: QuantityButtons(
                          quantity: quantity,
                          onAdd: () => cart.add(product),
                          onRemove: () => cart.decrease(product.id),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
