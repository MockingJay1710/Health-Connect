import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:medical/Screens/Views/chat_screen.dart';
import 'package:medical/Screens/Widgets/message_all_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../global.dart';

class MessageTabAll extends StatefulWidget {
  const MessageTabAll({Key? key}) : super(key: key);

  @override
  _MessageTabAllState createState() => _MessageTabAllState();
}

class _MessageTabAllState extends State<MessageTabAll> {
  List<Map<String, String>> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final String senderEmail = currentUser.email ?? "";

      // API to fetch conversations by sender email
      final url = '$backend/api/conversations/$senderEmail';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<Map<String, String>> conversationList = [];

        // Loop through the conversations data
        for (var conversation in data) {
          // Extract sender email from the first message
          String senderEmail = '';
          if (conversation['messages'] != null && conversation['messages'].isNotEmpty) {
            senderEmail = conversation['messages'][0]['senderMail'] ?? '';
          }

          // Create a map for each conversation
          conversationList.add({
            'senderEmail': senderEmail,
            'time': formatRandomDate(), // Generate a random date for display
          });
        }

        // Update state with fetched conversations
        setState(() {
          conversations = conversationList;
          isLoading = false;
        });
      } else {
        throw Exception("Failed to fetch conversations: ${response.body}");
      }
    } catch (e) {
      print("Error fetching conversations: $e");
      setState(() {
        isLoading = false;
      });
    }
  }
  // Helper function to generate a random time (random date)
  String formatRandomDate() {
    final randomHour = (DateTime.now().hour + (DateTime.now().second % 10)) % 24;
    final randomMinute = DateTime.now().minute + (DateTime.now().second % 10);
    return "${randomHour}:${randomMinute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: SizedBox(),
        title: Text(
          "Messages",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : conversations.isEmpty
          ? Center(child: Text("No conversations found."))
          : ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];

          return GestureDetector(
            onTap: () {
              // Navigate to chat screen
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop,
                  child: chat_screen(
                    image: "lib/icons/default-user.png", // Placeholder image
                    name: conversation['senderEmail']!,
                    receiverEmail: conversation['senderEmail']!,
                  ),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage("lib/icons/default-user.png"), // Placeholder image
              ),
              title: Text(
                conversation['senderEmail']!,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                "Tap to chat",
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Text(
                conversation['time']!,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
