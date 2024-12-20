import 'package:flutter/material.dart';
import 'package:campingbazar/widgets/productlist.dart';
import 'package:campingbazar/widgets/profile.dart';
import 'package:campingbazar/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'addArticle.dart';
import 'favouritePage.dart';
import 'message.dart';
import 'productDetails.dart';

class GuestPage extends StatefulWidget {
  const GuestPage({super.key});

  @override
  State<GuestPage> createState() => _GuestPageState();
}

class _GuestPageState extends State<GuestPage> {
  int _selectedIndex = 0; // Current index for the bottom navigation bar
  String _searchQuery = '';
  bool _isSearching = false;
  String _searchType = 'name'; // Default search type

  // Initialize the list of products
  List<Product> products = [];
  final TextEditingController searchController = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData(); // Load user data and token
    fetchProducts(); // Fetch products from the API
  }

  void _onItemTapped(int index) {
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
        _selectedIndex = index; // Update selected index for Home
      });
    }
  }

  Future<void> fetchProducts() async {
    const String apiUrl = "http://20.64.237.50:3000/api/items/getItems";

    try {
      // Retrieve userData from SecureStorage
      final userDataString = await secureStorage.read(key: 'userData');
      Map<String, dynamic>? userData;
      if (userDataString != null) {
        userData = json.decode(userDataString);
      }

      final response;

      // Check if userData and userID are available
      if (userData != null && userData['userID'] != null && userData['userID'].isNotEmpty) {
        response = await http.get(
          Uri.parse(apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'user_id': userData['userID'],
          },
        );
      } else {
        response = await http.get(
          Uri.parse(apiUrl),
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['items'];
        print(jsonData);
        setState(() {
          products = jsonData.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchSearchResults(String keyword) async {
    const String searchApiUrl = "http://20.64.237.50:3000/api/items/search";
    print(keyword);
    try {
      // Retrieve userData from SecureStorage
      final userDataString = await secureStorage.read(key: 'userData');
      Map<String, dynamic>? userData;
      if (userDataString != null) {
        userData = json.decode(userDataString);
      }

      final response;

      // Add userID in the headers if available
      if (userData != null && userData['userID'] != null && userData['userID'].isNotEmpty) {
        response = await http.get(
          Uri.parse("$searchApiUrl?keyword=$keyword"),
          headers: {
            'Content-Type': 'application/json',
            'user_id': userData['userID'],
          },
        );
      } else {
        response = await http.get(
          Uri.parse("$searchApiUrl?keyword=$keyword"),
        );
      }

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body)['items'];
        setState(() {
          products = jsonData.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load search results");
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }



  String userName = "Guest";
  String token = "";
  Map<String, dynamic> userData = {};

  Future<void> getData() async {
    try {
      // Fetch user data and token from secureStorage asynchronously
      final fetchedUserData = await secureStorage.read(key: 'userData');
      final fetchedToken = await secureStorage.read(key: 'token');


      // Initialize the state variables
      String fetchedUserName = "Guest";
      String fetchedTokenValue = "";

      // Check if user data exists and decode it if not null
      if (fetchedUserData != null) {
        final decodedUserData = json.decode(fetchedUserData);
        userData = decodedUserData; // Assign the decoded map to userData
        fetchedUserName = decodedUserData['userName'] ?? "Guest"; // Get the username
      }

      // Check if token exists and set it
      if (fetchedToken != null) {
        fetchedTokenValue = fetchedToken;
      }

      // Only update the state if token is valid (not empty)
      if (fetchedTokenValue.isNotEmpty) {
        setState(() {
          token = fetchedTokenValue; // Update token in the state
          userName = fetchedUserName; // Update username in the state
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }


  void _showFilterDialog(BuildContext context) {
    bool proxyEnabled = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        double minPrice = 0;
        double maxPrice = 1000;
        List<String> categories = ['Tents', 'Chairs', 'Sleeping Bags', 'Others'];
        Map<String, bool> selectedCategories = {
          'Tents': false,
          'Chairs': false,
          'Sleeping Bags': false,
          'Others': false,
        };

        return StatefulBuilder(
          builder: (context, setState) {
            final screenWidth = MediaQuery.of(context).size.width;
            final screenHeight = MediaQuery.of(context).size.height;

            return AlertDialog(
              backgroundColor: const Color(0xFF0F2747), // Deeper blue color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: SingleChildScrollView(
                child: Container(
                  width: screenWidth * 0.9, // Responsive width
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Filter',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06, // Responsive font size
                            fontWeight: FontWeight.bold,
                            color: Colors.yellow,
                          ),
                        ),
                      ),
                      const Divider(color: Colors.white54),
                      const SizedBox(height: 16),
                      Text(
                        'Categories:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: categories.map((category) {
                            return CheckboxListTile(
                              title: Text(
                                category,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              value: selectedCategories[category],
                              onChanged: (bool? value) {
                                setState(() {
                                  selectedCategories[category] = value ?? false;
                                });
                              },
                              checkColor: Colors.black,
                              activeColor: Colors.yellow,
                              contentPadding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Show Nearby Items:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title: Text(
                          'Enable',
                          style: TextStyle(color: Colors.white70),
                        ),
                        value: proxyEnabled,
                        onChanged: (bool value) async {
                          setState(() {
                            proxyEnabled = value;
                          });

                          if (value) {
                            LocationPermission permission =
                            await Geolocator.checkPermission();

                            if (permission == LocationPermission.denied ||
                                permission == LocationPermission.whileInUse) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      "Permission Required",
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: screenWidth * 0.045,
                                      ),
                                    ),
                                    content: const Text(
                                      "We need access to your location to filter nearby items.",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    backgroundColor: const Color(0xFF0F2747),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            proxyEnabled = false;
                                          });
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "No, thanks",
                                          style: TextStyle(color: Colors.yellow),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          Navigator.pop(context);
                                          await Geolocator.requestPermission();
                                          LocationPermission newPermission =
                                          await Geolocator.checkPermission();
                                          if (newPermission !=
                                              LocationPermission.denied) {
                                            Position position =
                                            await Geolocator.getCurrentPosition(
                                                desiredAccuracy:
                                                LocationAccuracy.high);
                                            print("User's location: ${position.latitude}, ${position.longitude}");
                                            setState(() {
                                              proxyEnabled = true;
                                            });
                                          } else {
                                            setState(() {
                                              proxyEnabled = false;
                                            });
                                          }
                                        },
                                        child: const Text(
                                          "Grant Permission",
                                          style: TextStyle(color: Colors.yellow),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              Position position =
                              await Geolocator.getCurrentPosition(
                                  desiredAccuracy: LocationAccuracy.high);
                              print("User's location: ${position.latitude}, ${position.longitude}");
                            }
                          }
                        },
                        activeColor: Colors.yellow,
                        inactiveThumbColor: Colors.white38,
                        inactiveTrackColor: Colors.white24,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Price:',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045, // Responsive font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          Text(
                            '\$${minPrice.toStringAsFixed(0)} - \$${maxPrice.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          RangeSlider(
                            values: RangeValues(minPrice, maxPrice),
                            min: 0,
                            max: 1000,
                            divisions: 100,
                            labels: RangeLabels(
                              '\$${minPrice.toStringAsFixed(0)}',
                              '\$${maxPrice.toStringAsFixed(0)}',
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                minPrice = values.start;
                                maxPrice = values.end;
                              });
                            },
                            activeColor: Colors.yellow,
                            inactiveColor: Colors.white30,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }








  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/background.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Main Content
            Column(
              children: [
                // Filter Button with Label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 30.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Search Field
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.white12, // Dark background
                            borderRadius: BorderRadius.circular(8.0), // Rounded corners
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController, // Add a controller for the text field
                                  style: const TextStyle(color: Colors.white), // White text
                                  decoration: InputDecoration(
                                    hintText: 'Search...',
                                    hintStyle: TextStyle(color: Colors.grey[400]), // Light grey hint
                                    border: InputBorder.none, // No border
                                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                                  ),
                                ),
                              ),
                              // Confirm Button
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.yellow),
                                onPressed: () async {
                                  final keyword = searchController.text.trim();
                                  if (keyword.isNotEmpty) {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    await fetchSearchResults(keyword); // Call the search function
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Filter Button
                      ElevatedButton(
                        onPressed: () {
                          _showFilterDialog(context); // Pass the context where the button is placed.
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 2, // Subtle shadow for depth
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'Filter',
                              style: TextStyle(color: Colors.black),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.filter_list, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),

                ),

                // Personalized Greeting
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle, color: Colors.yellow, size: 40),
                      const SizedBox(width: 8),
                      Text(
                        "Hi, $userName",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.5, 1.5),
                              blurRadius: 3.0,
                              color: Colors.black45,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Products Label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Products",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white70,
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 2,
                        color: Colors.yellow,
                      ),
                    ],
                  ),
                ),

                // Product Grid (Scrolls with content)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: RefreshIndicator(
                      onRefresh: fetchProducts,
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.61,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailsPage(
                                    title: product.title,
                                    userName: product.userName,
                                    price: product.price,
                                    image: product.image,
                                    description:
                                    "This is a high-quality product that meets your camping needs perfectly!",
                                  ),
                                ),
                              );
                            },
                            child: ProductCard(product: product),
                          );
                        },
                        physics: const BouncingScrollPhysics(), // Smoother scrolling on mobile
                        cacheExtent: 300, // Pre-cache additional items during scrolling
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),

      // BottomNavigationBar
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
