import 'package:flutter/material.dart';
import 'package:icy/data/models/marketplace_model.dart';

class MarketplaceItemCard extends StatelessWidget {
  final MarketplaceItem item;
  final VoidCallback onTap;

  const MarketplaceItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.available ? onTap : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.2,
                  child: Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, size: 40),
                          ),
                        ),
                  ),
                ),
                if (!item.available)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Text(
                          'SOLD OUT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // Item details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
