import 'package:flutter/material.dart';
import 'package:campingbazar/widgets/socialloginbutton.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:campingbazar/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:campingbazar/widgets/guestpage.dart';
import 'package:campingbazar/widgets/createaccount.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  SignInPageState createState() => SignInPageState();
}

class SignInPageState extends State<SignInPage> {
  // Create controllers for the text fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;

  // A method to handle the sign-in logic
  void _signInWithPassword() async {
    String email = _emailController.text;
    String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      // Show an error if any field is empty
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
    } else {
      setState(() {
        isLoading = true;
      });

      try {
        // Sign-in with Firebase Authentication
        UserCredential credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Obtain the ID token
        String? token = await credential.user?.getIdToken();
        if (token == null) {
          // If the token is null, show an error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Authentication failed. Please try again.")),
          );
          return;
        }

        // Store the token in secure storage
        await secureStorage.write(key: 'token', value: token);

        // Call the backend API to send the token
        final success = await ApiService().signInUser(token);

        if (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const GuestPage()),
                (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to sign in')),
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle FirebaseAuthException (e.g., wrong credentials)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Incorrect Email or password!')),
        );
      } catch (e) {
        // Handle any other exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'An error occurred during sign-in. Please try again.')),
        );
      } finally {
        setState(() {
          isLoading = false;
        });
      }
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
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      // Get the user info from Firebase
      User? user = userCredential.user;

      if (user != null) {
        var token = await user
            .getIdToken(); // get the token after successful sing in
        // Check if the token is null
        if (token == null) {
          print('invalid token');
          return;
        }
        await secureStorage.write(key: 'token', value: token);

        // After Firebase account creation, call the backend API to register the user
        final apiService = ApiService();
        bool success = await apiService.createUserWithGoogle(token);
        if (success) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const GuestPage()),
                (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to sign in')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred during sign-in')),
      );
      setState(() {
        isLoading = false;
      });
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
      resizeToAvoidBottomInset: true,
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
                      mainAxisSize: MainAxisSize.min, // Content follows naturally
                      children: [
                        const SizedBox(height: 20), // Space after the app bar
                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10), // Spacing between elements
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade800,
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade800,
                            hintStyle: const TextStyle(color: Colors.white54),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            suffixIcon: Icon(
                              Icons.visibility_off,
                              color: Colors.white54,
                            ),
                          ),
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Add Forgot Password logic here
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(color: Colors.yellow),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _signInWithPassword,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                              )
                                  : const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Center(
                          child: Text(
                            "Or using other method",
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        const SizedBox(height: 20),
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
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CreateAccountPage()),
                              );
                            },
                            child: const Text(
                              "Don't have an account? Sign Up",
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
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

class ApiService {
  Future<bool> signInUser(String token) async {
    final url = Uri.parse("http://20.64.237.50:3000/api/users/signin");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final userData = responseData['user'];
        await secureStorage.write(key: 'userData', value: json.encode(userData));
        return true;
      } else {
        print('Failed to get user data: ${response.body}');
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
        print (await secureStorage.read(key: 'userData'));
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
