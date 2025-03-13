import 'package:flutter/material.dart';
import 'package:forui/forui.dart'; // Add ForUI import
import 'package:icy/data/models/marketplace_model.dart';

class MarketplaceCategorySelector extends StatelessWidget {
  final List<MarketplaceCategory> categories;
  final String selectedCategoryId;
  final Function(String) onCategorySelected;

  const MarketplaceCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            categories.map((category) {
              final isSelected = category.id == selectedCategoryId;
              return Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: _buildCategoryChip(context, category, isSelected),
              );
            }).toList(),
      ),
    );
  }

  // Create a custom chip that doesn't require Material widget
  Widget _buildCategoryChip(
    BuildContext context,
    MarketplaceCategory category,
    bool isSelected,
  ) {
    final theme = FTheme.of(context);

    return GestureDetector(
      onTap: () => onCategorySelected(category.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? theme.colorScheme.primary.withOpacity(0.2)
                  : theme.colorScheme.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getIconForName(category.icon),
              size: 18,
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.mutedForeground,
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color:
                    isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.foreground,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to convert string icon names to IconData
  IconData _getIconForName(String iconName) {
    // Map common icon names to their corresponding IconData
    switch (iconName) {
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'face':
        return Icons.face;
      case 'palette':
        return Icons.palette;
      case 'business':
        return Icons.business;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'star':
        return Icons.star;
      case 'redeem':
        return Icons.redeem;
      case 'local_offer':
        return Icons.local_offer;
      default:
        return Icons.category;
    }
  }
}
