import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/data/models/marketplace_model.dart';

class MarketplaceRepository {

  MarketplaceRepository({LocalStorageService? localStorageService});

  // Load marketplace items from JSON file
  Future<MarketplaceData> getMarketplaceData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/data/marketplace.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return MarketplaceData.fromJson(jsonData);
    } catch (e) {
      print('Error loading marketplace data: $e');
      return MarketplaceData(categories: [], items: [], purchaseHistory: []);
    }
  }

  Future<List<PurchaseHistoryItem>> getUserPurchases(String userId) async {
    try {
      final marketplaceData = await getMarketplaceData();
      return marketplaceData.purchaseHistory
          .where((purchase) => purchase.userId == userId)
          .toList();
    } catch (e) {
      print('Error getting user purchases: $e');
      return [];
    }
  }

  // Purchase an item
  Future<bool> purchaseItem(String userId, String itemId) async {
    try {
      // In a real implementation, this would call an API
      // For now, we'll just simulate a successful purchase

      // Get the user's coin balance
      final userCoins = await _getUserCoins(userId);

      // Get the item price
      final marketplaceData = await getMarketplaceData();
      final item = marketplaceData.items.firstWhere(
        (item) => item.id == itemId,
      );

      // Check if the user can afford the item
      if (userCoins < item.price) {
        return false;
      }

      // In a real implementation, we would update the user's coin balance
      // and update the purchase history

      return true;
    } catch (e) {
      print('Error purchasing item: $e');
      return false;
    }
  }

  // Get user's coin balance
  Future<int> _getUserCoins(String userId) async {
    try {
      // This would typically come from the user profile
      // For now, just returning a fixed value
      return 1000;
    } catch (e) {
      print('Error getting user coins: $e');
      return 0;
    }
  }
}
