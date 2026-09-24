import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/product_api.dart';
import '../services/storage.dart';
import '../utils/errors.dart';

class ProductState extends ChangeNotifier {
  ProductState(this._api, this._storage);

  final ProductApi _api;
  final Storage _storage;
  static const _cacheKey = 'products';

  List<Product> _all = [];
  bool loading = false;
  String? error;
  String _search = '';

  /// True when showing the last saved list because loading failed.
  bool fromCache = false;

  bool get hasProducts => _all.isNotEmpty;

  List<Product> get products {
    final query = _search.trim().toLowerCase();
    if (query.isEmpty) return _all;
    return _all
        .where((p) =>
            p.name.toLowerCase().contains(query) ||
            p.category.toLowerCase().contains(query))
        .toList();
  }

  void search(String text) {
    _search = text;
    notifyListeners();
  }

  Future<void> load() async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      _all = await _api.fetchProducts().timeout(const Duration(seconds: 10));
      fromCache = false;
      await _storage.writeList(_cacheKey, _all.map((p) => p.toJson()).toList());
    } catch (e) {
      // Fall back to the last saved list so the app still works offline.
      if (_all.isEmpty) {
        _all = _storage.readList(_cacheKey).map(Product.fromJson).toList();
      }
      if (_all.isEmpty) {
        error = friendlyError(e);
      } else {
        fromCache = true;
      }
    }

    loading = false;
    notifyListeners();
  }
}
