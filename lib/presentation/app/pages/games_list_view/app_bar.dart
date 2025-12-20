import 'package:flutter/material.dart';
import 'package:gameboy/asset_manager/assets.gen.dart';
import 'package:gameboy/blocs/app/events.dart';
import 'package:gameboy/blocs/bloc_extensions.dart';
import 'package:gameboy/presentation/app/extensions.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Distinct app bar colors
    final appBarBackground = isDark
        ? const Color(0xFF1A1A2E) // Deep navy for dark mode
        : Colors.white;
    final controlBackground = isDark
        ? const Color(0xFF2D2D44) // Slightly lighter for controls
        : const Color(0xFFF0F0F5);
    final iconColor = isDark ? Colors.white : AppColors.brandPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: appBarBackground,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.brandPrimary.withValues(alpha: 0.2)
                : AppColors.brandPrimary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // Theme toggle button
              _AnimatedThemeButton(
                controlBackground: controlBackground,
                iconColor: iconColor,
              ),
              const Spacer(),
              // App logo
              Hero(
                tag: 'app_logo',
                child: Assets.logos.app.image(
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(),
              // Logout button
              _AppBarIconButton(
                icon: Icons.logout_rounded,
                tooltip: 'Sign out',
                onPressed: () {
                  context.addMasterPageEvent(Logout());
                },
                controlBackground: controlBackground,
                iconColor: iconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedThemeButton extends StatelessWidget {
  final Color controlBackground;
  final Color iconColor;

  const _AnimatedThemeButton({
    required this.controlBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    var isDarkMode = context.isDarkMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.addMasterPageEvent(ToggleThemeMode());
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: controlBackground,
            border: Border.all(
              color: isDarkMode
                  ? Colors.amber.withValues(alpha: 0.3)
                  : AppColors.brandPrimary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) {
              return RotationTransition(
                turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            child: Icon(
              isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              key: ValueKey(isDarkMode),
              color: isDarkMode ? Colors.amber : AppColors.brandPrimary,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color controlBackground;
  final Color iconColor;

  const _AppBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.controlBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: controlBackground,
              border: Border.all(
                color: iconColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
