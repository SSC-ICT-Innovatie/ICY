part of 'marketplace_bloc.dart';

abstract class MarketplaceEvent extends Equatable {
  const MarketplaceEvent();

  @override
  List<Object?> get props => [];
}

class LoadMarketplace extends MarketplaceEvent {
  final String? categoryId;

  const LoadMarketplace({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class ChangeCategory extends MarketplaceEvent {
  final String categoryId;

  const ChangeCategory({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class PurchaseItem extends MarketplaceEvent {
  final String itemId;

  const PurchaseItem({required this.itemId});

  @override
  List<Object?> get props => [itemId];
}
