import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/monetization_config.dart';
import '../dialogs/premium_dialog.dart';
import '../dialogs/rate_app_dialog.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_widgets.dart';
import 'lang_screen.dart';

class SettingsScreen extends StatelessWidget {
  final AppState appState;

  const SettingsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final s = appState.strings;
        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      AuraIconButton(
                        size: 36,
                        padding: 8,
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.greenPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        s.appSettings.toUpperCase(),
                        style: AppTextStyles.display(
                          16,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.06,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        if (!appState.isPro)
                          GestureDetector(
                            onTap: () => PremiumDialog.show(context, appState),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.cardBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppColors.greenLine,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  AuraIconTile(
                                    size: 36,
                                    padding: 8,
                                    backgroundColor: AppColors.goldSoft,
                                    child: Image.asset(
                                      'assets/images/icon_crown.webp',
                                      color: AppColors.gold,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          s.unlockProFeatures,
                                          style: AppTextStyles.display(
                                            12.5,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          s.proPerks,
                                          style: AppTextStyles.body(
                                            10.5,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.greenPrimary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      s.tryForFree,
                                      style: AppTextStyles.display(
                                        9.5,
                                        color: AppColors.onGreen,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: AppColors.cardBorder,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              _SettingsRow(
                                icon: const Icon(
                                  Icons.language_rounded,
                                  color: AppColors.greenPrimary,
                                  size: 18,
                                ),
                                label: s.language,
                                trailingText: appState.languageDisplayName,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => LangScreen(
                                        appState: appState,
                                        changingLanguage: true,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(color: AppColors.divider, height: 1),
                              _SettingsRow(
                                icon: Image.asset(
                                  'assets/images/icon_star.webp',
                                  color: AppColors.greenPrimary,
                                ),
                                label: s.rateTheApp,
                                onTap: () => RateAppDialog.show(context, s),
                              ),
                              const Divider(color: AppColors.divider, height: 1),
                              _SettingsRow(
                                icon: Image.asset(
                                  'assets/images/icon_share.webp',
                                  color: AppColors.greenPrimary,
                                ),
                                label: s.shareTheApp,
                                onTap: () {
                                  final storeUrl = (!kIsWeb && Platform.isIOS)
                                      ? 'https://apps.apple.com/app/id${MonetizationConfig.appStoreId}'
                                      : 'https://play.google.com/store/apps/details?id=com.dark.aurapanel';
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          'Try RabbitX - Dark Sensi Panel! $storeUrl',
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Link copied to clipboard',
                                        style: AppTextStyles.body(
                                          12,
                                          color: AppColors.onGreen,
                                        ),
                                      ),
                                      backgroundColor: AppColors.greenPrimary,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                              const Divider(color: AppColors.divider, height: 1),
                              _SettingsRow(
                                icon: const Icon(
                                  Icons.privacy_tip_outlined,
                                  color: AppColors.greenPrimary,
                                  size: 18,
                                ),
                                label: s.privacyPolicy,
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    MonetizationConfig.privacyPolicyUrl,
                                  ),
                                  mode: LaunchMode.externalApplication,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          s.versionLabel('1.0.0'),
                          style: AppTextStyles.body(
                            10.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final String? trailingText;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailingText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Row(
          children: [
            AuraIconTile(size: 32, padding: 7, child: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.body(13, color: AppColors.textPrimary),
              ),
            ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: AppTextStyles.body(11.5, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
            ],
            Image.asset(
              'assets/images/icon_open.webp',
              width: 13,
              height: 13,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
