import 'dart:io';
import 'package:flutter/foundation.dart';

/// Centralized AdMob & In-App Purchase configuration.
///
/// Automatically uses Google's official test Ad Unit IDs in debug builds
/// (`kDebugMode`) to prevent invalid traffic, and switches to your production
/// iOS AdMob IDs in release/profile builds (Codemagic TestFlight & App Store).
class MonetizationConfig {
  MonetizationConfig._();

  // App Store ID (for native App Store review & share link)
  static const String appStoreId = '6838112895';

  // Legal URLs (required on auto-renewable subscription paywalls by Apple 3.1.2)
  // Replace privacyPolicyUrl with your own hosted privacy policy if desired.
  static const String privacyPolicyUrl =
      'https://sites.google.com/view/app-sens-ffh-red-tool/home';
  static const String termsOfUseUrl =
      'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

  // IAP Subscription Product ID
  static const String subscriptionProductId = 'free_style_month';
  static const String fallbackPriceLabel = '\$6.99';
  static const int defaultTrialDays = 3;

  // Cooldown between interstitial ads (seconds)
  static const int interstitialCooldownSeconds = 30;

  static bool get isMobilePlatform =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String get appOpenAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-6687779687898901/1029608578';
    }
    return 'ca-app-pub-3940256099942544/9257395921';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-6687779687898901/5469662447';
    }
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static String get rewardedAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-6687779687898901/4529869882';
    }
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  static String get nativeAdUnitId {
    if (kIsWeb) return '';
    if (Platform.isIOS) {
      return kDebugMode
          ? 'ca-app-pub-3940256099942544/3986624511'
          : 'ca-app-pub-6687779687898901/1666148802';
    }
    return 'ca-app-pub-3940256099942544/2247696110';
  }
}
