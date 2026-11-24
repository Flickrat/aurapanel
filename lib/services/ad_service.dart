import 'dart:async';
import 'dart:io';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/monetization_config.dart';
import '../theme/app_colors.dart';

/// Policy-compliant pure Google AdMob service (no mediation).
///
/// Compliance checklist:
/// - Requests iOS App Tracking Transparency (ATT) before initializing ads.
/// - Requests Google UMP GDPR/EEA consent via `ConsentInformation` before
///   initializing `MobileAds`.
/// - Uses `AppOpenAd` on app launch (never Interstitial on splash).
/// - Enforces 30s cooldown on Interstitials and 4-hour freshness on App Open.
/// - Auto-uses Google test ad unit IDs in debug mode.
/// - Serves zero ads when Pro is unlocked.
class AdService {
  AdService._();

  static final AdService instance = AdService._();

  bool _initialized = false;
  bool _canRequestAds = false;
  bool Function() _isProChecker = () => false;

  AppOpenAd? _appOpenAd;
  DateTime? _appOpenLoadedAt;
  bool _isLoadingAppOpen = false;

  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitial = false;
  DateTime? _lastInterstitialShownAt;

  RewardedAd? _rewardedAd;
  bool _isLoadingRewarded = false;

  bool get adsEnabled =>
      MonetizationConfig.isMobilePlatform &&
      _canRequestAds &&
      !_isProChecker();

  void setProChecker(bool Function() checker) {
    _isProChecker = checker;
  }

