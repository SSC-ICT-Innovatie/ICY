import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:icy/data/datasources/local_storage_service.dart';
import 'package:icy/data/models/marketplace_model.dart';
import 'package:icy/data/models/user_model.dart';
import 'package:icy/data/repositories/marketplace_repository.dart';

class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final LocalStorageService _localStorageService;

  MarketplaceRepositoryImpl({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService();

  @override
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

  @override
  Future<List<PurchaseHistoryItem>> getUserPurchases(String userId) async {
    try {
      final marketplaceData = await getMarketplaceData();

      // Filter purchases by user ID
      final userPurchases =
          marketplaceData.purchaseHistory
              .where((purchase) => purchase.userId == userId)
              .toList();

      // Enrich purchase data with item information where name is missing
      return Future.wait(
        userPurchases.map((purchase) async {
          if (purchase.name != null) return purchase;

          // FIX: Handle potential null with a default value creation
          MarketplaceItem? item;
          try {
            item = marketplaceData.items.firstWhere(
              (item) => item.id == purchase.itemId,
            );
          } catch (_) {
            // Create a default item if not found
            item = MarketplaceItem(
              id: "unknown",
              categoryId: "unknown",
              name: "Unknown Item",
              description: "Item not found",
              image: "https://placehold.co/400x300?text=Unknown",
              price: 0,
              available: false,
              featured: false,
            );
          }

          // Create a new purchase with the item name
          return PurchaseHistoryItem(
            id: purchase.id,
            userId: purchase.userId,
            itemId: purchase.itemId,
            purchaseDate: purchase.purchaseDate,
            expiryDate: purchase.expiryDate,
            used: purchase.used,
            redeemCode: purchase.redeemCode,
            status: purchase.status,
            permanent: purchase.permanent,
            active: purchase.active,
            name: item.name,
          );
        }),
      );
    } catch (e) {
      print('Error getting user purchases: $e');
      return [];
    }
  }

  @override
  Future<bool> purchaseItem(String userId, String itemId) async {
    try {
      // Get the item information
      final marketplaceData = await getMarketplaceData();

      // FIX: Use try-catch instead of orElse that might return null
      MarketplaceItem? item;
      try {
        item = marketplaceData.items.firstWhere((item) => item.id == itemId);
      } catch (_) {
        throw Exception('Item not found');
      }

      // Check if the item is available
      if (!item.available) {
        return false;
      }

      // Get user information including coins
      final UserModel? user = await _getUserData(userId);
      if (user == null || user.stats == null) {
        throw Exception('User data not available');
      }

      // Check if user has enough coins
      final userCoins = user.stats!.totalCoins;
      if (userCoins < item.price) {
        return false;
      }

      // For now, we'll just simulate a successful purchase
      return true;
    } catch (e) {
      print('Error purchasing item: $e');
      return false;
    }
  }

  // Helper method to get user data
  Future<UserModel?> _getUserData(String userId) async {
    try {
      return await _localStorageService.getAuthUser();
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
}
