import 'dart:convert';

import '../../core/constants/wish_tier.dart';

class WishItem {
  const WishItem({
    required this.id,
    required this.name,
    required this.price,
    required this.tier,
    required this.createdAt,
    this.note,
    this.link,
    this.photoPath,
    this.isPurchased = false,
    this.purchasedAt,
    this.sortOrder = 0,
  });

  final String id;
  final String name;
  final int price;
  final WishTier tier;
  final String? note;
  final String? link;
  final String? photoPath;
  final bool isPurchased;
  final DateTime? purchasedAt;
  final DateTime createdAt;
  final int sortOrder;

  bool get hasNote => note != null && note!.trim().isNotEmpty;
  bool get hasLink => link != null && link!.trim().isNotEmpty;
  bool get hasPhoto => photoPath != null && photoPath!.isNotEmpty;

  WishItem copyWith({
    String? name,
    int? price,
    WishTier? tier,
    String? note,
    bool clearNote = false,
    String? link,
    bool clearLink = false,
    String? photoPath,
    bool clearPhoto = false,
    bool? isPurchased,
    DateTime? purchasedAt,
    bool clearPurchasedAt = false,
    int? sortOrder,
  }) {
    return WishItem(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      tier: tier ?? this.tier,
      note: clearNote ? null : (note ?? this.note),
      link: clearLink ? null : (link ?? this.link),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      isPurchased: isPurchased ?? this.isPurchased,
      purchasedAt: clearPurchasedAt ? null : (purchasedAt ?? this.purchasedAt),
      createdAt: createdAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'tier': tier.name,
      'note': note,
      'link': link,
      'photoPath': photoPath,
      'isPurchased': isPurchased,
      'purchasedAt': purchasedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'sortOrder': sortOrder,
    };
  }

  factory WishItem.fromMap(Map<String, dynamic> map) {
    return WishItem(
      id: map['id'] as String,
      name: (map['name'] as String?) ?? 'Tanpa nama',
      price: (map['price'] as num?)?.toInt() ?? 0,
      tier: WishTierX.fromName(map['tier'] as String?),
      note: map['note'] as String?,
      link: map['link'] as String?,
      photoPath: map['photoPath'] as String?,
      isPurchased: (map['isPurchased'] as bool?) ?? false,
      purchasedAt: _parseDate(map['purchasedAt']),
      createdAt: _parseDate(map['createdAt']) ?? DateTime.now(),
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory WishItem.fromJson(String source) {
    return WishItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
