import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumPlanInfo {
  final String productId;
  final int durationDays;
  final String title;
  final String fallbackPrice;
  final double fallbackPriceAmount;
  final String currencySymbol;
  final String description;
  final bool isPopular;
  final bool isBestValue;

  const PremiumPlanInfo({
    required this.productId,
    required this.durationDays,
    required this.title,
    required this.fallbackPrice,
    required this.fallbackPriceAmount,
    this.currencySymbol = '$',
    required this.description,
    this.isPopular = false,
    this.isBestValue = false,
  });

  /// Resolves real localized price from Google Play Billing ProductDetails if available,
  /// otherwise uses fallback example price for offline/development environments.
  String resolveDisplayPrice(ProductDetails? productDetails) {
    if (productDetails != null && productDetails.price.isNotEmpty) {
      return productDetails.price;
    }
    return fallbackPrice;
  }

  /// All 10 Supported Google Play In-App Purchase Product IDs
  static const List<PremiumPlanInfo> allPlans = [
    PremiumPlanInfo(
      productId: 'premium_3_days',
      durationDays: 3,
      title: '3 Days',
      fallbackPrice: '$0.55',
      fallbackPriceAmount: 0.55,
      description: 'Quick trial access to unlimited notes & backup',
    ),
    PremiumPlanInfo(
      productId: 'premium_7_days',
      durationDays: 7,
      title: '7 Days',
      fallbackPrice: '$1.09',
      fallbackPriceAmount: 1.09,
      description: 'Weekly full premium access & custom palettes',
    ),
    PremiumPlanInfo(
      productId: 'premium_15_days',
      durationDays: 15,
      title: '15 Days',
      fallbackPrice: '$2.09',
      fallbackPriceAmount: 2.09,
      description: 'Fortnight pass with prioritized local indexing',
    ),
    PremiumPlanInfo(
      productId: 'premium_30_days',
      durationDays: 30,
      title: '30 Days',
      fallbackPrice: '$3.09',
      fallbackPriceAmount: 3.09,
      isPopular: true,
      description: 'Most popular monthly plan for regular note taking',
    ),
    PremiumPlanInfo(
      productId: 'premium_45_days',
      durationDays: 45,
      title: '45 Days',
      fallbackPrice: '$4.09',
      fallbackPriceAmount: 4.09,
      description: 'Extended month-and-a-half access with all tools',
    ),
    PremiumPlanInfo(
      productId: 'premium_60_days',
      durationDays: 60,
      title: '60 Days',
      fallbackPrice: '$5.09',
      fallbackPriceAmount: 5.09,
      description: 'Bi-monthly pass for uninterrupted productivity',
    ),
    PremiumPlanInfo(
      productId: 'premium_120_days',
      durationDays: 120,
      title: '120 Days',
      fallbackPrice: '$10.09',
      fallbackPriceAmount: 10.09,
      description: 'Semester & project pass with markdown export',
    ),
    PremiumPlanInfo(
      productId: 'premium_365_days',
      durationDays: 365,
      title: '365 Days',
      fallbackPrice: '$24.09',
      fallbackPriceAmount: 24.09,
      isBestValue: true,
      description: 'Best Value annual plan. Save over 35%',
    ),
    PremiumPlanInfo(
      productId: 'premium_730_days',
      durationDays: 730,
      title: '730 Days',
      fallbackPrice: '$52.09',
      fallbackPriceAmount: 52.09,
      description: 'Two full years with locked-in discount pricing',
    ),
    PremiumPlanInfo(
      productId: 'premium_1825_days',
      durationDays: 1825,
      title: '1825 Days',
      fallbackPrice: '$99.09',
      fallbackPriceAmount: 99.09,
      description: 'Ultimate 5-year lifetime pass with priority upgrades',
    ),
  ];

  /// Set of all Product IDs for Google Play Billing query
  static Set<String> get productIds => allPlans.map((p) => p.productId).toSet();

  /// Find plan by product ID
  static PremiumPlanInfo? findById(String productId) {
    try {
      return allPlans.firstWhere((p) => p.productId == productId);
    } catch (_) {
      return null;
    }
  }
}
