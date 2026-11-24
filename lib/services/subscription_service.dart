import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../config/monetization_config.dart';
import 'app_state.dart';

/// Handles Google Play Billing (Android) and StoreKit (iOS) subscriptions
/// via Flutter's official `in_app_purchase` package.
class SubscriptionService extends ChangeNotifier {
  final AppState appState;
  InAppPurchase? _iapInstance;

  InAppPurchase get _iap => _iapInstance ??= InAppPurchase.instance;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  ProductDetails? _productDetails;
  bool _storeAvailable = false;
  bool _isPurchasing = false;
  String? _lastError;

  SubscriptionService({required this.appState});

  bool get storeAvailable => _storeAvailable;
  bool get isPurchasing => _isPurchasing;
  String? get lastError => _lastError;
  ProductDetails? get productDetails => _productDetails;

  String get displayPrice =>
      _productDetails?.price ?? MonetizationConfig.fallbackPriceLabel;

  Future<void> initialize() async {
    if (!MonetizationConfig.isMobilePlatform) return;

    try {
      _storeAvailable = await _iap.isAvailable();
      if (!_storeAvailable) return;

      _purchaseSub = _iap.purchaseStream.listen(
        _onPurchaseUpdates,
        onError: (Object error) {
          _isPurchasing = false;
          _lastError = error.toString();
          notifyListeners();
        },
      );

      await _queryProductDetails();
    } catch (e) {
      debugPrint('SubscriptionService init error: $e');
    }
  }

  Future<void> _queryProductDetails() async {
    final response = await _iap.queryProductDetails({
      MonetizationConfig.subscriptionProductId,
    });
    if (response.productDetails.isNotEmpty) {
      _productDetails = response.productDetails.first;
      notifyListeners();
    }
  }

  Future<bool> buySubscription() async {
    _lastError = null;

    if (!MonetizationConfig.isMobilePlatform) {
      // On desktop/web previews where store billing is unavailable, unlock locally
      await appState.unlockPro();
      return true;
    }

    if (!_storeAvailable) {
      _lastError = 'Store is not available on this device.';
      notifyListeners();
      return false;
    }

    if (_productDetails == null) {
      await _queryProductDetails();
    }

    final product = _productDetails;
    if (product == null) {
      _lastError =
          'Subscription "${MonetizationConfig.subscriptionProductId}" not found in store console.';
      notifyListeners();
      return false;
    }

    _isPurchasing = true;
    notifyListeners();

    try {
      final param = PurchaseParam(productDetails: product);
      final started = await _iap.buyNonConsumable(purchaseParam: param);
      if (!started) {
        _isPurchasing = false;
        notifyListeners();
      }
      return started;
    } catch (e) {
      _isPurchasing = false;
      _lastError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> restorePurchases() async {
    if (!MonetizationConfig.isMobilePlatform || !_storeAvailable) return;
    _isPurchasing = true;
    _lastError = null;
    notifyListeners();
    try {
      await _iap.restorePurchases();
    } catch (e) {
      _lastError = e.toString();
    } finally {
      _isPurchasing = false;
      notifyListeners();
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.pending:
          _isPurchasing = true;
          notifyListeners();
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == MonetizationConfig.subscriptionProductId) {
            await appState.unlockPro();
          }
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          _isPurchasing = false;
          _lastError = null;
          notifyListeners();
          break;
        case PurchaseStatus.error:
          _isPurchasing = false;
          _lastError = purchase.error?.message ?? 'Purchase failed.';
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          notifyListeners();
          break;
        case PurchaseStatus.canceled:
          _isPurchasing = false;
          notifyListeners();
          break;
      }
    }
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }
}
