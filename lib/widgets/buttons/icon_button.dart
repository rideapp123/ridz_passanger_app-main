import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CommonIconButton extends HookWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  const CommonIconButton({
    super.key,
    this.iconColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed, // Use the callback provided by the parent
      icon: Icon(
        icon, // Use the icon provided by the parent
        color: iconColor ??
            Theme.of(context).colorScheme.tertiary, // Styling using the theme
      ),
    );
  }
}
