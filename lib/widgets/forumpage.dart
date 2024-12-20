import 'package:flutter/material.dart';

class ForumPage extends StatelessWidget {
  // List of forums with dynamic data
  final List<Map<String, String>> forums = [
    {
      "subject": "Capserat Event",
      "time": "12:30 PM",
      "content": "Fahmi: When does this event start?",
      "image":
      "https://th.bing.com/th/id/OIP.pAQmhPb6aEnai-oSmxSJDwHaE7?rs=1&pid=ImgDetMain"
    },
    {
      "subject": "Houaria Event",
      "time": "3:45 PM",
      "content": "ahmed: very nice",
      "image":
      "https://th.bing.com/th/id/OIP.Zhd4k9A1h0H5fP7hWpJvZwHaDt?rs=1&pid=ImgDetMain"
    },
    {
      "subject": "Camping Tips ",
      "time": "10:00 AM",
      "content": "Anis: if you have any question DM me.",
      "image":
      "https://th.bing.com/th/id/OIP.-WivAmqVUgxVk4eX-J7ymgHaE8?rs=1&pid=ImgDetMain"
    },
  ];

  ForumPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color for the screen
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Forum post list
            Expanded(
              child: ListView.builder(
                itemCount: forums.length, // Use the length of the forums list
                itemBuilder: (context, index) {
                  final forum = forums[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(forum["image"]!),
                          backgroundColor: Colors.grey[700],
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              forum["subject"]!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              forum["time"]!,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          forum["content"]!,
                          style: TextStyle(
                            color: Colors.grey[300],
                            fontSize: 14,
                          ),
                        ),
                        onTap: () {
                          // Handle tap event to show more details or navigate
                          print("Tapped on: ${forum["subject"]}");
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Spacer to push button to the bottom
            const SizedBox(height: 16),

            // "Create New Post" button centered at the bottom
          ],
        ),
      ),
    );
  }
}