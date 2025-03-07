import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forui/forui.dart';
import 'package:icy/abstractions/navigation/widgets/modal_wrapper.dart';
import 'package:icy/core/utils/widget_utils.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';
import 'package:icy/features/marketplace/bloc/marketplace_bloc.dart';
import 'package:icy/features/marketplace/widgets/purchase_history_tab.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    // Load marketplace data when screen is initialized
    context.read<MarketplaceBloc>().add(const LoadMarketplace());
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

          return BlocConsumer<MarketplaceBloc, MarketplaceState>(
            listener: (context, state) {
              if (state is MarketplaceError) {
                // Use FAlert instead of FToast
                showDialog(
                  context: context,
                  builder:
                      (context) => FDialog(
                        title: const Text('Error'),
                        body: FAlert(
                          style: FAlertStyle.destructive,
                          title: Text(state.message),
                        ),
                        actions: [
                          FButton(
                            onPress: () => Navigator.pop(context),
                            label: const Text('OK'),
                          ),
                        ],
                      ),
                );
              } else if (state is MarketplacePurchaseError) {
                showDialog(
                  context: context,
                  builder:
                      (context) => FDialog(
                        title: const Text('Purchase Error'),
                        body: FAlert(
                          style: FAlertStyle.destructive,
                          title: Text(state.message),
                        ),
                        actions: [
                          FButton(
                            onPress: () => Navigator.pop(context),
                            label: const Text('OK'),
                          ),
                        ],
                      ),
                );
              }
            },
            builder: (context, state) {
              if (state is MarketplaceInitial || state is MarketplaceLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is MarketplaceLoaded) {
                return Column(
                  children: [
                    // Coins display
                    FButton(
                      onPress: () {},
                      style: FButtonStyle.outline,
                      prefix: const Icon(
                        Icons.monetization_on,
                        color: Colors.yellow,
                      ),
                      label: Text(
                        '$coins munten',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),

                    // Use FTabs instead of TabBar/TabBarView
                    Expanded(
                      child: FTabs(
                        tabs: [
                          FTabEntry(
                            label: const Text('Winkel'),
                            content: _buildStoreTab(state),
                          ),
                          FTabEntry(
                            label: const Text('Mijn Aankopen'),
                            content: WidgetUtils.safeHeight(
                              PurchaseHistoryTab(
                                purchases: state.userPurchases,
                              ),
                              height: 400,
                            ),
                          ),
                        ],
                        initialIndex: 0,
                      ),
                    ),
                  ],
                );
              }

              return const Center(
                child: Text('Er ging iets mis. Probeer het later opnieuw.'),
              );
            },
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
                    child: FButton(
                      style:
                          isSelected
                              ? FButtonStyle.primary
                              : FButtonStyle.secondary,
                      label: Text(category.name),
                      onPress: () {
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
                      return _buildMarketplaceCard(item);
                    },
                  ),
        ),
      ],
    );
  }

  // Convert to FCard
  Widget _buildMarketplaceCard(MarketplaceItem item) {
    return FTile(
      onPress: () => _showItemDetails(context, item),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item.image,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(child: Icon(Icons.broken_image)),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.monetization_on, color: Colors.yellow, size: 16),
              const SizedBox(width: 4),
              Text(item.price.toString()),
            ],
          ),
        ],
      ),
    );
  }

  void _showItemDetails(BuildContext context, MarketplaceItem item) {
    showCupertinoModalPopup(
      context: context,
      builder:
          (context) => ModalWrapper(
            body: Column(
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
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey.shade300,
                        child: const Center(child: Icon(Icons.broken_image)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(item.description),
                const SizedBox(height: 16),

                // Price
                Row(
                  children: [
                    const Icon(Icons.monetization_on, color: Colors.yellow),
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

                Row(
                  children: [
                    FButton(
                      onPress: () {
                        Navigator.of(context).pop();
                      },
                      label: const Text('Annuleren'),
                      style: FButtonStyle.outline,
                    ),
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
              ],
            ),
          ),
    );
  }
}