  /// Runs ATT (iOS) -> Google UMP Consent -> MobileAds.initialize() -> preload.
  Future<void> initialize() async {
    if (!MonetizationConfig.isMobilePlatform || _initialized) return;
    try {
      // 1. iOS App Tracking Transparency (wait briefly so UI is active)
      if (Platform.isIOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        if (status == TrackingStatus.notDetermined) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
          await AppTrackingTransparency.requestTrackingAuthorization();
        }
      }

      // 2. Google UMP Consent (EEA/UK GDPR compliance)
      await _gatherUmpConsent();

      _canRequestAds = await ConsentInformation.instance.canRequestAds();
      if (!_canRequestAds) return;

      // 3. Initialize Google Mobile Ads SDK
      await MobileAds.instance.initialize();
      _initialized = true;

      if (adsEnabled) {
        preloadAppOpen();
        preloadInterstitial();
        preloadRewarded();
      }
    } catch (e) {
      debugPrint('AdService init error: $e');
    }
  }

  Future<void> _gatherUmpConsent() async {
    final completer = Completer<void>();
    final params = ConsentRequestParameters();
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
            if (formError != null) {
              debugPrint('UMP form error: ${formError.message}');
            }
          });
        } catch (e) {
          debugPrint('UMP form exception: $e');
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      },
      (FormError error) {
        debugPrint('UMP update error: ${error.message}');
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future.timeout(
      const Duration(seconds: 6),
      onTimeout: () {},
    );
  }

  void preloadAppOpen() {
    if (!adsEnabled || _appOpenAd != null || _isLoadingAppOpen) return;
    _isLoadingAppOpen = true;
    AppOpenAd.load(
      adUnitId: MonetizationConfig.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoadedAt = DateTime.now();
          _isLoadingAppOpen = false;
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
          _isLoadingAppOpen = false;
          debugPrint('AppOpenAd failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Shows an App Open ad (policy-compliant launch placement), then runs [onDone].
  void showAppOpenThen(VoidCallback onDone) {
    if (!adsEnabled) {
      onDone();
      return;
    }

    final ad = _appOpenAd;
    final loadedAt = _appOpenLoadedAt;
    final isFresh = loadedAt != null &&
        DateTime.now().difference(loadedAt) < const Duration(hours: 4);

    if (ad == null || !isFresh) {
      ad?.dispose();
      _appOpenAd = null;
      preloadAppOpen();
      onDone();
      return;
    }

    _appOpenAd = null;
    bool completed = false;
    void finish() {
      if (completed) return;
      completed = true;
      preloadAppOpen();
      onDone();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        finish();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        finish();
      },
    );

    ad.show();
  }

  void preloadInterstitial() {
    if (!adsEnabled || _interstitialAd != null || _isLoadingInterstitial) {
      return;
    }
    _isLoadingInterstitial = true;
    InterstitialAd.load(
      adUnitId: MonetizationConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoadingInterstitial = false;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isLoadingInterstitial = false;
          debugPrint('Interstitial failed to load: ${error.message}');
        },
      ),
    );
  }

  void preloadRewarded() {
    if (!adsEnabled || _rewardedAd != null || _isLoadingRewarded) return;
    _isLoadingRewarded = true;
    RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoadingRewarded = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isLoadingRewarded = false;
          debugPrint('Rewarded failed to load: ${error.message}');
        },
      ),
    );
  }

  /// Shows an interstitial if available and cooldown has elapsed, then runs [onDone].
  void showInterstitialThen(VoidCallback onDone) {
    if (!adsEnabled) {
      onDone();
      return;
    }
    if (_lastInterstitialShownAt != null) {
      final elapsed =
          DateTime.now().difference(_lastInterstitialShownAt!).inSeconds;
      if (elapsed < MonetizationConfig.interstitialCooldownSeconds) {
        onDone();
        return;
      }
    }

    final ad = _interstitialAd;
    if (ad == null) {
      preloadInterstitial();
      onDone();
      return;
    }

    _interstitialAd = null;
    bool completed = false;
    void finish() {
      if (completed) return;
      completed = true;
      preloadInterstitial();
      onDone();
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _lastInterstitialShownAt = DateTime.now();
      },
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        finish();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        finish();
      },
    );

    ad.show();
  }

  /// Shows a rewarded ad. If not preloaded yet, attempts an on-demand load.
  Future<void> showRewarded({
    required VoidCallback onRewarded,
    required VoidCallback onFailed,
  }) async {
    if (!adsEnabled) {
      onRewarded();
      return;
    }

    RewardedAd? ad = _rewardedAd;
    _rewardedAd = null;

    ad ??= await _loadRewardedOnDemand();

    if (ad == null) {
      preloadRewarded();
      onFailed();
      return;
    }

    bool earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        preloadRewarded();
        if (earned) {
          onRewarded();
        } else {
          onFailed();
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        preloadRewarded();
        onFailed();
      },
    );

    ad.show(
      onUserEarnedReward: (_, _) {
        earned = true;
      },
    );
  }

  Future<RewardedAd?> _loadRewardedOnDemand() async {
    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: MonetizationConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('On-demand rewarded load failed: ${error.message}');
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
    return completer.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () => null,
    );
  }

  /// Creates a dark-themed NativeAd styled to match the RabbitX UI.
  NativeAd? createNativeAd({
    required VoidCallback onLoaded,
    required VoidCallback onFailed,
  }) {
    if (!adsEnabled) return null;
    return NativeAd(
      adUnitId: MonetizationConfig.nativeAdUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          debugPrint('Native ad failed to load: ${error.message}');
          ad.dispose();
          onFailed();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: AppColors.cardBgElevated,
        cornerRadius: 12,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.onGreen,
          backgroundColor: AppColors.greenPrimary,
          style: NativeTemplateFontStyle.bold,
          size: 13,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textPrimary,
          backgroundColor: AppColors.cardBgElevated,
          style: NativeTemplateFontStyle.bold,
          size: 14,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textSecondary,
          backgroundColor: AppColors.cardBgElevated,
          style: NativeTemplateFontStyle.normal,
          size: 12,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textTertiary,
          backgroundColor: AppColors.cardBgElevated,
          style: NativeTemplateFontStyle.normal,
          size: 11,
        ),
      ),
    )..load();
  }
}
