part of 'marketplace_bloc.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class MarketplaceLoaded extends MarketplaceState {
  final List<MarketplaceCategory> categories;
  final List<MarketplaceItem> items;
  final List<MarketplaceItem> filteredItems;
  final List<MarketplaceItem> featuredItems;
  final String selectedCategoryId;
  final List<PurchaseHistoryItem> userPurchases;

  const MarketplaceLoaded({
    required this.categories,
    required this.items,
    required this.filteredItems,
    required this.featuredItems,
    required this.selectedCategoryId,
    required this.userPurchases,
  });

  @override
  List<Object> get props => [
    categories,
    items,
    filteredItems,
    featuredItems,
    selectedCategoryId,
    userPurchases,
  ];
}

class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError({required this.message});

  @override
  List<Object> get props => [message];
}

class MarketplacePurchasing extends MarketplaceState {}

// Update the props method here to return List<Object> instead of List<Object?>
class MarketplacePurchaseError extends MarketplaceState {
  final String message;

  const MarketplacePurchaseError({required this.message});

  @override
  List<Object> get props => [message]; // Change from List<Object?> to List<Object>
}
