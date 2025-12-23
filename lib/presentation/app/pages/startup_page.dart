import 'dart:math' as math;
import 'dart:ui'; // Required for ImageFilter

import 'package:flutter/material.dart';
import 'package:gameboy/asset_manager/assets.gen.dart';
import 'package:gameboy/blocs/app/events.dart';
import 'package:gameboy/blocs/bloc_extensions.dart';
import 'package:gameboy/data/app/models/game.dart';
import 'package:gameboy/presentation/app/extensions.dart';
import 'package:gameboy/presentation/app/theming/app_colors.dart';

class _BackgroundLetterData {
  final String char;
  final double xPosRatio;
  final double yPosRatio;
  final double rotation;
  final double size;
  final double opacity;

  const _BackgroundLetterData({
    required this.char,
    required this.xPosRatio,
    required this.yPosRatio,
    required this.rotation,
    required this.size,
    required this.opacity,
  });
}

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final List<_BackgroundLetterData> _backgroundLetters = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _generateBackgroundLetters();
  }

  void _generateBackgroundLetters() {
    const String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    for (int i = 0; i < 50; i++) {
      _backgroundLetters.add(_BackgroundLetterData(
        char: chars[_random.nextInt(chars.length)],
        xPosRatio: _random.nextDouble(),
        yPosRatio: _random.nextDouble(),
        rotation: _random.nextDouble() - 0.5,
        size: _random.nextDouble() * 110 + 40,
        opacity: _random.nextDouble() * 0.10 + 0.05,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ScatteredLettersBackground(letters: _backgroundLetters),
          LayoutBuilder(
            builder: (context, constraints) {
              bool isDesktop = constraints.maxWidth > 900;
              if (isDesktop) {
                return _buildDesktopLayout(constraints);
              } else {
                return _buildMobileLayout(constraints);
              }
            },
          ),
        ],
      ),
    );
  }

  // --- DESKTOP LAYOUT ---
  Widget _buildDesktopLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppLogo(fontSize: 60),
                const Spacer(),
                _buildHeroHeadline(context, fontSize: 80),
                const SizedBox(height: 24),
                _buildHeroSubtitle(context, fontSize: 20),
                const SizedBox(height: 48),
                const GoogleSignInButton(scale: 1.2),
                const Spacer(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Center(
              child: SizedBox(
                height: 400,
                child: _GamesListView(cardWidth: 280, cardHeight: 350),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MOBILE LAYOUT ---
  Widget _buildMobileLayout(BoxConstraints constraints) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppLogo(fontSize: 40),
            const Spacer(),
            _buildHeroHeadline(context, fontSize: 42),
            const SizedBox(height: 16),
            _buildHeroSubtitle(context, fontSize: 16),
            const SizedBox(height: 32),
            const Center(child: GoogleSignInButton(scale: 1.0)),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text("TRENDING GAMES",
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2)),
            ),
            const SizedBox(
              height: 230,
              child: _GamesListView(cardWidth: 140, cardHeight: 160),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeadline(BuildContext context, {required double fontSize}) {
    final theme = Theme.of(context);
    return Text(
      "PLAY\nSPELL\nCONQUER",
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w900,
        height: 0.95,
        color: theme.colorScheme.onSurface,
        shadows: [
          Shadow(
              color: AppColors.brandPrimary,
              offset: const Offset(4, 4),
              blurRadius: 10),
        ],
      ),
    );
  }

  Widget _buildHeroSubtitle(BuildContext context, {required double fontSize}) {
    final theme = Theme.of(context);
    return Text(
      "Compete, solve, and dominate the leaderboard.\nThe ultimate arcade for word puzzle lovers.",
      style: TextStyle(
        fontSize: fontSize,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        height: 1.5,
      ),
    );
  }
}

// --- THE NEW BACKGROUND WIDGET ---
class ScatteredLettersBackground extends StatelessWidget {
  final List<_BackgroundLetterData> letters;

  const ScatteredLettersBackground({super.key, required this.letters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Size screenSize = MediaQuery.of(context).size;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF0A0A0A),
                  const Color(0xFF121212),
                ]
              : [
                  const Color(0xFFF5F5F5),
                  const Color(0xFFE8E8E8),
                ],
        ),
      ),
      child: Stack(
        children: letters.map((data) {
          return Positioned(
            left: data.xPosRatio * screenSize.width,
            top: data.yPosRatio * screenSize.height,
            child: Transform.rotate(
              angle: data.rotation,
              child: Text(
                data.char,
                style: TextStyle(
                  fontSize: data.size,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: data.opacity),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GamesListView extends StatelessWidget {
  final double cardWidth;
  final double cardHeight;

  const _GamesListView({required this.cardWidth, required this.cardHeight});

  @override
  Widget build(BuildContext context) {
    final games = context.getAppData().games.toList();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];

        return GlassGameCard(
          game: game,
          description: game.description,
          width: cardWidth,
          height: cardHeight,
        );
      },
    );
  }
}

class GlassGameCard extends StatelessWidget {
  final Game game;
  final String description;
  final double width;
  final double height;

  const GlassGameCard({
    super.key,
    required this.game,
    required this.description,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gameColor = GameColors.getPrimaryColor(game.name);

    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Glass Blur Layer
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: gameColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _createGameLogoWithName(context, gameColor),
                  const Spacer(),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: width * 0.08,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createGameLogoWithName(BuildContext context, Color gameColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: ClipOval(
            child:
                game.imageAsset.image(width: 60, height: 60, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          game.name,
          style: TextStyle(
            fontSize: width * 0.12,
            fontWeight: FontWeight.bold,
            color: gameColor,
          ),
        ),
      ],
    );
  }
}

class GoogleSignInButton extends StatefulWidget {
  final double scale;
  const GoogleSignInButton({super.key, this.scale = 1.0});

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          transform: Matrix4.identity()
            ..scaleByDouble(
              _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
              _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
              _isPressed ? 0.95 : (_isHovered ? 1.02 : 1.0),
              1.0,
            ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.addMasterPageEvent(AuthenticateWithGoogle());
              },
              borderRadius: BorderRadius.circular(4),
              splashColor: const Color(0xFF4285F4).withValues(alpha: 0.1),
              highlightColor: const Color(0xFF4285F4).withValues(alpha: 0.05),
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 24 * widget.scale, vertical: 12 * widget.scale),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _isHovered || _isPressed
                        ? const Color(0xFF4285F4)
                        : const Color(0xFFDADCE0),
                    width: 1,
                  ),
                  boxShadow: [
                    if (_isHovered || _isPressed)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 18 * widget.scale,
                      height: 18 * widget.scale,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Assets.logos.google.image(
                        width: 18 * widget.scale,
                        height: 18 * widget.scale,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 24 * widget.scale),
                    Text(
                      "Sign in with Google",
                      style: TextStyle(
                        color: const Color(0xFF3C4043),
                        fontSize: 14 * widget.scale,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.25,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  final double fontSize;
  const AppLogo({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Assets.logos.app.image(
      height: fontSize * 2,
      width: fontSize * 2,
      fit: BoxFit.contain,
    );
  }
}
