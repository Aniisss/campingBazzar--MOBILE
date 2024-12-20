import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:campingbazar/main.dart';

import 'SocialLoginButton.dart';
import 'guestpage.dart';


class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  CreateAccountPageState createState() => CreateAccountPageState();
}

class CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();




  String? errorMessage = '';
  bool isLoading = false;

  // Google Sign-In setup
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> createAccountWithPassword() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      setState(() {
        errorMessage = "Please fill in all fields.";
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      var token = await credential.user!.getIdToken();
      // Check if the token is null
      if (token == null) {
        setState(() {
          errorMessage = 'Error in authentication ';
        });
        return;
      }


      await secureStorage.write(key: 'token', value: token);



      // After Firebase account creation, call the backend API to register the user
      final apiService = ApiService();
      bool success = await apiService.createUserWithPassword(username, token);
      if (success) {
         // Replace with your next screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const GuestPage()),
              (Route<dynamic> route) => false, // Remove all routes from the stack
        );
        final user = await secureStorage.read(key: 'userData');
        print(user);
      } else {
        setState(() {
          errorMessage = 'Failed to create account in backend.';
        });
      }


    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else {
          errorMessage = 'An unknown error occurred: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Sign In with Google function
  Future<void> signInWithGoogle() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Start the Google sign-in process
      GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in
        setState(() {
          isLoading = false;
        });
        return;
      }

      // Obtain the authentication details from the Google account
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase authentication
      OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the user info from Firebase
      User? user = userCredential.user;

      if (user != null) {
        // You can call your backend API here to register the user if needed
        // You can also store the token for further use
        var token = await user.getIdToken();
        // Check if the token is null
        if (token == null) {
          setState(() {
            errorMessage = 'Error in authentication ';
          });
          return;
        }
        await secureStorage.write(key: 'token', value: token);

        // After Firebase account creation, call the backend API to register the user
        final apiService = ApiService();
        bool success = await apiService.createUserWithGoogle(token);
        if (success) {
          // Replace with your next screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const GuestPage()),
                (Route<dynamic> route) => false, // Remove all routes from the stack
          );
        } else {
          setState(() {
            errorMessage = 'Failed to create account in backend.';
          });
        }

        // After successful Google sign-in, navigate to another screen (e.g., home screen)
        // Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error signing in with Google: ${e.toString()}';
      });
      print(errorMessage);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20), // Space after app bar
                        const Text(
                          "Create Account",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username Input
                        InputField(
                          controller: usernameController,
                          label: "Username",
                          hintText: "Create your username",
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 20),

                        // Email Input
                        InputField(
                          controller: emailController,
                          label: "Email",
                          hintText: "Enter your email",
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 20),

                        // Password Input
                        InputField(
                          controller: passwordController,
                          label: "Password",
                          hintText: "Create your password",
                          icon: Icons.lock,
                          isPassword: true,
                        ),
                        const SizedBox(height: 30),

                        // Display error message if exists
                        if (errorMessage != null && errorMessage!.isNotEmpty)
                          Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),

                        // Create Account Button
                        GestureDetector(
                          onTap: isLoading ? null : createAccountWithPassword,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: isLoading
                                  ? Colors.yellow.withOpacity(0.5)
                                  : Colors.yellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Text(
                                  "Create Account",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                if (isLoading)
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Divider Text
                        const Center(
                          child: Text(
                            "Or using other method",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Social Login Buttons
                        SocialLoginButton(
                          text: "Sign Up with Google",
                          icon: FontAwesomeIcons.google,
                          color: Colors.white,
                          textColor: Colors.black,
                          onTap: signInWithGoogle,
                        ),
                        const SizedBox(height: 10),
                        SocialLoginButton(
                          text: "Sign Up with Facebook",
                          icon: Icons.facebook,
                          color: Colors.blue,
                          textColor: Colors.white,
                          onTap: () {},
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

}

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool isPassword;

  const InputField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade800,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: Icon(icon, color: Colors.white54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}


class ApiService {
  Future<bool> createUserWithPassword(String username,String token) async {
    final url = Uri.parse("http://20.64.237.50:3000/api/users/signin");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
          "userName": username,
        }),
      );

      if (response.statusCode == 201) {
        final userData = json.decode(response.body)['user'];
        await secureStorage.write(key: 'userData', value: json.encode(userData));
        return true;
      } else {
        print('Failed to create user: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error during API call: $error');
      return false;
    }
  }


  Future<bool> createUserWithGoogle(String token) async {
    final url = Uri.parse("http://20.64.237.50:3000/api/users/signin");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: json.encode({
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userData = responseData['user'];
        await secureStorage.write(key: 'userData', value: json.encode(userData));
        return true;
      } else {
        print('Failed to create user: ${response.body}');
        return false;
      }
    } catch (error) {
      print('Error during API call: $error');
      return false;
    }
  }
}


