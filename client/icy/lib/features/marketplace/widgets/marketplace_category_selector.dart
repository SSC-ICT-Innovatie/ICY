import 'package:flutter/material.dart';
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
                child: FilterChip(
                  selectedColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.2),
                  backgroundColor: Theme.of(context).cardColor,
                  checkmarkColor: Theme.of(context).primaryColor,
                  label: Row(
                    children: [
                      Icon(
                        IconData(
                          int.parse(
                            '0xe${category.icon.substring(0, 3)}',
                            radix: 16,
                          ),
                          fontFamily: 'MaterialIcons',
                        ),
                        size: 18,
                        color:
                            isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Theme.of(context).primaryColor
                                  : null,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => onCategorySelected(category.id),
                ),
              );
            }).toList(),
      ),
    );
  }
}
