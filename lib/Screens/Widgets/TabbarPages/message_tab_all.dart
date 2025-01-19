import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/chat_screen.dart';
import 'package:medical/Screens/Widgets/message_all_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../global.dart';

class message_tab_all extends StatefulWidget {
  const message_tab_all({Key? key}) : super(key: key);

  @override
  _MessageTabAllState createState() => _MessageTabAllState();
}

class _MessageTabAllState extends State<message_tab_all> {
  List<Map<String, String>> conversations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  // Fetch conversations from the API
  Future<void> fetchConversations() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final String userEmail = currentUser.email ?? "";

      // Replace this with your backend API URL
      final url = '$backend/api/conversations/$userEmail'; // Update URL

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        List<Map<String, String>> conversationList = [];

        // Loop through the conversations data and extract necessary info
        for (var conversation in data) {
          String receiverEmail = '';
          String senderEmail = '';
          int messageCount = 0;
          String time = formatRandomDate(); // Generate random time for display

          if (conversation['messages'] != null && conversation['messages'].isNotEmpty) {
            senderEmail = conversation['messages'][0]['senderMail'] ?? ''; // Get senderEmail
            messageCount = conversation['messages'].length;
            receiverEmail = conversation['messages'][0]['recipientMail'] ?? '';// Get the message count (length of the messages list)
          }

          conversationList.add({
            'receiverEmail': receiverEmail,
            'senderEmail': senderEmail, // Store senderEmail
            'time': time,
            'message_count': messageCount.toString(), // Store message count as a string
          });
        }

        setState(() {
          conversations = conversationList; // Update the conversations list
          isLoading = false; // Data is loaded
        });
      } else {
        throw Exception("Failed to fetch conversations: ${response.body}");
      }
    } catch (e) {
      print("Error fetching conversations: $e");
      setState(() {
        isLoading = false; // Set loading to false on error
      });
    }
  }

  // Helper function to generate a random time
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
          : ListView.builder(
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          return GestureDetector(
            onTap: () {
              // Navigate to chat screen with sender email
              if (conversation['senderEmail'] != null) {
                Navigator.push(
                  context,
                  PageTransition(
                    type: PageTransitionType.bottomToTop,
                    child: chat_screen(
                      image: 'lib/icons/default-doctor.png', // Placeholder image
                      name: 'Unknown', // Placeholder name
                      receiverEmail: conversation['senderEmail']!, // Pass senderEmail instead of receiverEmail
                    ),
                  ),
                );
              } else {
                print('Conversation data is missing');
              }
            },
            child: message_all_widget(
              image: 'lib/icons/default-doctor.png', // Placeholder image
              Maintext: conversation['receiverEmail'] ?? 'Unknown', // Display sender email as the main text
              subtext: 'Start chatting', // Placeholder text
              time: conversation['time'] ?? 'Now', // Display random time
              message_count: conversation['message_count'] ?? '0', // Display message count
            ),
          );
        },
      ),
    );
  }
}
