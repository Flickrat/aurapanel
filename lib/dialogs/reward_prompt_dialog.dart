import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_widgets.dart';

/// Reward prompt dialog matching `dialog_reward_prompt.xml`.
class RewardPromptDialog extends StatelessWidget {
  final AppStrings strings;

  const RewardPromptDialog({super.key, required this.strings});

  static Future<bool> show(BuildContext context, AppStrings strings) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => RewardPromptDialog(strings: strings),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greenLine, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.greenSoft,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.greenLine, width: 1),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.greenPrimary,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              strings.unlockFeature,
              textAlign: TextAlign.center,
              style: AppTextStyles.display(16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              strings.watchAdToUnlock,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            AuraGreenButton(
              height: 42,
              onTap: () => Navigator.of(context).pop(true),
              child: Text(
                strings.watchAd.toUpperCase(),
                style: AppTextStyles.display(
                  12,
                  color: AppColors.onGreen,
                  letterSpacing: 0.06,
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                strings.cancel,
                style: AppTextStyles.body(12, color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable dark-themed Native Ad container widget.
class AuraNativeAdCard extends StatelessWidget {
  final Widget? adWidget;
  final bool loaded;

  const AuraNativeAdCard({
    super.key,
    required this.adWidget,
    required this.loaded,
  });

  @override
  Widget build(BuildContext context) {
    if (!loaded || adWidget == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.cardBgElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: adWidget,
    );
  }
}
