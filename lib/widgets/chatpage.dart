import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String userName;
  final String userPhoto; // Add userPhoto parameter

  const ChatPage({
    super.key,
    required this.userName,
    required this.userPhoto, // Required for the image
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final List<String> messages = [];
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage:
              NetworkImage(widget.userPhoto), // Use the passed photo URL
              backgroundColor: Colors.grey[700],
            ),
            const SizedBox(width: 12.0),
            Text(
              widget.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.yellow[700],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                      ),
                    ),
                    child: Text(
                      messages[index],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Field, Upload Button, and Send Button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Upload Icon Button
                IconButton(
                  icon: const Icon(
                    Icons.photo,
                    color: Colors.yellow,
                    size: 30,
                  ),
                  onPressed: () {
                    // Upload functionality can be added here
                  },
                ),

                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Send Icon Button
                IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.yellow,
                    size: 30,
                  ),
                  onPressed: () {
                    if (messageController.text.isNotEmpty) {
                      setState(() {
                        messages.insert(0, messageController.text);
                      });
                      messageController.clear();
                      _scrollToBottom();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}