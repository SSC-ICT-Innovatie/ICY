import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/widgets/modal_wrapper.dart';
import 'package:icy/data/models/marketplace_model.dart';

class MarketplaceItemDetail extends StatelessWidget {
  final MarketplaceItem item;
  final bool alreadyPurchased;
  final VoidCallback onPurchase;

  const MarketplaceItemDetail({
    super.key,
    required this.item,
    required this.alreadyPurchased,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FTheme.of(context);

    return ModalWrapper(
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar for bottom sheet
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
      
            // Item image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        color: theme.colorScheme.muted,
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 40),
                        ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 16),
      
            // Item details
            Text(
              item.name,
              style: theme.typography.xl2.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  '${item.price} Coins',
                  style: theme.typography.lg.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (item.permanent == true) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Permanent',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ] else if (item.expiryDays != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Valid for ${item.expiryDays} days',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
      
            // Description
            Text(
              'Description',
              style: theme.typography.lg.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(item.description, style: theme.typography.base),
      
            const SizedBox(height: 24),
      
            // Purchase button or status
            if (alreadyPurchased) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Already Purchased',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (!item.available) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.do_not_disturb, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Currently Unavailable',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              FButton(
                onPress: onPurchase,
                style: FButtonStyle.primary,
                label: const Text(
                  'Purchase Item',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
      
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
