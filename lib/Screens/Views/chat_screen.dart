import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../global.dart';

class chat_screen extends StatefulWidget {
  final String image;
  final String name;
  final String receiverEmail;

  chat_screen({
    required this.image,
    required this.name,
    required this.receiverEmail,
  });

  @override
  _chat_screenState createState() => _chat_screenState();
}

class _chat_screenState extends State<chat_screen> {
  final TextEditingController messageController = TextEditingController();
  List<dynamic> messages = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    initializeConversation();
    fetchMessages();// Initialize conversation on view load
  }

  Future<void> initializeConversation() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    var senderEmail = currentUser?.email;

    final conversation = {
      "id": {
        "senderEmail": senderEmail,
        "receiverEmail": widget.receiverEmail,
      },
      "messages": []
    };

    final url = '$backend/api/conversations/save';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(conversation),
      );

      if (response.statusCode == 200) {
        print("Conversation initialized successfully");
      } else {
        print("Failed to initialize conversation: ${response.body}");
      }
    } catch (e) {
      print("Error initializing conversation: $e");
    }
  }

  Future<void> fetchMessages() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    var senderEmail = currentUser?.email;
    final url = '$backend/api/conversations/${widget.receiverEmail}/$senderEmail/messages';

    try {
      setState(() {
        isLoading = true;
      });

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          messages = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("Failed to fetch messages: ${response.body}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching messages: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendMessage() async {
    if (messageController.text.isNotEmpty) {
      User? currentUser = FirebaseAuth.instance.currentUser;
      var senderEmail = currentUser?.email;

      final message = {
        "content": messageController.text,
        "senderMail": senderEmail,
        "recipientMail": widget.receiverEmail,
      };

      final url =
          '$backend/api/conversations/${widget.receiverEmail}/$senderEmail/addMessage';

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          messageController.clear();
          await fetchMessages(); // Fetch messages after adding a new one
        } else {
          print("Failed to send message: ${response.body}");
        }
      } catch (e) {
        print("Error sending message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.name),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CircleAvatar(
              backgroundImage: AssetImage(widget.image),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : messages.isEmpty
                ? Center(child: Text("No messages yet."))
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['senderMail'] ==
                    FirebaseAuth.instance.currentUser?.email;

                return ListTile(
                  title: Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Colors.blueAccent
                            : Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        message['content'] ?? '',
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
