import 'package:flutter/material.dart';

import '../theme/wish_colors.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.size = 44,
    this.iconSize = 21,
    this.background,
    this.foreground,
    this.borderColor,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? foreground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: iconSize),
      style: IconButton.styleFrom(
        backgroundColor: background ?? colors.surface,
        foregroundColor: foreground ?? colors.ink,
        disabledBackgroundColor: colors.surfaceMuted,
        disabledForegroundColor: colors.inkTertiary,
        side: BorderSide(color: borderColor ?? colors.border),
        minimumSize: Size.square(size),
        fixedSize: Size.square(size),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size * 0.32),
        ),
      ),
    );
  }
}
