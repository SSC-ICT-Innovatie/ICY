import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/data/repositories/marketplace_repository.dart';
import 'package:icy/features/authentication/state/bloc/auth_bloc.dart';

part 'marketplace_event.dart';
part 'marketplace_state.dart';

class MarketplaceBloc extends Bloc<MarketplaceEvent, MarketplaceState> {
  final MarketplaceRepository _marketplaceRepository;
  final AuthBloc _authBloc;

  MarketplaceBloc({
    required MarketplaceRepository marketplaceRepository,
    required AuthBloc authBloc,
  }) : _marketplaceRepository = marketplaceRepository,
       _authBloc = authBloc,
       super(MarketplaceInitial()) {
    // Load marketplace data
    on<LoadMarketplace>((event, emit) async {
      emit(MarketplaceLoading());
      try {
        final marketplaceData =
            await _marketplaceRepository.getMarketplaceData();

        // Get user purchases if logged in
        List<PurchaseHistoryItem> userPurchases = [];
        if (_authBloc.state is AuthSuccess) {
          final userId = (_authBloc.state as AuthSuccess).user.id;
          userPurchases = await _marketplaceRepository.getUserPurchases(userId);
        }

        emit(
          MarketplaceLoaded(
            categories: marketplaceData.categories,
            items: marketplaceData.items,
            userPurchases: userPurchases,
            selectedCategoryId:
                event.categoryId ?? marketplaceData.categories.first.id,
          ),
        );
      } catch (e) {
        emit(MarketplaceError(message: 'Failed to load marketplace: $e'));
      }
    });

    // Change category
    on<ChangeCategory>((event, emit) {
      if (state is MarketplaceLoaded) {
        final currentState = state as MarketplaceLoaded;
        emit(currentState.copyWith(selectedCategoryId: event.categoryId));
      }
    });

    // Purchase item
    on<PurchaseItem>((event, emit) async {
      if (state is MarketplaceLoaded && _authBloc.state is AuthSuccess) {
        emit(MarketplacePurchasing());

        try {
          final userId = (_authBloc.state as AuthSuccess).user.id;
          final success = await _marketplaceRepository.purchaseItem(
            userId,
            event.itemId,
          );

          if (success) {
            // Reload marketplace data after purchase
            add(LoadMarketplace());
          } else {
            emit(
              MarketplacePurchaseError(
                message: 'Purchase failed. Insufficient coins.',
              ),
            );
            // Go back to loaded state after error
            add(LoadMarketplace());
          }
        } catch (e) {
          emit(MarketplaceError(message: 'Purchase error: $e'));
        }
      }
    });
  }
}
