import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:intl/intl.dart';

class PurchaseHistoryTab extends StatelessWidget {
  final List<PurchaseHistoryItem> purchases;

  const PurchaseHistoryTab({Key? key, required this.purchases})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (purchases.isEmpty) {
      return const Center(child: Text('Je hebt nog geen aankopen gedaan'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: purchases.length,
      itemBuilder: (context, index) {
        final purchase = purchases[index];
        return _buildPurchaseItem(purchase, context);
      },
    );
  }

  Widget _buildPurchaseItem(
    PurchaseHistoryItem purchase,
    BuildContext context,
  ) {
    final formatter = DateFormat('dd-MM-yyyy');
    final purchaseDate = DateTime.parse(purchase.purchaseDate);
    final formattedDate = formatter.format(purchaseDate);

    final bool isExpired =
        purchase.expiryDate != null &&
        DateTime.parse(purchase.expiryDate!).isBefore(DateTime.now());

    // Get display name - either from the name property or fallback to item ID
    final displayName = purchase.name ?? 'Item ${purchase.itemId}';

    return FTile(
      title: Text(
        purchase.permanent == true ? '$displayName (Permanent)' : displayName,
      ),
      prefixIcon:
          purchase.used == true || isExpired
              ? const Icon(Icons.check_circle, color: Colors.grey)
              : Icon(
                Icons.card_giftcard,
                color: context.theme.colorScheme.primary,
              ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gekocht op: $formattedDate'),
          if (purchase.expiryDate != null) ...[
            Text(
              'Geldig tot: ${formatter.format(DateTime.parse(purchase.expiryDate!))}',
              style: TextStyle(color: isExpired ? Colors.red : null),
            ),
          ],
          if (purchase.redeemCode != null) Text('Code: ${purchase.redeemCode}'),

          // Status badge
          const SizedBox(height: 4),
          _buildStatusBadge(purchase, isExpired),
        ],
      ),
      suffixIcon:
          purchase.used == true || isExpired
              ? null
              : FButton(
                style: FButtonStyle.ghost,
                onPress: () {
                  // In a real app, this would redeem the purchase
                },
                label: const Text('Gebruik'),
              ),
    );
  }

  Widget _buildStatusBadge(PurchaseHistoryItem purchase, bool isExpired) {
    if (isExpired) {
      return _buildBadge('Verlopen', Colors.grey);
    }

    if (purchase.used == true) {
      return _buildBadge('Gebruikt', Colors.grey);
    }

    if (purchase.status == 'active') {
      return _buildBadge('Actief', Colors.green);
    }

    return const SizedBox.shrink();
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color)),
    );
  }
}
