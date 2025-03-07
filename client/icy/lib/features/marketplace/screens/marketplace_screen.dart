import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/marketplace/bloc/marketplace_bloc.dart';
import 'package:icy/features/marketplace/widgets/item_card.dart';
import 'package:icy/features/marketplace/widgets/purchase_history_tab.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load marketplace data when screen is initialized
    context.read<MarketplaceBloc>().add(const LoadMarketplace());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader(title: const Text('Marketplace')),
      content: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthSuccess) {
            return const Center(
              child: Text(
                'Je moet ingelogd zijn om de marketplace te gebruiken',
              ),
            );
          }

          final user = authState.user;
          final coins = user.stats?.totalCoins ?? 0;

          return Material(
            type: MaterialType.transparency,
            child: BlocConsumer<MarketplaceBloc, MarketplaceState>(
              listener: (context, state) {
                if (state is MarketplaceError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is MarketplacePurchaseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is MarketplaceInitial ||
                    state is MarketplaceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is MarketplaceLoaded) {
                  return Column(
                    children: [
                      // Coins display
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.yellow.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.monetization_on, color: Colors.yellow),
                            const SizedBox(width: 4),
                            Text(
                              '$coins munten',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tab bar
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Winkel'),
                          Tab(text: 'Mijn Aankopen'),
                        ],
                      ),

                      // Tab content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Store tab
                            _buildStoreTab(state),

                            // Purchases tab
                            PurchaseHistoryTab(purchases: state.userPurchases),
                          ],
                        ),
                      ),
                    ],
                  );
                }

                return const Center(
                  child: Text('Er ging iets mis. Probeer het later opnieuw.'),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreTab(MarketplaceLoaded state) {
    return Column(
      children: [
        // Categories
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children:
                state.categories.map((category) {
                  final isSelected = category.id == state.selectedCategoryId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category.name),
                      selected: isSelected,
                      onSelected: (_) {
                        context.read<MarketplaceBloc>().add(
                          ChangeCategory(categoryId: category.id),
                        );
                      },
                    ),
                  );
                }).toList(),
          ),
        ),

        // Items
        Expanded(
          child:
              state.filteredItems.isEmpty
                  ? const Center(
                    child: Text('Geen items gevonden in deze categorie'),
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: state.filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = state.filteredItems[index];
                      return MarketplaceItemCard(
                        item: item,
                        onTap: () => _showItemDetails(context, item),
                      );
                    },
                  ),
        ),
      ],
    );
  }

  void _showItemDetails(BuildContext context, MarketplaceItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Item image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.image,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              // Item details
              Text(item.name, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              Text(item.description),
              const SizedBox(height: 16),

              // Price
              Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.yellow),
                  const SizedBox(width: 8),
                  Text(
                    '${item.price} munten',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Additional info
              if (item.quantity != null)
                Text('Beschikbare voorraad: ${item.quantity}'),
              if (item.expiryDays != null)
                Text('Verloopt na: ${item.expiryDays} dagen'),
              if (item.permanent == true) const Text('Permanent item'),
              if (item.approvalRequired == true)
                const Text('Goedkeuring vereist na aankoop'),
              const SizedBox(height: 16),

              // Purchase button
              FButton(
                onPress: () {
                  if (item.available) {
                    Navigator.of(context).pop();
                    context.read<MarketplaceBloc>().add(
                      PurchaseItem(itemId: item.id),
                    );
                  }
                },
                label: const Text('Kopen'),
                prefix: FIcon(FAssets.icons.shoppingCart),

                style:
                    item.available
                        ? FButtonStyle.primary
                        : FButtonStyle.secondary,
              ),
            ],
          ),
        );
      },
    );
  }
}
