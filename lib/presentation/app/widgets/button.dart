import 'package:flutter/material.dart';

class AnimatedButton extends StatelessWidget {
  final isPressed = ValueNotifier<bool>(false);
  final Color onPressedColor, color;
  final VoidCallback? onPressed;
  final Widget content;
  AnimatedButton(
      {super.key,
      required this.content,
      this.onPressed,
      this.onPressedColor = Colors.white38,
      this.color = Colors.white12});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isPressed,
      builder: (context, pressed, child) {
        return AnimatedScale(
          scale: pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.all(5),
            color: pressed ? onPressedColor : color,
            child: InkWell(
              onTap: () {
                if (onPressed != null) {
                  onPressed!();
                }
              },
              onTapDown: (_) {
                isPressed.value = true;
              },
              onTapUp: (_) {
                isPressed.value = false;
              },
              onTapCancel: () {
                isPressed.value = false;
              },
              child: Center(
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}
