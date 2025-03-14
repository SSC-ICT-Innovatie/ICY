import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/features/marketplace/repository/marketplace_repository.dart';
import 'package:icy/abstractions/utils/network_util.dart';

part 'marketplace_event.dart';
part 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository _marketplaceRepository;

  MarketplaceBloc({required MarketplaceRepository marketplaceRepository})
    : _marketplaceRepository = marketplaceRepository,
      super(MarketplaceInitial()) {
    on<LoadMarketplace>(_onLoadMarketplace);
    on<ChangeCategory>(_onChangeCategory);
    on<PurchaseItem>(_onPurchaseItem);
  }

  Future<void> _onLoadMarketplace(
    LoadMarketplace event,
    Emitter<MarketplaceState> emit,
  ) async {
    emit(MarketplaceLoading());
    try {
      // First check network connectivity
      final hasConnection = await NetworkUtil.isApiAvailable();

      if (!hasConnection) {
        emit(
          MarketplaceError(
            message:
                'No network connection. Please check your connection and try again.',
          ),
        );
        return;
      }

      // Get categories
      final categories = await _marketplaceRepository.getCategories();

      if (categories.isEmpty) {
        emit(
          MarketplaceError(
            message: 'Unable to load marketplace data. Please try again later.',
          ),
        );
        return;
      }

      // Select the first category by default
      final firstCategoryId = categories.isNotEmpty ? categories.first.id : '';

      // Get items for the category
      final items = await _marketplaceRepository.getItems();

      // Filter items by category
      final filteredItems =
          items.where((item) => item.categoryId == firstCategoryId).toList();

      // Get featured items
      final featuredItems = items.where((item) => item.featured).toList();

      // Get user purchases
      final userPurchases = await _marketplaceRepository.getUserPurchases();

      emit(
        MarketplaceLoaded(
          categories: categories,
          items: items,
          filteredItems: filteredItems,
          featuredItems: featuredItems,
          selectedCategoryId: firstCategoryId,
          userPurchases: userPurchases,
        ),
      );
    } catch (error) {
      emit(
        MarketplaceError(message: 'Something went wrong: ${error.toString()}'),
      );
    }
  }

  void _onChangeCategory(ChangeCategory event, Emitter<MarketplaceState> emit) {
    if (state is MarketplaceLoaded) {
      final currentState = state as MarketplaceLoaded;

      // Filter items by selected category
      final filteredItems =
          currentState.items
              .where((item) => item.categoryId == event.categoryId)
              .toList();

      emit(
        MarketplaceLoaded(
          categories: currentState.categories,
          items: currentState.items,
          filteredItems: filteredItems,
          featuredItems: currentState.featuredItems,
          selectedCategoryId: event.categoryId,
          userPurchases: currentState.userPurchases,
        ),
      );
    }
  }

  Future<void> _onPurchaseItem(
    PurchaseItem event,
    Emitter<MarketplaceState> emit,
  ) async {
    if (state is MarketplaceLoaded) {
      // First set purchasing state
      emit(MarketplacePurchasing());

      try {
        // Purchase item via repository
        final success = await _marketplaceRepository.purchaseItem(event.itemId);

        if (success) {
          // Reload marketplace data to get updated items and user purchases
          add(const LoadMarketplace());
        } else {
          emit(
            MarketplaceError(
              message: 'Failed to purchase item. Please try again.',
            ),
          );
        }
      } catch (error) {
        emit(
          MarketplaceError(
            message: 'Error purchasing item: ${error.toString()}',
          ),
        );
      }
    }
  }
}
