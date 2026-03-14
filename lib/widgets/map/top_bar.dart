import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import 'filter_chip.dart';

class MapTopBar extends StatelessWidget {
  final VoidCallback onSearchPressed;
  final String? selectedFilter;
  final ValueChanged<String?> onFilterChanged;

  const MapTopBar({
    super.key,
    required this.onSearchPressed,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            HapticFeedback.mediumImpact();
            onSearchPressed();
          },
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.textDark, size: 26),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                MapFilterChip(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Shopping',
                  isSelected: selectedFilter == 'Shopping',
                  onTap: () => onFilterChanged('Shopping'),
                ),
                const SizedBox(width: 8),
                MapFilterChip(
                  icon: Icons.login_rounded,
                  label: 'Gates',
                  isSelected: selectedFilter == 'Gates',
                  onTap: () => onFilterChanged('Gates'),
                ),
                const SizedBox(width: 8),
                MapFilterChip(
                  icon: Icons.credit_card_rounded,
                  label: 'ATM',
                  isSelected: selectedFilter == 'ATM',
                  onTap: () => onFilterChanged('ATM'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
