import 'package:icy/abstractions/utils/api_constants.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/features/marketplace/repository/marketplace_repository.dart';
import 'package:icy/services/api_service.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final ApiService _apiService;

  MarketplaceRepositoryImpl({required ApiService apiService})
    : _apiService = apiService;

  @override
  Future<List<MarketplaceCategory>> getCategories() async {
    try {
      final response = await _apiService.get(
        ApiConstants.marketplaceCategoriesEndpoint,
      );

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((categoryJson) => MarketplaceCategory.fromJson(categoryJson))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  @override
  Future<List<MarketplaceItem>> getItems({
    String? categoryId,
    bool? featured,
  }) async {
    try {
      String endpoint = ApiConstants.marketplaceItemsEndpoint;

      // Add query parameters if needed
      if (categoryId != null || featured != null) {
        endpoint += '?';
        if (categoryId != null) {
          endpoint += 'categoryId=$categoryId';
          if (featured != null) endpoint += '&';
        }
        if (featured != null) endpoint += 'featured=$featured';
      }

      final response = await _apiService.get(endpoint);

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((itemJson) => MarketplaceItem.fromJson(itemJson))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching items: $e');
      return [];
    }
  }

  @override
  Future<List<PurchaseHistoryItem>> getUserPurchases() async {
    try {
      final response = await _apiService.get(
        ApiConstants.marketplacePurchasesEndpoint,
      );

      if (response['success'] == true && response['data'] != null) {
        return (response['data'] as List)
            .map((purchaseJson) => PurchaseHistoryItem.fromJson(purchaseJson))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching user purchases: $e');
      return [];
    }
  }

  @override
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

  @override
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
