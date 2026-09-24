import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/product_list_screen.dart';
import 'services/connectivity_service.dart';
import 'services/order_api.dart';
import 'services/product_api.dart';
import 'services/storage.dart';
import 'state/auth_state.dart';
import 'state/cart_state.dart';
import 'state/order_state.dart';
import 'state/product_state.dart';
import 'widgets/common.dart';

class ShopEaseApp extends StatelessWidget {
  const ShopEaseApp({super.key, required this.storage, required this.connectivity});

  final Storage storage;
  final ConnectivityService connectivity;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: connectivity),
        ChangeNotifierProvider(create: (_) => AuthState()),
        ChangeNotifierProvider(
            create: (_) => ProductState(ProductApi(connectivity), storage)),
        // Cart and orders are loaded for whoever is logged in.
        ChangeNotifierProxyProvider<AuthState, CartState>(
          create: (_) => CartState(storage),
          update: (_, auth, cart) => cart!..setUser(auth.user?.uid),
        ),
        ChangeNotifierProxyProvider<AuthState, OrderState>(
          lazy: false, // Start sending pending orders as soon as the app opens.
          create: (_) => OrderState(storage, OrderApi(), connectivity),
          update: (_, auth, orders) => orders!..setUser(auth.user?.uid),
        ),
      ],
      child: MaterialApp(
        title: 'ShopEase',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        // Offline bar on top of every screen.
        builder: (context, child) {
          final online = context.watch<ConnectivityService>().isOnline;
          return Column(
            children: [
              const OfflineBanner(),
              Expanded(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: !online, // The banner already covers the status bar.
                  child: child!,
                ),
              ),
            ],
          );
        },
        home: const AuthGate(),
      ),
    );
  }
}

/// Shows a spinner while checking for a saved login, then login or shop.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (!auth.ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.user == null ? const LoginScreen() : const ProductListScreen();
  }
}
