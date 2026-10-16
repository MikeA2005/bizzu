import 'package:bizzu/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final IconData? leadingIcon;
  final void Function()? leadingOnPressed;
  final String title;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.leadingIcon,
    this.leadingOnPressed,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // If leadingIcon is provided, show an IconButton, otherwise null
      leading: leadingIcon != null
          ? IconButton(
              icon: Icon(leadingIcon),
              color: AppColors.textPrimaryLight,
              onPressed: leadingOnPressed,
            )
          : null,
      // Title with custom text style
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
      // Transparent background and no elevation
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
