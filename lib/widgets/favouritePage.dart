import 'package:campingbazar/main.dart';
import 'package:campingbazar/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addArticle.dart';
import 'message.dart';
import 'productlist.dart'; // Import your ProductCard file here
import 'package:campingbazar/widgets/guestpage.dart';


class favoritesPage extends StatefulWidget {
  const favoritesPage({super.key});


  @override
  State<favoritesPage> createState() => favoritesPageState();
}

class favoritesPageState extends State<favoritesPage> {
  List<Product> favoriteProducts = [];
  bool isLoading = true;
  int selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 0) {
      // Check if the Favorites tab is selected
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GuestPage()),
      );
    }
    if (index == 1) {
      // Check if the Favorites tab is selected
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const favoritesPage()),
      );
    } else if (index == 2) {
      // Redirect to Sign In Page for all tabs except Home
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddArticlePage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const MessageForumPage()),
      );
    } else if (index == 4) {
      // Redirect to Sign In Page for all tabs except Home
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    } else {
      setState(() {
        selectedIndex = index; // Update selected index for Home
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFavoriteProducts();
  }

  Future<void> fetchFavoriteProducts() async {
    const String apiUrl = "http://20.64.237.50:3000/api/items/getFavourites"; // Replace with your API endpoint
    final token = await secureStorage.read(key: 'token');
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
        },);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['items'];
        setState(() {
          favoriteProducts = jsonData.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load favorite products");
      }
    } catch (e) {
      print("Error fetching favorite products: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void onHeartTap(String itemID){
    setState(() {
      favoriteProducts.removeWhere((product) => product.itemID == itemID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate crossAxisCount based on screen width
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        backgroundColor: const Color.fromRGBO(6, 31, 71, 0.51),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite, color: Colors.red),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Transform.scale(
              scale: 1.8,
              child: const Icon(Icons.add_circle, color: Colors.yellow),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.message, color: Colors.lightBlue),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person, color: Colors.white60),
            label: '',
          ),
        ],
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
      ),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        elevation: 0,
        title: const Text(
          "Favorites",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.yellow),
        )
            : Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04, // Dynamically adjust padding
          ),
          child: favoriteProducts.isEmpty
              ? const Center(
            child: Text(
              "No Favorites Yet 😔",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
              : LayoutBuilder(
            builder: (context, constraints) {
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount, // Dynamically set columns
                  crossAxisSpacing: screenWidth * 0.04, // Adjust spacing
                  mainAxisSpacing: screenWidth * 0.04,
                  childAspectRatio: screenHeight / screenWidth > 1.5
                      ? 0.61
                      : 0.8, // Adjust aspect ratio for different screens
                ),
                itemCount: favoriteProducts.length,
                itemBuilder: (context, index) {
                  final product = favoriteProducts[index];
                  return ProductCard(
                      product: product,
                      onHeartTap: () => onHeartTap(product.itemID));
                },
              );
            },
          ),
        ),
      ),
    );
  }


}
