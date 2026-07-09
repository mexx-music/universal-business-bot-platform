import 'package:flutter/material.dart';

enum ProductType { produkt, dienstleistung }

extension ProductTypeX on ProductType {
  String get displayName => switch (this) {
    ProductType.produkt => 'Produkt',
    ProductType.dienstleistung => 'Dienstleistung',
  };

  Color get color => switch (this) {
    ProductType.produkt => Colors.indigo,
    ProductType.dienstleistung => Colors.teal,
  };

  IconData get icon => switch (this) {
    ProductType.produkt => Icons.inventory_2_outlined,
    ProductType.dienstleistung => Icons.design_services_outlined,
  };
}

class ProductOrService {
  final String id;
  final String name;
  final String description;
  final ProductType type;
  final double? price;

  const ProductOrService({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.price,
  });
}
