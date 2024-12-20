import 'package:flutter/material.dart';
import 'dart:async';
import 'package:smooth_page_indicator/smooth_page_indicator.dart'; // Add this package to your pubspec.yaml
import 'package:campingbazar/widgets/createaccount.dart';
import 'package:campingbazar/widgets/signin.dart';
import 'package:campingbazar/widgets/guestpage.dart';

class NextPage extends StatelessWidget {
  const NextPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
        ),
        body: PageTow());
  }
}



class PageTow extends StatefulWidget {
  const PageTow({super.key});

  @override
  State<PageTow> createState() => _NextPageState();
}

class _NextPageState extends State<PageTow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _images = [
    'assets/caroussel/image1.webp',
    'assets/caroussel/image2.jpg',
    'assets/caroussel/image3.jpeg',
  ];

  final List<String> _texts = [
    "Experience the ultimate outdoor comfort",
    "Make every camping trip unforgettable",
    "Embark on your next adventure with the ultimate camping essentials",
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (Timer timer) {
      if (_currentPage < _images.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // Main Content
          Column(
            children: [
              SizedBox(height: screenHeight * 0.05), // Top Padding
              // Carousel
              SizedBox(
                height: screenHeight * 0.4, // Dynamically adjust carousel height
                width: screenWidth * 0.8,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        _images[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Page Indicator
              SmoothPageIndicator(
                controller: _pageController,
                count: _images.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.yellow,
                  dotColor: Colors.grey,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              // Text Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: SizedBox(
                  width: screenWidth * 0.8, // Fixed width
                  child: Text(
                    _texts[_currentPage],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              // Buttons
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignInPage(),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Sign in",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateAccountPage(),
                    ),
                  );
                },
                child: Container(
                  width: screenWidth * 0.9,
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  decoration: BoxDecoration(
                    color: Colors.yellow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Create Account",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GuestPage(),
                    ),
                  );
                },
                child: const Text(
                  "Continue as a Guest",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05), // Bottom Padding
            ],
          ),
        ],
      ),
    );
  }
}

