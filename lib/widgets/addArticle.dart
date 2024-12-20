
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:campingbazar/main.dart';
import 'package:campingbazar/widgets/profile.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;

import 'favouritePage.dart';
import 'guestpage.dart';
import 'message.dart';



class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key});

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  LatLng? _location;  // to capture from map
  bool _isLoading = false;
  bool _isSubmitLoading = false ;
  bool _isUploading = false ;

  final ImagePicker picker = ImagePicker();
  String imageUrl = ''; // To store the image URL after upload
  File? _imageFile ;

  String selectedCategory = "";
  final List<String> categories = ["Chairs", "Tents", "Sleeping Bags", "Other"];

  Future<LatLng?> useMyLocation() async {
    setState(() {
      _isLoading = true; // Start loading
    });
    try {
      // Check if location permissions are granted
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        // Request permissions if denied
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          // If still denied, show an error and return null
          print('Location permissions are denied.');
          return null;
        }
      }

      // Get the current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _location = LatLng(position.latitude, position.longitude);
      });
      print("Location Selected: ${_location?.latitude}, ${_location?.longitude}");

    } catch (e) {
      print('Error getting current location: $e');
    }finally {
      setState(() {
        _isLoading = false; // Stop loading
      });
    }
    return null ;
  }

  void chooseOnMap() async {
    final selectedLocation = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
    if (selectedLocation != null) {
      setState(() {
        _location = selectedLocation;
      });
      print("Location Selected: ${selectedLocation.latitude}, ${selectedLocation.longitude}");
    } else {
      print("Map selection canceled");
    }
  }

  // Function to handle form submission
  Future<void> _onSubmit() async {
    setState(() {
      _isSubmitLoading = true;
    });
    // Get the values from the controllers and other fields
    final String name = nameController.text;
    final String description = descriptionController.text;
    final String price = priceController.text;

    // Prepare the data to send to the API
    final Map<String, dynamic> data = {
      'title': name,
      'description': description,
      'price': price,
      'category': selectedCategory,
      'location': {
        'latitude': _location?.latitude,
        'longitude': _location?.longitude,
      },
      'image': imageUrl
    };

    try {
      // retrieving the token from the storage
      final token = await secureStorage.read(key: 'token');

      // Send the POST request to the API
      final response = await http.post(
        Uri.parse("http://20.64.237.50:3000/api/items/createItem"),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(data), // Encode the data to JSON
      );

      // Check the response status
      if (response.statusCode == 201) {
        // Successfully created the item
        final responseData = jsonDecode(response.body);
        print('Item created successfully: ${responseData['message']}');
      } else {
        // Failed to create item
        final responseData = jsonDecode(response.body);
        print('Failed to create item. Status code: ${responseData.error}');
      }
    } catch (e) {
      // Handle errors
      print('Error occurred while submitting data: $e');
    } finally{
      setState(() {
        _isSubmitLoading = false ;
      });
    }
  }

  // Function to upload the image to the backend and get the URL
  // Function to upload the image to the backend and get the URL
  Future<void> _uploadImage(File imageFile) async {
    try {
      setState(() {
        _isUploading = true ;
      });
      // Prepare the file to upload
      String fileName = p.basename(imageFile.path); // Use p.basename to get the file name
      var uri = Uri.parse('http://20.64.237.50:3000/api/items/upload'); // Replace with your backend API URL

      final token = await secureStorage.read(key: 'token');

      // Define headers (including Authorization with Bearer token)
      Map<String, String> headers = {
        'Authorization': "Bearer $token", // Replace with your actual token
      };

      var request = http.MultipartRequest('POST', uri)
        ..headers.addAll(headers)
        ..files.add(await http.MultipartFile.fromPath(
          'image', // Key used in backend
          imageFile.path,
        ));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response from the server
        final responseBody = await http.Response.fromStream(response);
        final responseData = responseBody.body;

        final url = jsonDecode(responseData)["imageUrl"] ;

        // Assuming the response is in JSON format and contains the image URL
        setState(() {
          imageUrl = url ; // Store the URL from the server response
        });

        // Optionally display the image URL
        print('Image uploaded successfully! URL: $imageUrl');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    } finally{
      setState(() {
        _isUploading = false ;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black54, Colors.black],
            begin: Alignment.bottomCenter,
            end: Alignment.center,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                "Add Article",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        // Pick an image from the gallery or camera
                        final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery); // or ImageSource.camera

                        if (pickedFile != null) {
                          File imageFile = File(pickedFile.path);
                          setState(() {
                            _imageFile = imageFile; // Store the selected image
                          });
                          print('Image picked');
                          await _uploadImage(imageFile); // Call upload function
                        } else {
                          print("No image selected");
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: _imageFile == null
                            ? const Center(
                          child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        )
                            : _isUploading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : Image.file(
                          _imageFile!,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Title",  // This is the label that will be shown
                        labelStyle: const TextStyle(
                          color: Colors.grey,  // The label color
                          fontSize: 20,         // Make the label text bigger
                          fontWeight: FontWeight.bold,  // Make the label text bold
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.yellow),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,  // This makes the label float above the text field
                      ),
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Category",  // This is the label that will be shown
                        labelStyle: const TextStyle(
                          color: Colors.grey,  // The label color
                          fontSize: 20,         // Make the label text bigger
                          fontWeight: FontWeight.bold,  // Make the label text bold
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.yellow),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,  // This makes the label float above the dropdown
                      ),
                      dropdownColor: Colors.grey[900],
                      style: const TextStyle(color: Colors.white),
                      items: categories
                          .map((category) => DropdownMenuItem<String>(
                        value: category,
                        child: Text(category, style: const TextStyle(color: Colors.white)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value ?? "Chairs";
                        });
                      },
                    )
                    ,
                    const SizedBox(height: 20),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Price",  // This is the label that will be shown
                        labelStyle: const TextStyle(
                          color: Colors.grey,  // The label color
                          fontSize: 20,         // Make the label text bigger
                          fontWeight: FontWeight.bold,  // Make the label text bold
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.yellow),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,  // This makes the label float above the text field
                      ),
                    )
                    ,
                    const SizedBox(height: 20),
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: descriptionController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Description",  // This is the label that will be shown
                        labelStyle: const TextStyle(
                          color: Colors.grey,  // The label color
                          fontSize: 20,         // Make the label text bigger
                          fontWeight: FontWeight.bold,  // Make the label text bold
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.yellow),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,  // This makes the label float above the text field
                      ),
                    )
                    ,
                    const SizedBox(height: 16),
                    const Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.center, // Ensures the loader is centered
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : useMyLocation,
                                icon: const FaIcon(
                                  FontAwesomeIcons.locationArrow,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                label: const Text(
                                  "Use My Location",
                                  style: TextStyle(color: Color.fromRGBO(10, 10, 2, 1)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isLoading ? null : chooseOnMap,
                                icon: const FaIcon(
                                  FontAwesomeIcons.mapMarkedAlt,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                label: const Text(
                                  "Choose on Map",
                                  style: TextStyle(color: Color.fromRGBO(10, 10, 2, 1)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(
                                color: Colors.yellow,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 50),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _isSubmitLoading
                            ? null // Disable button when loading
                            : () async {
                          if (nameController.text.isNotEmpty &&
                              descriptionController.text.isNotEmpty &&
                              priceController.text.isNotEmpty &&
                              selectedCategory.isNotEmpty &&
                              _location != null && imageUrl.isNotEmpty) {
                            setState(() {
                              _isSubmitLoading = true; // Start loading
                            });
                            try {
                              await _onSubmit();

                              // Show the success pop-up dialog
                              showDialog(
                                context: context,
                                barrierColor: Colors.black.withOpacity(0.7), // Semi-transparent black background
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15), // Rounded corners for the dialog
                                    ),
                                    backgroundColor: Colors.grey[900], // Dark mode background
                                    title: Center(
                                      child: Text(
                                        "Success",
                                        style: TextStyle(
                                          color: Colors.yellowAccent, // Vibrant yellow title for emphasis
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          size: 50,
                                          color: Colors.greenAccent, // Green accent for success
                                        ),
                                        SizedBox(height: 15),
                                        Text(
                                          "Item created successfully!",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white70, // Subtle white text for content
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actionsAlignment: MainAxisAlignment.center, // Center align actions
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close the dialog
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.yellowAccent,
                                          backgroundColor: Colors.grey.shade800, // Dark button background
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                                          ),
                                        ),
                                        child: Text(
                                          "OK",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("An error occurred. Please try again."),
                                ),
                              );
                            } finally {
                              setState(() {
                                _isSubmitLoading = false; // Stop loading
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please fill in all required fields!"),
                              ),
                            );
                          }
                        },
                        child: _isSubmitLoading
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                strokeWidth: 2.5,
                              ),
                            ),
                            SizedBox(width: 12), // Spacing between spinner and text
                            Text(
                              "Loading...",
                              style: TextStyle(fontSize: 18, color: Colors.black),
                            ),
                          ],
                        )
                            : const Text(
                          "Add Article",
                          style: TextStyle(fontSize: 18, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }


}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _selectedLocation;
  TextEditingController _searchController = TextEditingController();
  List<dynamic> _suggestions = [];
  Timer? _debounce;

  // Fetch suggestions from Nominatim API
  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) return;

    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');
    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'com.example.app' // Required by Nominatim API
      });

      if (response.statusCode == 200) {
        final results = json.decode(response.body);
        setState(() {
          _suggestions = results;
        });
      } else {
        setState(() {
          _suggestions = [];
        });
      }
    } catch (e) {
      setState(() {
        _suggestions = [];
      });
    }
  }

  // Handle search input with debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSuggestions(query);
    });
  }

  // Move map to selected suggestion
  void _selectSuggestion(dynamic suggestion) {
    final lat = double.parse(suggestion['lat']);
    final lon = double.parse(suggestion['lon']);
    final location = LatLng(lat, lon);

    setState(() {
      _selectedLocation = location;
      _suggestions = [];
      _searchController.text = suggestion['display_name'];
    });

    _mapController.move(location, 15.0);
  }

  // Handle map tap to pick location
  void _onMapTap(LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
  }

  // Confirm selection
  void _confirmSelection() {
    if (_selectedLocation != null) {
      Navigator.pop(context, _selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No location selected!")),
      );
    }
  }

  // Cancel and return
  void _cancelSelection() {
    Navigator.pop(context, null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Display
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(51.509364, -0.128928),
              initialZoom: 9.2,
              onTap: (tapPosition, point) => _onMapTap(point),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              // Marker for selected location
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 80.0,
                      height: 80.0,
                      child: const Icon(
                        Icons.location_pin,
                        size: 40,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          // Custom App Bar (Search Bar)
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      decoration: const InputDecoration(
                        hintText: "Search for a place...",
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Suggestions Dropdown
          if (_suggestions.isNotEmpty)
            Positioned(
              top: 90,
              left: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _suggestions[index];
                    return ListTile(
                      title: Text(suggestion['display_name']),
                      onTap: () => _selectSuggestion(suggestion),
                    );
                  },
                ),
              ),
            ),
          // Confirm and Cancel Buttons
          Positioned(
            bottom: 30,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensures the column wraps its children
              crossAxisAlignment: CrossAxisAlignment.end, // Align buttons to the right
              children: [
                FloatingActionButton.extended(
                  onPressed: _cancelSelection,
                  label: const Text("Cancel"),
                  icon: const Icon(Icons.close),
                  backgroundColor: Colors.red,
                ),
                const SizedBox(height: 15), // Add some spacing between buttons
                FloatingActionButton.extended(
                  onPressed: _confirmSelection,
                  label: const Text("Confirm"),
                  icon: const Icon(Icons.check),
                  backgroundColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





