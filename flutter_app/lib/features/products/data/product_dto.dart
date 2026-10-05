import 'package:flutter_app/features/products/domain/product.dart';

/// Objeto de transferencia de datos (DTO) para mapear la respuesta JSON de la API.
class ProductDto {
  final int id;
  final String title;
  final String description;
  final double price;
  final double rating;
  final String thumbnail;
  final String category;
  final int stock;
  final double discountPercentage;
  final String brand;
  final List<String> images;

  const ProductDto({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.rating,
    required this.thumbnail,
    required this.category,
    required this.stock,
    this.discountPercentage = 0.0,
    this.brand = '',
    this.images = const [],
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      thumbnail: json['thumbnail'] as String? ?? '',
      category: json['category'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      brand: json['brand'] as String? ?? '',
      images: (json['images'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'rating': rating,
      'thumbnail': thumbnail,
      'category': category,
      'stock': stock,
      'discountPercentage': discountPercentage,
      'brand': brand,
      'images': images,
    };
  }

  Product toDomain() {
    return Product(
      id: id,
      title: title,
      description: description,
      price: price,
      rating: rating,
      thumbnail: thumbnail,
      category: category,
      stock: stock,
      discountPercentage: discountPercentage,
      brand: brand,
      images: images,
    );
  }
}
