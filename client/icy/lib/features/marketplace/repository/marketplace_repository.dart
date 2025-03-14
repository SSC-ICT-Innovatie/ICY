import 'package:icy/data/models/marketplace_model.dart';

abstract class MarketplaceRepository {
  Future<List<MarketplaceCategory>> getCategories();
  Future<List<MarketplaceItem>> getItems({String? categoryId, bool? featured});
  Future<List<PurchaseHistoryItem>> getUserPurchases();
  Future<bool> purchaseItem(String itemId);
  Future<bool> redeemPurchase(String purchaseId);
}
