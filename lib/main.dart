import 'package:campingbazar/widgets/guestpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:campingbazar/widgets/campingbazar.dart' ;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Global instance of flutter secure storage
final FlutterSecureStorage secureStorage = FlutterSecureStorage();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Check for token and userData in secure storage
  String? token = await secureStorage.read(key: 'token');
  String? userData = await secureStorage.read(key: 'userData');

  // Determine the initial page based on the presence of token and userData
  Widget initialPage;
  if (token != null && userData != null) {
    initialPage = GuestPage(); // Redirect to GuestPage
  } else {
    initialPage = CampingBazzarApp(); // Default entry point
  }

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: initialPage,
  ));
}









