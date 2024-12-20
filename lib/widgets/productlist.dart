import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:campingbazar/main.dart';
import 'package:http/http.dart' as http;

class Product {
  final String itemID;
  final String userName;
  final String title;
  final String category;
  final double price;
  final String image;
  final int createdAt; // Backend-provided timestamp in milliseconds
  bool isLiked;

  Product({
    required this.userName,
    required this.itemID,
    required this.title,
    required this.category,
    required this.price,
    required this.image,
    required this.createdAt,
    required this.isLiked,
  });

  // Factory method to create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      itemID: json['itemID'] ?? '',
      userName: json['userName'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      image: json['image'] ?? '',
      createdAt: (json['createdAt']?['_seconds'] ?? 0) * 1000,
      isLiked: json['isLiked'] ?? false,
    );
  }

  // Helper method to calculate time difference
  String getTimeDifference() {
    final createdAtDate = DateTime.fromMillisecondsSinceEpoch(createdAt);
    final now = DateTime.now();
    final difference = now.difference(createdAtDate);

    if (difference.inMinutes < 1) {
      return "Now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} m";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} h";
    } else if (difference.inDays < 30) {
      return "${difference.inDays} d";
    } else {
      return "${(difference.inDays / 30).floor()} mo";
    }
  }
}

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onHeartTap; // Optional callback

  const ProductCard({
    required this.product,
    this.onHeartTap,
    Key? key,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  void toggleLike() async {
    final productId = widget.product.itemID;
    final apiUrl = "http://20.64.237.50:3000/api/items/addFavourite/$productId";

    try {
      final String? token = await secureStorage.read(key: 'token');

      setState(() {
        widget.product.isLiked = !widget.product.isLiked;
      });

      if (token == null) {
        return;
      }
      if (widget.onHeartTap != null) {
        widget.onHeartTap!(); // Safely invoke callback
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'isLiked': widget.product.isLiked,
        }),
      );

      if (response.statusCode != 200) {
        setState(() {
          widget.product.isLiked = !widget.product.isLiked;
        });
      }
    } catch (e) {
      setState(() {
        widget.product.isLiked = !widget.product.isLiked;
      });
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String timeSince = widget.product.getTimeDifference();

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade800,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  widget.product.image,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Available",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: toggleLike,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: Icon(
                        widget.product.isLiked ? Icons.favorite : Icons.favorite_border,
                        color: widget.product.isLiked ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.product.category,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "${widget.product.price.toStringAsFixed(0)} DT",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        timeSince,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
