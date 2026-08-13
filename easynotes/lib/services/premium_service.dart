import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../database/boxes.dart';
import '../database/hive_service.dart';
import '../models/premium_plan.dart';
import 'billing_service.dart';

class PremiumService extends ChangeNotifier {
  final HiveService _hiveService;
  final BillingService _billingService;

  static const String _keyIsPremium = 'is_premium';
  static const String _keyActivePlanId = 'active_plan_id';
  static const String _keyPurchaseToken = 'purchase_token';
  static const String _keyOrderId = 'order_id';
  static const String _keyExpiryDate = 'expiry_date';
  static const String _keyPurchaseDate = 'purchase_date';

  bool _isPremium = false;
  String? _activePlanId;
  String? _purchaseToken;
  String? _orderId;
  DateTime? _expiryDate;
  DateTime? _purchaseDate;

  bool get isPremium => _isPremium;
  String? get activePlanId => _activePlanId;
  String? get purchaseToken => _purchaseToken;
  String? get orderId => _orderId;
  DateTime? get expiryDate => _expiryDate;
  DateTime? get purchaseDate => _purchaseDate;

  PremiumPlanInfo? get currentPlan => _activePlanId != null ? PremiumPlanInfo.findById(_activePlanId!) : null;

  int get daysRemaining {
    if (!_isPremium || _expiryDate == null) return 0;
    final diff = _expiryDate!.difference(DateTime.now()).inDays;
    return diff < 0 ? 0 : diff;
  }

  PremiumService({
    required HiveService hiveService,
    required BillingService billingService,
  })  : _hiveService = hiveService,
        _billingService = billingService {
    
    // Wire purchase verification listener from BillingService
    _billingService.onPurchaseVerified = _onPurchaseVerified;

    // Load locally persisted premium state
    _loadState();

    // Perform automatic background restoration check
    _autoRestoreOnStartup();
  }

  /// Loads premium data from persistent Hive storage
  void _loadState() {
    try {
      final box = _hiveService.premiumBox;
      _isPremium = box.get(_keyIsPremium, defaultValue: false) as bool;
      _activePlanId = box.get(_keyActivePlanId) as String?;
      _purchaseToken = box.get(_keyPurchaseToken) as String?;
      _orderId = box.get(_keyOrderId) as String?;

      final expiryStr = box.get(_keyExpiryDate) as String?;
      if (expiryStr != null) {
        _expiryDate = DateTime.tryParse(expiryStr);
        // Verify expiry
        if (_expiryDate != null && _expiryDate!.isBefore(DateTime.now())) {
          debugPrint('Premium membership has expired. Revoking active status.');
          _isPremium = false;
        }
      }

      final purchaseStr = box.get(_keyPurchaseDate) as String?;
      if (purchaseStr != null) {
        _purchaseDate = DateTime.tryParse(purchaseStr);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading premium state: $e');
    }
  }

  /// Automatically checks and restores previous purchases after app reinstall
  Future<void> _autoRestoreOnStartup() async {
    try {
      if (!_isPremium && _billingService.isAvailable) {
        debugPrint('Performing automatic background Google Play purchase restoration...');
        await _billingService.restorePurchases();
      }
    } catch (e) {
      debugPrint('Auto restore check error: $e');
    }
  }

  /// Handles verified purchases from BillingService
  Future<void> _onPurchaseVerified(String productId, int days, String? orderId, String? token) async {
    final now = DateTime.now();
    
    // If user already has active time remaining, extend it
    final baseDate = (_isPremium && _expiryDate != null && _expiryDate!.isAfter(now))
        ? _expiryDate!
        : now;
    
    final newExpiryDate = baseDate.add(Duration(days: days));

    _isPremium = true;
    _activePlanId = productId;
    _purchaseToken = token;
    _orderId = orderId;
    _purchaseDate = now;
    _expiryDate = newExpiryDate;

    // Persist securely to Hive
    final box = _hiveService.premiumBox;
    await box.put(_keyIsPremium, true);
    await box.put(_keyActivePlanId, productId);
    if (token != null) await box.put(_keyPurchaseToken, token);
    if (orderId != null) await box.put(_keyOrderId, orderId);
    await box.put(_keyExpiryDate, newExpiryDate.toIso8601String());
    await box.put(_keyPurchaseDate, now.toIso8601String());

    notifyListeners();
  }

  /// Manual reset for testing / development
  Future<void> clearPremium() async {
    _isPremium = false;
    _activePlanId = null;
    _purchaseToken = null;
    _orderId = null;
    _expiryDate = null;
    _purchaseDate = null;

    final box = _hiveService.premiumBox;
    await box.clear();
    notifyListeners();
  }
}