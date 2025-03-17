import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/services/api_service.dart';

class MarketplaceRepository {
  final ApiService _apiService;

  MarketplaceRepository({
    ApiService? apiService,
    LocalStorageService? localStorageService,
  }) : _apiService = apiService ?? ApiService();

  // Get marketplace data (categories and items)
  Future<MarketplaceData> getMarketplaceData() async {
    try {
      // Get categories from API
      final categoriesResponse = await _apiService.get(
        ApiConstants.marketplaceCategoriesEndpoint,
      );
      final List<MarketplaceCategory> categories =
          (categoriesResponse['data'] as List)
              .map((categoryJson) => MarketplaceCategory.fromJson(categoryJson))
              .toList();

      // Get all items from API
      final itemsResponse = await _apiService.get(
        ApiConstants.marketplaceItemsEndpoint,
      );
      final List<MarketplaceItem> items =
          (itemsResponse['data'] as List)
              .map((itemJson) => MarketplaceItem.fromJson(itemJson))
              .toList();

      // Get user's purchase history
      final purchasesResponse = await _apiService.get(
        ApiConstants.marketplacePurchasesEndpoint,
      );
      final List<PurchaseHistoryItem> purchases =
          (purchasesResponse['data'] as List)
              .map((purchaseJson) => PurchaseHistoryItem.fromJson(purchaseJson))
              .toList();

      return MarketplaceData(
        categories: categories,
        items: items,
        purchaseHistory: purchases,
      );
    } catch (e) {
      print('Error loading marketplace data: $e');
      return MarketplaceData(categories: [], items: [], purchaseHistory: []);
    }
  }

  // Get user's purchase history
  Future<List<PurchaseHistoryItem>> getUserPurchases() async {
    try {
      final response = await _apiService.get(
        ApiConstants.marketplacePurchasesEndpoint,
      );
      return (response['data'] as List)
          .map((purchaseJson) => PurchaseHistoryItem.fromJson(purchaseJson))
          .toList();
    } catch (e) {
      print('Error getting user purchases: $e');
      return [];
    }
  }

  // Purchase an item
  Future<bool> purchaseItem(String itemId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.marketplaceItemsEndpoint}/$itemId/purchase',
        {},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error purchasing item: $e');
      return false;
    }
  }

  // Redeem a purchase
  Future<bool> redeemPurchase(String purchaseId) async {
    try {
      final response = await _apiService.post(
        '${ApiConstants.marketplacePurchasesEndpoint}/$purchaseId/redeem',
        {},
      );

      return response['success'] == true;
    } catch (e) {
      print('Error redeeming purchase: $e');
      return false;
    }
  }
}
