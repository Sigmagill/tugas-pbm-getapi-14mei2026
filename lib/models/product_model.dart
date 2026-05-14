class Product {
  final int? id;
  final String name;
  final int price;
  final String description;
  final String? createdAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    required this.description,
    this.createdAt,
  });

  // Factory constructor: dari JSON ke Object
 factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'],
    name: json['name'],
    price: double.parse(json['price'].toString()).toInt(), // ← fix ini
    description: json['description'],
    createdAt: json['created_at'],
  );
}

  // Ke JSON untuk dikirim ke API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'description': description,
    };
  }

  // Format harga ke Rupiah
  String get formattedPrice {
    return 'Rp ${price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    )}';
  }
}