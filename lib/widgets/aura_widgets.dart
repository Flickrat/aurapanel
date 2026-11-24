import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Custom toggle switch matching `switch_track.xml` and `switch_thumb.xml`.
class AuraSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AuraSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return GestureDetector(
      onTap: enabled ? () => onChanged!(!value) : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 44,
        height: 24,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.greenPrimary : AppColors.switchOff,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: value ? AppColors.onGreen : AppColors.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal progress meter matching `custom_progress.xml`.
class AuraProgressBar extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;

  const AuraProgressBar({
    super.key,
    required this.progress,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.divider,
            borderRadius: BorderRadius.circular(height / 2),
          ),
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: constraints.maxWidth * clamped,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.greenPrimary,
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        );
      },
    );
  }
}

/// Square rounded icon tile matching `RowIconTile` (`bg_icon_green_main_round.xml`).
class AuraIconTile extends StatelessWidget {
  final Widget child;
  final double size;
  final double padding;
  final Color backgroundColor;
  final double radius;

  const AuraIconTile({
    super.key,
    required this.child,
    this.size = 32,
    this.padding = 7,
    this.backgroundColor = AppColors.greenSoft,
    this.radius = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }
}

/// Elevated icon button matching `bg_btn_icon.xml`.
class AuraIconButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final double padding;

  const AuraIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 36,
    this.padding = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBgElevated,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: AppColors.greenSoft,
        child: Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder, width: 1),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Neon green primary button matching `btn_main_green_round.xml`.
class AuraGreenButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;

  const AuraGreenButton({
    super.key,
    required this.child,
    this.onTap,
    this.height = 44,
    this.borderRadius = 12,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.greenPrimary,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        splashColor: Colors.black12,
        child: Container(
          height: height,
          padding: padding,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}

/// Section header row matching `SectionHeader` + `SectionTitle`.
class AuraSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;

  const AuraSectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AuraIconTile(
          size: 32,
          padding: 7,
          child: Icon(icon, color: AppColors.greenPrimary, size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.display(
              13,
              color: AppColors.greenPrimary,
              letterSpacing: 0.06,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Expandable feature card matching `FeatureCard`, `FeatureHead`, `FeatureDesc`, `FeatureBody`.
class AuraFeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final bool expanded;
  final ValueChanged<bool>? onToggle;
  final Widget body;

  const AuraFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.expanded,
    required this.onToggle,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.display(
                    13,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.04,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              AuraSwitch(value: expanded, onChanged: onToggle),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.body(11, color: AppColors.textSecondary, height: 1.3),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: body,
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 220),
          ),
        ],
      ),
    );
  }
}

/// Key-value row matching `InfoRow` / `InfoLabel` / `InfoValue`.
class AuraInfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double valueSize;

  const AuraInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
    this.valueSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: AppTextStyles.body(11.5, color: AppColors.textSoft),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.display(
                valueSize,
                color: valueColor,
                letterSpacing: 0.02,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sensitivity meter row matching `MeterLabel` / `Meter` / `MeterValue`.
class AuraMeterRow extends StatelessWidget {
  final String label;
  final int? value;
  final int maxValue;

  const AuraMeterRow({
    super.key,
    required this.label,
    required this.value,
    this.maxValue = 200,
  });

  @override
  Widget build(BuildContext context) {
    final progress = value == null ? 0.0 : (value! / maxValue).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.body(11.5, color: AppColors.textSoft),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: AuraProgressBar(progress: progress, height: 6)),
          const SizedBox(width: 10),
          SizedBox(
            width: 34,
            child: Text(
              value == null ? '--' : '$value',
              textAlign: TextAlign.end,
              style: AppTextStyles.display(12, color: AppColors.greenPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
