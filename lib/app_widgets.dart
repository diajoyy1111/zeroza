import 'package:flutter/material.dart';
import 'app_theme.dart';

class RongIconContainer extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final double size;

  const RongIconContainer({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.icon,
      ),
      child: Icon(icon, size: size * 0.5, color: iconColor),
    );
  }
}

class RongHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const RongHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;
    final subColor = isDark ? AppColors.textDarkSecondary : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 5,
                    color: textColor,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: subColor,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class RongBackButton extends StatelessWidget {
  const RongBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, top: 8),
        child: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}

class RongScreenTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const RongScreenTitle({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.textDark : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: textColor),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: textColor,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing! else const SizedBox(width: 48),
        ],
      ),
    );
  }
}
