import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gameboy/blocs/game/bloc.dart';
import 'package:gameboy/blocs/game/events.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? contentWidth;
  final Game game;
  final double height;

  @override
  Size get preferredSize => Size.fromHeight(height);

  const GameAppBar({
    super.key,
    this.contentWidth,
    required this.game,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final gameColor = GameColors.getPrimaryColor(game.name);

    // Distinct app bar colors for game page
    final appBarBackground = isDark
        ? const Color(0xFF1A1A2E) // Deep navy for dark mode
        : Colors.white;
    final controlBackground = isDark
        ? const Color(0xFF2D2D44) // Slightly lighter for controls
        : const Color(0xFFF0F0F5);
    final iconColor = isDark ? gameColor : gameColor;

    return Container(
      height: height,
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
            color: gameColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Close button
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _GameAppBarButton(
                    icon: Icons.close_rounded,
                    onPressed: () => Navigator.pop(context),
                    controlBackground: controlBackground,
                    iconColor: iconColor,
                  ),
                ),
                // Game logo and name
                _buildGameLogo(context, gameColor),
                // Action buttons
                _createActionButtonBar(context, controlBackground, iconColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _createActionButtonBar(
    BuildContext context,
    Color controlBackground,
    Color iconColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: _GameAppBarButton(
            icon: Icons.help_outline_rounded,
            onPressed: () {
              BlocProvider.of<GameBloc>(context).add(RequestTutorial());
            },
            controlBackground: controlBackground,
            iconColor: iconColor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: _GameAppBarButton(
            icon: Icons.bar_chart_rounded,
            onPressed: () {
              BlocProvider.of<GameBloc>(context).add(RequestStats());
            },
            controlBackground: controlBackground,
            iconColor: iconColor,
          ),
        ),
      ],
    );
  }

  Widget _buildGameLogo(BuildContext context, Color gameColor) {
    final theme = Theme.of(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: gameColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: ClipOval(
            child:
                game.imageAsset.image(width: 40, height: 40, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          game.name.toUpperCase(),
          style: theme.textTheme.titleLarge?.copyWith(
            color: gameColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _GameAppBarButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color controlBackground;
  final Color iconColor;

  const _GameAppBarButton({
    required this.icon,
    required this.onPressed,
    required this.controlBackground,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: controlBackground,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
