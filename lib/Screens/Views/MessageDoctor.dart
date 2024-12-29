
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/chat_screen.dart';


import 'package:medical/Screens/Widgets/message_all_widget.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class message_tab_all extends StatefulWidget {
  const message_tab_all({Key? key}) : super(key: key);

  @override
  TabBarExampleState createState() => TabBarExampleState();
}

class TabBarExampleState extends State<message_tab_all> {
  List<Map<String, String>> doctors = [
    {
      'image': "lib/icons/male-doctor.png",
      'name': "Dr. Marcus Horizon",
      'message': "I don't have any fever, but headache...",
      'time': "10.24",
      'message_count': "2",
    },
    {
      'image': "lib/icons/docto3.png",
      'name': "Dr. Alysa Hana",
      'message': "Hello, How can I help you?",
      'time': "10.24",
      'message_count': "1",
    },
    {
      'image': "lib/icons/doctor2.png",
      'name': "Dr. Maria Elena",
      'message': "Do you have fever?",
      'time': "10.24",
      'message_count': "3",
    },
  ];


  @override
  void initState() {
    super.initState();
    fetchContactedDoctors();
  }

  // Fetch contacted doctors for the logged-in user
  // Fetch contacted doctors for the logged-in user
  Future<void> fetchContactedDoctors() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      final String userEmail = currentUser.email ?? "";

      // Find the user document by email
      final QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userSnapshot.docs.isEmpty) {
        throw Exception("No user found with the email: $userEmail");
      }

      final String userId = userSnapshot.docs.first.id;

      // Fetch the `contactedDoctors` subcollection for the located user
      final QuerySnapshot<Map<String, dynamic>> doctorsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('contactedDoctors')
          .get();

      // Convert the fetched doctors into a list of maps
      final List<Map<String, String>> fetchedDoctors = doctorsSnapshot.docs.map((doc) {
        final data = doc.data();

        // Safely cast fields to String and handle missing fields
        return {
          'image': data['image']?.toString() ?? '',
          'name': data['name']?.toString() ?? '',
          'message': "Start chatting", // Placeholder message
          'time': formatTimestamp(data['contactedAt']), // Convert Timestamp to readable format
          'message_count': "0", // Placeholder for message count
        };
      }).toList();

      // Update the state to include fetched doctors
      setState(() {
        doctors.addAll(fetchedDoctors); // Add the fetched doctors to the existing list
      });
    } catch (e) {
      print("Error fetching contacted doctors: $e");
      // Handle the error appropriately
    }
  }

// Helper function to format Firestore Timestamp to readable time
  String formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final DateTime dateTime = timestamp.toDate();
      return "${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}"; // Format as hh:mm
    }
    return "Now"; // Default time if timestamp is null or invalid
  }





  void addDoctor(Map<String, String> doctor) {
    setState(() {
      doctors.add(doctor); // Add the doctor to the list permanently
    });

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
        actions: [

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
              },
              child: Image.asset(
                "lib/icons/bell.png",
                height: 24,
                width: 24,

              ),
            ),
          ),
        ],
      ),

      body: ListView.builder(
        itemCount: doctors.length,
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return GestureDetector(
            onTap: () {
              // Navigate to chat screen with image and name

              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.bottomToTop,

                  child: chat_screen(
                    image: doctor['image']!,
                    name: doctor['name']!,
                    receiverEmail: doctor['name']!,
                  ),

                ),
              );
            },
            child: message_all_widget(
              image: doctor['image']!,
              Maintext: doctor['name']!,
              subtext: doctor['message']!,
              time: doctor['time']!,
              message_count: doctor['message_count']!,
            ),
          );
        },
      ),
    );
  }
}

