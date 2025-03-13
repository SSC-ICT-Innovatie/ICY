import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/marketplace/bloc/marketplace_bloc.dart';
import 'package:icy/features/marketplace/widgets/marketplace_category_selector.dart';
import 'package:icy/features/marketplace/widgets/marketplace_featured_items.dart';
import 'package:icy/features/marketplace/widgets/marketplace_item_card.dart';
import 'package:icy/features/marketplace/widgets/marketplace_item_detail.dart';
import 'package:icy/features/marketplace/widgets/user_coins_display.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(
        title: const Text('Marketplace'),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthSuccess) {
                return UserCoinsDisplay(
                  coins: state.user.stats?.totalCoins ?? 0,
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      content: BlocBuilder<MarketplaceBloc, MarketplaceState>(
        builder: (context, state) {
          if (state is MarketplaceInitial) {
            // Trigger loading of marketplace data
            context.read<MarketplaceBloc>().add(const LoadMarketplace());
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is MarketplaceLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (state is MarketplaceError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  FButton(
                    onPress: () {
                      context.read<MarketplaceBloc>().add(
                        const LoadMarketplace(),
                      );
                    },
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (state is MarketplacePurchasing) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator.adaptive(),
                  SizedBox(height: 16),
                  Text('Processing your purchase...'),
                ],
              ),
            );
          }

          if (state is MarketplaceLoaded) {
            return _buildMarketplaceContent(context, state);
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }

  Widget _buildMarketplaceContent(
    BuildContext context,
    MarketplaceLoaded state,
  ) {
    final theme = FTheme.of(context);

    return RefreshIndicator.adaptive(
      onRefresh: () async {
        context.read<MarketplaceBloc>().add(const LoadMarketplace());
      },
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MarketplaceCategorySelector(
                categories: state.categories,
                selectedCategoryId: state.selectedCategoryId,
                onCategorySelected: (categoryId) {
                  context.read<MarketplaceBloc>().add(
                    ChangeCategory(categoryId: categoryId),
                  );
                },
              ),
            ),
          ),

          // Featured items section
          if (state.featuredItems.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0),
                child: Text(
                  'Featured',
                  style: theme.typography.xl.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MarketplaceFeaturedItems(
                featuredItems: state.featuredItems,
                onItemTap:
                    (item) =>
                        _showItemDetail(context, item, state.userPurchases),
              ),
            ),
          ],

          // Category items grid
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
              child: Text(
                state.categories
                    .firstWhere((c) => c.id == state.selectedCategoryId)
                    .name,
                style: theme.typography.xl.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver:
                state.filteredItems.isEmpty
                    ? SliverToBoxAdapter(
                      child: Center(
                        child: Column(
                          children: [
                            const SizedBox(height: 40),
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: theme.colorScheme.mutedForeground,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No items available in this category',
                              style: theme.typography.base,
                            ),
                          ],
                        ),
                      ),
                    )
                    : SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,
                          ),
                      delegate: SliverChildBuilderDelegate((
                        BuildContext context,
                        int index,
                      ) {
                        final item = state.filteredItems[index];
                        return MarketplaceItemCard(
                          item: item,
                          onTap:
                              () => _showItemDetail(
                                context,
                                item,
                                state.userPurchases,
                              ),
                        );
                      }, childCount: state.filteredItems.length),
                    ),
          ),
        ],
      ),
    );
  }

  void _showItemDetail(
    BuildContext context,
    MarketplaceItem item,
    List<PurchaseHistoryItem> purchases,
  ) {
    // Check if user already purchased this item
    final alreadyPurchased = purchases.any(
      (purchase) =>
          purchase.itemId == item.id &&
          (purchase.permanent == true ||
              (purchase.expiryDate != null &&
                  DateTime.parse(
                    purchase.expiryDate!,
                  ).isAfter(DateTime.now()))),
    );

    if (!Platform.isIOS) {
      showDialog(
        context: context,
        builder:
            (context) => MarketplaceItemDetail(
              item: item,
              alreadyPurchased: alreadyPurchased,
              onPurchase: () {
                Navigator.pop(context);
                context.read<MarketplaceBloc>().add(
                  PurchaseItem(itemId: item.id),
                );
              },
            ),
      );
    } else {
      showCupertinoSheet(
        context: context,
        pageBuilder:
            (context) => MarketplaceItemDetail(
              item: item,
              alreadyPurchased: alreadyPurchased,
              onPurchase: () {
                Navigator.pop(context);
                context.read<MarketplaceBloc>().add(
                  PurchaseItem(itemId: item.id),
                );
              },
            ),
      );
    }
  }
}
