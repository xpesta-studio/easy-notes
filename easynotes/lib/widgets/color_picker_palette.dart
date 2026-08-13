import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class ColorPickerPalette extends StatelessWidget {
  final int selectedColorIndex;
  final ValueChanged<int> onColorSelected;

  const ColorPickerPalette({
    super.key,
    required this.selectedColorIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorList = isDark ? AppColors.noteColorsDark : AppColors.noteColorsLight;
    final borderList = isDark ? AppColors.noteBorderColorsDark : AppColors.noteBorderColorsLight;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: colorList.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = selectedColorIndex == index;
          return GestureDetector(
            onTap: () => onColorSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorList[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : borderList[index],
                  width: isSelected ? 2.5 : 1.2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 20,
                      color: isDark ? Colors.white : Colors.black87,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}