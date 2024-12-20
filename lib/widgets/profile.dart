import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:campingbazar/main.dart';
import 'addArticle.dart';
import 'favouritePage.dart';
import 'guestpage.dart';
import 'message.dart';
import 'signin.dart';
import 'package:google_sign_in/google_sign_in.dart';




class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfilePage> {


  String userName = "Loading...";
  String email = "Loading...";


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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDataString = await secureStorage.read(key: 'userData');
      if (userDataString != null) {
        final userData = json.decode(userDataString);
        setState(() {
          userName = userData['userName'] ?? "Unknown User";
          email = userData['email'] ?? "No Email Provided";
        });
      }
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
      ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // User's Photo and Name Section
          const SizedBox(height: 30),
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage(
                  'assets/profile.jpeg'), // User's profile picture
              backgroundColor: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userName, // Fake user name
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            email, // Fake email
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 30),

          // Categories and Settings Options
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.grey[850]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: ListView(
                children: [
                  // Categories Section
                  _buildCategoryLabel("Categories"),
                  _buildSettingItem(
                    context,
                    icon: Icons.shopping_cart,
                    title: "My Purchases",
                    onTap: () {
                      // Implement functionality for My Purchases
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.sell,
                    title: "My Sellings",
                    onTap: () {
                      // Implement functionality for My Sellings
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.notifications,
                    title: "Notifications",
                    onTap: () {
                      // Implement functionality for Notifications
                    },
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),

                  // Settings Section
                  _buildCategoryLabel("Settings"),
                  _buildSettingItem(
                    context,
                    icon: Icons.person,
                    title: "Change Username",
                    onTap: () {
                      // Implement functionality to change username
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.lock,
                    title: "Change Password",
                    onTap: () {
                      // Implement functionality to change password
                    },
                  ),
                  _buildSettingItem(
                    context,
                    icon: Icons.help,
                    title: "Help & Support",
                    onTap: () {
                      // Implement functionality for help
                    },
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 0.5,
                  ),

                  // Log Out Button
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text(
                      "Log Out",
                      style: TextStyle(color: Colors.redAccent, fontSize: 18),
                    ),
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable widget for settings options
  Widget _buildSettingItem(BuildContext context,
      {required IconData icon,
        required String title,
        required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.yellow),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 18),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
    );
  }

  // Label for categories
  Widget _buildCategoryLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  // Log Out Confirmation Dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.grey[900], // Dark mode background
          title: Center(
            child: Text(
              "Log Out",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout,
                size: 50,
                color: Colors.redAccent,
              ),
              SizedBox(height: 15),
              Text(
                "Are you sure you want to log out?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center, // Center align actions
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[300],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey[700]!),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "Cancel",
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(width: 10),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                      (Route<dynamic> route) => false, // Remove all routes from the stack
                );
                await authService.signOut();
                final token = await secureStorage.read(key: 'token');
                print(token);
              },
              child: Text(
                "Log Out",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        );
      },
    );
  }

}

AuthService authService = AuthService();
final GoogleSignIn _googleSignIn = GoogleSignIn();

//  Sign out
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  // Sign out function
  Future<void> signOut() async {
    try {
      // Sign out from Firebase Authentication
      await _firebaseAuth.signOut();
      await _googleSignIn.signOut();
      print("User signed out from Google.");
      print("User signed out from Firebase.");

      // Remove 'token' and 'userData' from secure storage
      await secureStorage.delete(key: 'token');
      await secureStorage.delete(key: 'userData');
      print("Sensitive data removed from secure storage.");
    } catch (e) {
      print("Error during sign out: $e");
    }
  }
}
