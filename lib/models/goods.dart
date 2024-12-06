class Goods {
  final String title;
  final double price;
  final String image;

  Goods({required this.title, required this.price, required this.image});

  factory Goods.fromJson(Map<String, dynamic> json) {
    return Goods(
      title: json['title'],
      price: json['price'] ?? 0.0,
      image: json['image'] is String && json['image'].isNotEmpty
          ? json['image']
          : 'https://via.placeholder.com/150', // Заглушка для порожніх зображень
    );
  }
}
