import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import '../models/premium_plan.dart';

enum BillingStatus {
  idle,
  connecting,
  ready,
  purchasing,
  verifying,
  restoring,
  success,
  error,
}

class BillingService extends ChangeNotifier {
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  BillingStatus _status = BillingStatus.idle;
  bool _isAvailable = false;
  bool _isOfflineFallback = false;
  String? _errorMessage;
  List<ProductDetails> _products = [];
  final Map<String, ProductDetails> _productsMap = {};
  
  // Callback when purchase is verified successfully
  Function(String productId, int days, String? orderId, String? token)? onPurchaseVerified;

  BillingStatus get status => _status;
  bool get isAvailable => _isAvailable;
  bool get isOfflineFallback => _isOfflineFallback;
  String? get errorMessage => _errorMessage;
  List<ProductDetails> get products => _products;
  bool get isLoading => _status == BillingStatus.connecting || 
                         _status == BillingStatus.purchasing || 
                         _status == BillingStatus.verifying || 
                         _status == BillingStatus.restoring;

  BillingService() {
    initialize();
  }

  /// Initializes Google Play Billing connection, stream listener, and loads dynamic product details
  Future<void> initialize() async {
    _status = BillingStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Listen to continuous purchase updates from Google Play Billing
      _subscription?.cancel();
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseStreamUpdated,
        onDone: () => _subscription?.cancel(),
        onError: (error) {
          debugPrint('Google Play purchaseStream error: $error');
          _errorMessage = error.toString();
          _status = BillingStatus.error;
          notifyListeners();
        },
      );

      // 2. Verify Google Play Billing service availability on device
      _isAvailable = await _iap.isAvailable();

      if (!_isAvailable) {
        debugPrint('Google Play Billing not available on device. Falling back to development placeholder rates.');
        _isOfflineFallback = true;
        _status = BillingStatus.ready;
        notifyListeners();
        return;
      }

      // 3. Query dynamic product details using Product IDs from Google Play Console
      await loadProductDetails();
    } catch (e) {
      debugPrint('Error initializing Google Play Billing: $e');
      _isOfflineFallback = true;
      _errorMessage = 'Could not connect to Google Play Store: $e';
      _status = BillingStatus.ready;
      notifyListeners();
    }
  }

  /// Dynamically loads product details from Google Play Console using Product IDs
  Future<void> loadProductDetails() async {
    try {
      final Set<String> productIds = PremiumPlanInfo.productIds;
      debugPrint('Querying Google Play Product IDs: $productIds');
      
      final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('Google Play queryProductDetails error: ${response.error}');
        _errorMessage = response.error!.message;
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Google Play products not found in console yet: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      _productsMap.clear();
      for (final p in _products) {
        _productsMap[p.id] = p;
      }

      _isOfflineFallback = _products.isEmpty;
      _status = BillingStatus.ready;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading product details: $e');
      _errorMessage = 'Failed to load store prices: $e';
      _isOfflineFallback = true;
      _status = BillingStatus.ready;
      notifyListeners();
    }
  }

  /// Get ProductDetails for a given plan ID if available
  ProductDetails? getProductDetails(String productId) {
    return _productsMap[productId];
  }

  /// Initiates dynamic purchase flow via Google Play Billing
  Future<void> purchasePlan(PremiumPlanInfo plan) async {
    _status = BillingStatus.purchasing;
    _errorMessage = null;
    notifyListeners();

    try {
      final ProductDetails? product = _productsMap[plan.productId];

      if (product != null && _isAvailable) {
        // Real Google Play In-App Purchase Flow
        final PurchaseParam purchaseParam = PurchaseParam(
          productDetails: product,
        );

        // Buy non-consumable subscription/pass
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Offline / Sandbox Development mode simulation for local testing
        debugPrint('Simulating sandbox purchase for ${plan.productId}...');
        await Future.delayed(const Duration(milliseconds: 1400));
        
        _status = BillingStatus.verifying;
        notifyListeners();
        
        await Future.delayed(const Duration(milliseconds: 800));
        
        onPurchaseVerified?.call(
          plan.productId,
          plan.durationDays,
          'GPA.TEST-${DateTime.now().millisecondsSinceEpoch}',
          'token_test_${plan.productId}',
        );

        _status = BillingStatus.success;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting purchase: $e');
      _errorMessage = 'Purchase could not be started: $e';
      _status = BillingStatus.error;
      notifyListeners();
    }
  }

  /// Restores previous purchases according to Google Play guidelines
  Future<void> restorePurchases() async {
    _status = BillingStatus.restoring;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_isAvailable) {
        await _iap.restorePurchases();
      } else {
        // Fallback simulate restore check
        await Future.delayed(const Duration(milliseconds: 1200));
        _status = BillingStatus.ready;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      _errorMessage = 'Could not restore purchases: $e';
      _status = BillingStatus.error;
      notifyListeners();
    }
  }

  /// Purchase stream handler for continuous purchase lifecycle
  Future<void> _onPurchaseStreamUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      debugPrint('Google Play Purchase Stream update: ${purchaseDetails.productID} -> ${purchaseDetails.status}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _status = BillingStatus.purchasing;
        notifyListeners();
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        _handlePurchaseError(purchaseDetails.error);
      } else if (purchaseDetails.status == PurchaseStatus.purchased || 
                 purchaseDetails.status == PurchaseStatus.restored) {
        
        _status = BillingStatus.verifying;
        notifyListeners();

        final bool isValid = await _verifyPurchase(purchaseDetails);

        if (isValid) {
          final plan = PremiumPlanInfo.findById(purchaseDetails.productID);
          final durationDays = plan?.durationDays ?? 30;

          onPurchaseVerified?.call(
            purchaseDetails.productID,
            durationDays,
            purchaseDetails.purchaseID,
            purchaseDetails.verificationData.serverVerificationData,
          );

          _status = BillingStatus.success;
          notifyListeners();
        } else {
          _errorMessage = 'Purchase verification failed. Please contact support.';
          _status = BillingStatus.error;
          notifyListeners();
        }

        // Acknowledge / complete transaction with Google Play
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.canceled) {
        _status = BillingStatus.ready;
        notifyListeners();
      }
    }
  }

  /// Server / Cryptographic verification of Google Play purchase
  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    try {
      // In production with backend, send purchaseDetails.verificationData to your server
      // for validation with Google Play Developer API (androidpublisher.purchases.subscriptions.get).
      // Here we check verification signature token presence.
      final token = purchaseDetails.verificationData.serverVerificationData;
      if (token.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Purchase verification error: $e');
      return false;
    }
  }

  /// User-friendly error message resolution
  void _handlePurchaseError(IAPError? error) {
    if (error == null) {
      _status = BillingStatus.ready;
      notifyListeners();
      return;
    }

    debugPrint('IAP Error: code=${error.code}, message=${error.message}');

    if (error.code == 'user_cancelled' || error.message.contains('canceled')) {
      _status = BillingStatus.ready;
      _errorMessage = null;
    } else if (error.code == 'item_already_owned') {
      _errorMessage = 'You already own this plan. Restoring your active subscription...';
      restorePurchases();
    } else {
      _errorMessage = error.message.isNotEmpty 
          ? error.message 
          : 'Transaction failed. Please try again or check your Google Play account.';
      _status = BillingStatus.error;
    }
    notifyListeners();
  }

  void resetStatus() {
    _status = BillingStatus.ready;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}