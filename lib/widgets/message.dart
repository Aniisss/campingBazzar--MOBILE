import 'package:campingbazar/widgets/profile.dart';
import 'package:flutter/material.dart';
import 'package:campingbazar/widgets/chatpage.dart';
import 'package:campingbazar/widgets/forumpage.dart';

import 'addArticle.dart';
import 'favouritePage.dart';
import 'guestpage.dart'; // Import ForumPage

class MessageForumPage extends StatefulWidget {
  const MessageForumPage({super.key});

  @override
  _MessageForumPageState createState() => _MessageForumPageState();
}

class _MessageForumPageState extends State<MessageForumPage> {
  bool isMessagesSelected = true;

  final List<Map<String, String>> messages = [
    {
      "name": "Fahmi",
      "lastMessage": "Hello, how are you?",
      "time": "12:45 PM",
      "userPhoto":
      "https://scontent.ftun9-1.fna.fbcdn.net/v/t39.30808-1/458470406_1943095399466350_8024828006208186735_n.jpg?stp=dst-jpg_s160x160_tt6&_nc_cat=108&ccb=1-7&_nc_sid=e99d92&_nc_ohc=JXmQ5rmsbJ8Q7kNvgHmNFOt&_nc_zt=24&_nc_ht=scontent.ftun9-1.fna&_nc_gid=Az-8dX2efCrx2Kp9CmJtCfo&oh=00_AYAJh1ro2WGGZI5xtchZjh5f81hr1L_nt7Fe-EF3GVg9BA&oe=676B718D" // Replace with actual image URL
    },
    {
      "name": "Azer",
      "lastMessage": "Let's meet up tomorrow.",
      "time": "1:30 PM",
      "userPhoto":
      "https://scontent.ftun9-1.fna.fbcdn.net/v/t39.30808-1/326095936_740121707362877_562017269399807385_n.jpg?stp=dst-jpg_s200x200_tt6&_nc_cat=107&ccb=1-7&_nc_sid=e99d92&_nc_ohc=6wJoo9_O8icQ7kNvgFXgNnF&_nc_zt=24&_nc_ht=scontent.ftun9-1.fna&_nc_gid=Ayr2DPSeWIoyvmngR5udicc&oh=00_AYCvhJ2J6xQcnIWaNtMfL6iu-qrUPa3lJETSrihLRFC97Q&oe=676B471D" // Replace with actual image URL
    },
    {
      "name": "Adam",
      "lastMessage": "Check out this cool place!",
      "time": "3:15 PM",
      "userPhoto":
      "https://scontent.ftun9-1.fna.fbcdn.net/v/t39.30808-1/438081336_3643555262529973_3592491024185659053_n.jpg?stp=c0.0.1933.1933a_dst-jpg_s200x200_tt6&_nc_cat=107&ccb=1-7&_nc_sid=e99d92&_nc_ohc=UE7ObCLS7CgQ7kNvgHnAs_B&_nc_zt=24&_nc_ht=scontent.ftun9-1.fna&_nc_gid=AEIgM5kj8wufJT78tP33zzI&oh=00_AYAvn117chVHp2HnizKJPmwbY2PUb_1AGIC56VgwuPfjtA&oe=676B62F3" // Replace with actual image URL
    },
    {
      "name": "Anis",
      "lastMessage": "What time is the event?",
      "time": "4:00 PM",
      "userPhoto":
      "https://scontent.ftun9-1.fna.fbcdn.net/v/t39.30808-6/402652185_3971425686426311_4901327544766063296_n.jpg?_nc_cat=107&ccb=1-7&_nc_sid=127cfc&_nc_ohc=IBbnakAIu4AQ7kNvgG2pYv_&_nc_zt=23&_nc_ht=scontent.ftun9-1.fna&_nc_gid=A1FKlBiopnLhNNGiKwE7nqm&oh=00_AYCPL16TiTl6BJ3RLq990z5bZAG65zeU5EusqC2ihpfsLg&oe=676B4E1E" // Replace with actual image URL
    },
  ];

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
  Widget build(BuildContext context) {
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Chats",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Navigation Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                    isMessagesSelected ? Colors.grey : Colors.black,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.only(topRight: Radius.circular(20))),
                  ),
                  onPressed: () {
                    setState(() {
                      isMessagesSelected = true;
                    });
                  },
                  child: const Text(
                    "Messages",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor:
                    isMessagesSelected ? Colors.black : Colors.grey,
                    shape: const RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.only(topLeft: Radius.circular(20))),
                  ),
                  onPressed: () {
                    setState(() {
                      isMessagesSelected = false;
                    });
                  },
                  child: const Text(
                    "Forum",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.grey),

          // Display Messages Section or Forum Section
          Expanded(
            child: isMessagesSelected
                ? ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
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
                        backgroundImage: NetworkImage(
                            message['userPhoto']!), // Use specific photo
                        backgroundColor: Colors.grey[700],
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.yellow, width: 2),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            message['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            message['time']!,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        message['lastMessage']!,
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                      onTap: () {
                        // Navigate to the ChatPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                                userName: message['name']!,
                                userPhoto: message['userPhoto']!),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            )
                : ForumPage(), // Display ForumPage when Forum tab is selected
          ),
        ],
      ),
    );
  }
}