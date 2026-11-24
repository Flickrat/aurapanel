import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/monetization_config.dart';

/// App Store & Play Store policy-compliant review service.
///
/// - Uses Apple's native SKStoreReviewController (`requestReview`) for in-app
///   prompts with zero review gating (Apple Guideline 1.1.7 / 5.6.1 compliant).
/// - Opens the App Store review page directly using App Store ID `6838112895`
///   when the user explicitly taps "Rate App".
class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  static const _kLaunchCount = 'review_launch_count';
  static const _kPromptCount = 'review_prompt_count';
  static const _kLastPromptMs = 'review_last_prompt_ms';

  static const int _firstPromptLaunch = 2;
  static const int _maxPrompts = 3;
  static const Duration _cooldown = Duration(days: 7);

  InAppReview? _reviewInstance;
  InAppReview get _review => _reviewInstance ??= InAppReview.instance;

  /// Increments launch count and triggers the native OS review sheet when
  /// eligible (after 2+ launches, respecting a 7-day cooldown and 3-prompt cap).
  Future<void> trackLaunchAndMaybeRequestReview() async {
    if (!MonetizationConfig.isMobilePlatform) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final launches = (prefs.getInt(_kLaunchCount) ?? 0) + 1;
      await prefs.setInt(_kLaunchCount, launches);

      final promptCount = prefs.getInt(_kPromptCount) ?? 0;
      if (launches < _firstPromptLaunch || promptCount >= _maxPrompts) return;

      final lastMs = prefs.getInt(_kLastPromptMs) ?? 0;
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      if (lastMs > 0 && (nowMs - lastMs) < _cooldown.inMilliseconds) return;

      final available = await _review.isAvailable();
      if (!available) return;

      await Future<void>.delayed(const Duration(seconds: 2));
      await _review.requestReview();

      await prefs.setInt(_kPromptCount, promptCount + 1);
      await prefs.setInt(_kLastPromptMs, nowMs);
    } catch (e) {
      debugPrint('ReviewService requestReview error: $e');
    }
  }

  /// Opens the App Store (`6838112895`) or Play Store listing directly when
  /// triggered by a user button tap (e.g. Settings → Rate App).
  Future<void> openStoreReview() async {
    if (!MonetizationConfig.isMobilePlatform) return;
    try {
      await _review.openStoreListing(appStoreId: MonetizationConfig.appStoreId);
    } catch (e) {
      debugPrint('ReviewService openStoreListing error: $e');
    }
  }
}
