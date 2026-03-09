import 'package:flutter/material.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/model/product.dart';

class ProductFetcher extends ChangeNotifier {
  ProductFetcher({required String barcode})
      : _barcode = barcode,
        _state = ProductFetcherLoading() {
    loadProduct();
  }

  final String _barcode;
  ProductFetcherState _state;
  bool _isDisposed = false; // Sécurité pour éviter le crash

  @override
  void dispose() {
    _isDisposed = true; // On marque l'objet comme détruit
    super.dispose();
  }

  Future<void> loadProduct() async {
    _state = ProductFetcherLoading();
    _safeNotify(); // Utilise la fonction sécurisée au lieu de notifyListeners()

    try {
      Product product = await OpenFoodFactsAPI().getProduct(_barcode);
      _state = ProductFetcherSuccess(product);
    } catch (error) {
      _state = ProductFetcherError(error);
    } finally {
      _safeNotify();
    }
  }

  // Fonction pour ne notifier que si l'écran est encore affiché
  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  ProductFetcherState get state => _state;
}

sealed class ProductFetcherState {}
class ProductFetcherLoading extends ProductFetcherState {}
class ProductFetcherSuccess extends ProductFetcherState {
  ProductFetcherSuccess(this.product);
  final Product product;
}
class ProductFetcherError extends ProductFetcherState {
  ProductFetcherError(this.error);
  final dynamic error;
}