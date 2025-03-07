part of 'marketplace_bloc.dart';

abstract class MarketplaceState extends Equatable {
  const MarketplaceState();

  @override
  List<Object?> get props => [];
}

class MarketplaceInitial extends MarketplaceState {}

class MarketplaceLoading extends MarketplaceState {}

class MarketplaceLoaded extends MarketplaceState {
  final List<MarketplaceCategory> categories;
  final List<MarketplaceItem> items;
  final List<PurchaseHistoryItem> userPurchases;
  final String selectedCategoryId;

  const MarketplaceLoaded({
    required this.categories,
    required this.items,
    required this.userPurchases,
    required this.selectedCategoryId,
  });

  List<MarketplaceItem> get filteredItems =>
      items.where((item) => item.categoryId == selectedCategoryId).toList();

  List<MarketplaceItem> get featuredItems =>
      items.where((item) => item.featured).toList();

  MarketplaceLoaded copyWith({
    List<MarketplaceCategory>? categories,
    List<MarketplaceItem>? items,
    List<PurchaseHistoryItem>? userPurchases,
    String? selectedCategoryId,
  }) {
    return MarketplaceLoaded(
      categories: categories ?? this.categories,
      items: items ?? this.items,
      userPurchases: userPurchases ?? this.userPurchases,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    items,
    userPurchases,
    selectedCategoryId,
  ];
}

class MarketplaceError extends MarketplaceState {
  final String message;

  const MarketplaceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MarketplacePurchasing extends MarketplaceState {}

class MarketplacePurchaseError extends MarketplaceState {
  final String message;

  const MarketplacePurchaseError({required this.message});

  @override
  List<Object?> get props => [message];
}
