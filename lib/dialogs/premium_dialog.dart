import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/monetization_config.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_widgets.dart';

class PremiumDialog extends StatefulWidget {
  final AppState appState;
  final String? storeNameOverride;

  const PremiumDialog({
    super.key,
    required this.appState,
    this.storeNameOverride,
  });

  static Future<bool?> show(BuildContext context, AppState appState) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Premium',
      barrierColor: AppColors.bgPrimary,
      transitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => PremiumDialog(appState: appState),
      transitionBuilder: (_, anim, _, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    );
  }

  @override
  State<PremiumDialog> createState() => _PremiumDialogState();
}

class _PremiumDialogState extends State<PremiumDialog>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    widget.appState.addListener(_onStateChanged);
    widget.appState.subscription.addListener(_onSubChanged);
  }

  void _onStateChanged() {
    if (widget.appState.isPro && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.appState.strings.subscriptionSuccess,
            style: AppTextStyles.body(12, color: AppColors.onGreen),
          ),
          backgroundColor: AppColors.greenPrimary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  void _onSubChanged() {
    if (!mounted) return;
    setState(() {});
    final err = widget.appState.subscription.lastError;
    if (err != null && err.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            err,
            style: AppTextStyles.body(12, color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.cardBgElevated,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    widget.appState.removeListener(_onStateChanged);
    widget.appState.subscription.removeListener(_onSubChanged);
    _floatCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _storeName =>
      widget.storeNameOverride ??
      ((!kIsWeb && Platform.isIOS) ? 'App Store' : 'Google Play');

  Future<void> _activateTrial() async {
    await widget.appState.subscription.buySubscription();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState.strings;
    final perks = [
      ('assets/images/icon_fps.webp', s.perkFps, s.perkFpsDesc),
      ('assets/images/icon_signal.webp', s.perkPing, s.perkPingDesc),
      ('assets/images/icon_device.webp', s.perkHz, s.perkHzDesc),
      ('assets/images/icon_temp.webp', s.perkTemp, s.perkTempDesc),
      (null, s.perkSensi, s.perkSensiDesc),
      ('assets/images/icon_block.webp', s.perkNoAds, s.perkNoAdsDesc),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 14),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _floatCtrl,
                          builder: (_, child) {
                            final dy = -12.0 * _floatCtrl.value;
                            return Transform.translate(
                              offset: Offset(0, dy),
                              child: child,
                            );
                          },
                          child: Container(
                            width: 58,
                            height: 58,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.greenSoft,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.greenLine,
                                width: 1,
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/icon_crown.webp',
                              color: AppColors.gold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.goldLine,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            s.paywallBrand,
                            style: AppTextStyles.display(
                              9.5,
                              color: AppColors.gold,
                              letterSpacing: 0.14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.paywallTitleTrial.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display(
                            22,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          s.paywallTitleDays(3).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display(
                            26,
                            color: AppColors.greenPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 260,
                          child: Text(
                            s.paywallSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body(
                              11.5,
                              color: AppColors.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Perks card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 13,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                child: Text(
                                  s.perksTitle.toUpperCase(),
                                  style: AppTextStyles.display(
                                    10,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.08,
                                  ),
                                ),
                              ),
                              for (int i = 0; i < perks.length; i++) ...[
                                _PerkRow(
                                  assetPath: perks[i].$1,
                                  title: perks[i].$2,
                                  subtitle: perks[i].$3,
                                ),
                                if (i < perks.length - 1)
                                  const Divider(
                                    color: AppColors.divider,
                                    height: 1,
                                  ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Trial timeline card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.greenLine,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.trialHow.toUpperCase(),
                                style: AppTextStyles.display(
                                  10,
                                  color: AppColors.greenPrimary,
                                  letterSpacing: 0.08,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      s.trialToday,
                                      style: AppTextStyles.display(
                                        11.5,
                                        color: AppColors.greenPrimary,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      s.trialTodayDesc,
                                      style: AppTextStyles.body(
                                        11.5,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: Divider(
                                  color: AppColors.divider,
                                  height: 1,
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      s.trialDay(3),
                                      style: AppTextStyles.display(
                                        11.5,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      s.trialEndDesc,
                                      style: AppTextStyles.body(
                                        11.5,
                                        color: AppColors.textSoft,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),
                Container(
                  color: AppColors.bgPrimary,
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
                  child: Column(
                    children: [
                      Text(
                        s.trustTrial,
                        style: AppTextStyles.body(
                          10.5,
                          color: AppColors.greenPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, child) {
                          final scale = 1.0 + (0.03 * _pulseCtrl.value);
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: AuraGreenButton(
                          height: 54,
                          onTap: widget.appState.subscription.isPurchasing
                              ? null
                              : _activateTrial,
                          child: Text(
                            widget.appState.subscription.isPurchasing
                                ? s.paywallOpening(_storeName)
                                : s.startFreeTrial,
                            style: AppTextStyles.display(
                              15.5,
                              color: AppColors.onGreen,
                              letterSpacing: 0.08,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.priceTrial(
                          MonetizationConfig.defaultTrialDays,
                          widget.appState.subscription.displayPrice,
                        ),
                        style: AppTextStyles.body(11.5, color: AppColors.textSoft),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          s.termsTrial(
                            MonetizationConfig.defaultTrialDays,
                            widget.appState.subscription.displayPrice,
                            _storeName,
                          ),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(
                            9.5,
                            color: AppColors.textTertiary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        runSpacing: 4,
                        children: [
                          GestureDetector(
                            onTap: widget.appState.subscription.isPurchasing
                                ? null
                                : () => widget.appState.subscription
                                    .restorePurchases(),
                            child: Text(
                              s.restorePurchases,
                              style: AppTextStyles.body(
                                10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '•',
                            style: AppTextStyles.body(
                              10.5,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse(MonetizationConfig.termsOfUseUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Text(
                              s.termsOfUse,
                              style: AppTextStyles.body(
                                10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          Text(
                            '•',
                            style: AppTextStyles.body(
                              10.5,
                              color: AppColors.textTertiary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse(MonetizationConfig.privacyPolicyUrl),
                              mode: LaunchMode.externalApplication,
                            ),
                            child: Text(
                              s.privacyPolicy,
                              style: AppTextStyles.body(
                                10.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              top: 8,
              left: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: Image.asset(
                  'assets/images/icon_close.webp',
                  width: 16,
                  height: 16,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  final String? assetPath;
  final String title;
  final String subtitle;

  const _PerkRow({
    required this.assetPath,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          AuraIconTile(
            size: 32,
            padding: 7,
            child: assetPath != null
                ? Image.asset(assetPath!, color: AppColors.greenPrimary)
                : const Icon(
                    Icons.bolt_rounded,
                    color: AppColors.greenPrimary,
                    size: 18,
                  ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.display(
                    11.5,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.03,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.body(
                    10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Image.asset(
            'assets/images/icon_check.webp',
            width: 16,
            height: 16,
            color: AppColors.greenPrimary,
          ),
        ],
      ),
    );
  }
}
