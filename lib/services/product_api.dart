import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/product.dart';
import '../utils/errors.dart';
import 'connectivity_service.dart';

/// Mock product API that reads assets/data/products.json.
/// It needs internet and has a small delay, like a real API.
class ProductApi {
  ProductApi(this._connectivity);

  final ConnectivityService _connectivity;

  Future<List<Product>> fetchProducts() async {
    if (!_connectivity.isOnline) {
      throw const AppException('No internet connection.');
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final raw = await rootBundle.loadString('assets/data/products.json');
    return (jsonDecode(raw) as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
