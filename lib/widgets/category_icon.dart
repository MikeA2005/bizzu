import 'package:flutter/material.dart';
import 'package:bizzu/theme/app_colors.dart';

class CategoryIcon extends StatelessWidget {
  final String name;
  final IconData iconData;

  const CategoryIcon({
    super.key,
    required this.name,
    this.iconData = Icons.category,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CircleAvatar with a white background and red icon
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.surfaceLight,
          child: Icon(iconData, color: AppColors.primary),
        ),
        // Spacer to add some space between the icon and the text
        const SizedBox(height: 8),
        // Text widget to display the title with black color and font size 12
        Text(
          name,
          style: const TextStyle(
            color: AppColors.textPrimaryLight,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
