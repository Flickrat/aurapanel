import 'package:flutter/material.dart';
import '../l10n/app_strings.dart';
import '../services/review_service.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_widgets.dart';

/// App Store policy-compliant rate dialog (no star-gating or rating filtering).
/// Sends users directly to the App Store (`6838112895`) / Play Store when they
/// choose to rate, or dismisses cleanly on "Not now".
class RateAppDialog extends StatefulWidget {
  final AppStrings strings;

  const RateAppDialog({super.key, required this.strings});

  static Future<void> show(BuildContext context, AppStrings strings) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => RateAppDialog(strings: strings),
    );
  }

  @override
  State<RateAppDialog> createState() => _RateAppDialogState();
}

class _RateAppDialogState extends State<RateAppDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRateNow() async {
    Navigator.of(context).pop();
    await ReviewService.instance.openStoreReview();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.strings;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.greenLine, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 28,
                  height: 28,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.cardBgElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Image.asset(
                    'assets/images/icon_close.webp',
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: 84,
              height: 84,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _glowCtrl,
                    builder: (_, _) => Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.greenPrimary.withValues(
                          alpha: 0.1 + 0.14 * _glowCtrl.value,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.greenLine, width: 1),
                    ),
                    child: Image.asset(
                      'assets/images/icon_star.webp',
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text(
              s.enjoyingTheApp,
              textAlign: TextAlign.center,
              style: AppTextStyles.display(17, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              s.yourFeedbackHelps,
              textAlign: TextAlign.center,
              style: AppTextStyles.body(12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: AppColors.cardBgElevated,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          s.later,
                          style: AppTextStyles.display(
                            12,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AuraGreenButton(
                    height: 42,
                    onTap: _onRateNow,
                    child: Text(
                      s.rateNow,
                      style: AppTextStyles.display(
                        12,
                        color: AppColors.onGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
