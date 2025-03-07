class MarketplaceData {
  final List<MarketplaceCategory> categories;
  final List<MarketplaceItem> items;
  final List<PurchaseHistoryItem> purchaseHistory;

  MarketplaceData({
    required this.categories,
    required this.items,
    required this.purchaseHistory,
  });

  factory MarketplaceData.fromJson(Map<String, dynamic> json) {
    return MarketplaceData(
      categories:
          (json['categories'] as List)
              .map((category) => MarketplaceCategory.fromJson(category))
              .toList(),
      items:
          (json['items'] as List)
              .map((item) => MarketplaceItem.fromJson(item))
              .toList(),
      purchaseHistory:
          (json['purchaseHistory'] as List)
              .map((purchase) => PurchaseHistoryItem.fromJson(purchase))
              .toList(),
    );
  }
}

class MarketplaceCategory {
  final String id;
  final String name;
  final String icon;

  MarketplaceCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory MarketplaceCategory.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategory(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
    );
  }
}

class MarketplaceItem {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final String image;
  final int price;
  final bool available;
  final bool featured;
  final int? quantity;
  final int? expiryDays;
  final bool? permanent;
  final bool? approvalRequired;

  MarketplaceItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.image,
    required this.price,
    required this.available,
    required this.featured,
    this.quantity,
    this.expiryDays,
    this.permanent,
    this.approvalRequired,
  });

  factory MarketplaceItem.fromJson(Map<String, dynamic> json) {
    return MarketplaceItem(
      id: json['id'],
      categoryId: json['categoryId'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      price: json['price'],
      available: json['available'],
      featured: json['featured'],
      quantity: json['quantity'],
      expiryDays: json['expiryDays'],
      permanent: json['permanent'],
      approvalRequired: json['approvalRequired'],
    );
  }
}

class PurchaseHistoryItem {
  final String id;
  final String userId;
  final String itemId;
  final String purchaseDate;
  final String? expiryDate;
  final bool? used;
  final String? redeemCode;
  final String? status;
  final bool? permanent;
  final bool? active;
  final String? name; // Add missing property

  PurchaseHistoryItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.purchaseDate,
    this.expiryDate,
    this.used,
    this.redeemCode,
    this.status,
    this.permanent,
    this.active,
    this.name, // Add to constructor
  });

  factory PurchaseHistoryItem.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryItem(
      id: json['id'],
      userId: json['userId'],
      itemId: json['itemId'],
      purchaseDate: json['purchaseDate'],
      expiryDate: json['expiryDate'],
      used: json['used'],
      redeemCode: json['redeemCode'],
      status: json['status'],
      permanent: json['permanent'],
      active: json['active'],
      name: json['name'], // Parse from JSON
    );
  }
}
