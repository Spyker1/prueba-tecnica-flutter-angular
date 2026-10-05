/// Modelo inmutable de Dominio que representa un producto del catálogo.
class Product {
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

  const Product({
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

  /// Factory constructor para deserializar de forma segura desde JSON de DummyJSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
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

  /// Serialización a Map JSON.
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

  /// Genera una copia inmutable con valores actualizados.
  Product copyWith({
    int? id,
    String? title,
    String? description,
    double? price,
    double? rating,
    String? thumbnail,
    String? category,
    int? stock,
    double? discountPercentage,
    String? brand,
    List<String>? images,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      thumbnail: thumbnail ?? this.thumbnail,
      category: category ?? this.category,
      stock: stock ?? this.stock,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      brand: brand ?? this.brand,
      images: images ?? this.images,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
