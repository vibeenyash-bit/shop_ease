import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/order.dart';
import '../state/cart_state.dart';
import '../state/order_state.dart';
import '../utils/errors.dart';
import '../utils/format.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();

  /// One id per checkout, so tapping "Place order" twice or retrying
  /// never creates two orders.
  final _orderId = const Uuid().v4();
  bool _placing = false;

  Future<void> _placeOrder() async {
    if (_placing || !_formKey.currentState!.validate()) return;
    setState(() => _placing = true);

    final cart = context.read<CartState>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final order = await context.read<OrderState>().placeOrder(
            orderId: _orderId,
            items: cart.items,
            name: _name.text.trim(),
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            pincode: _pincode.text.trim(),
          );
      cart.clear();
      navigator.popUntil((route) => route.isFirst);
      navigator.push(MaterialPageRoute(builder: (_) => const OrdersScreen()));
      messenger.showSnackBar(SnackBar(
        content: Text(order.status == OrderStatus.confirmed
            ? 'Order placed successfully!'
            : 'Order saved as pending. It will be sent when you are back online.'),
      ));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(friendlyError(e))));
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _pincode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Delivery details', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _field(_name, 'Full name', validator: (v) => v.isEmpty ? 'Enter your name' : null),
            _field(_phone, 'Mobile number',
                keyboard: TextInputType.phone,
                validator: (v) => RegExp(r'^[6-9]\d{9}$').hasMatch(v)
                    ? null
                    : 'Enter a valid 10-digit mobile number'),
            _field(_address, 'Address',
                maxLines: 3, validator: (v) => v.length < 5 ? 'Enter your full address' : null),
            _field(_pincode, 'Pincode',
                keyboard: TextInputType.number,
                validator: (v) =>
                    RegExp(r'^\d{6}$').hasMatch(v) ? null : 'Enter a valid 6-digit pincode'),
            const SizedBox(height: 8),
            const Card(
              child: ListTile(
                leading: Icon(Icons.payments_outlined),
                title: Text('Cash on Delivery'),
              ),
            ),
            const SizedBox(height: 16),
            Text('Order summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in cart.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(child: Text('${item.product.name} × ${item.quantity}')),
                    Text(rupees(item.total)),
                  ],
                ),
              ),
            const Divider(height: 24),
            Row(
              children: [
                const Expanded(
                    child: Text('Total',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Text(rupees(cart.total),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            onPressed: _placing || cart.isEmpty ? null : _placeOrder,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: _placing
                ? const SizedBox(
                    width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('Place order • ${rupees(cart.total)}'),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    required String? Function(String value) validator,
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => validator(v?.trim() ?? ''),
      ),
    );
  }
}
