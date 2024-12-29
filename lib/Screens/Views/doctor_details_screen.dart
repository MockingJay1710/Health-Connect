import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/chat_screen.dart';
import 'package:medical/Screens/Widgets/TabbarPages/message_tab_all.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class DoctorDetails extends StatelessWidget {
  final String doctorName;
  final String specialty;
  final String rating;
  final String distance;
  final String image;

  const DoctorDetails({
    Key? key,
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.image,
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            height: 10,
            width: 10,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/icons/back1.png"),
              ),
            ),
          ),
        ),
        title: Text(
          "Doctor Details",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  image,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctorName,
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      specialty,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      "Rating: $rating",
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      distance,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              "About",
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Dr. $doctorName is a highly experienced $specialty with a track record of excellent patient care and service.",
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                  onPressed: () async {
                    try {
                      // Get the current user's email
                      final User? currentUser = FirebaseAuth.instance.currentUser;
                      if (currentUser == null) {
                        throw Exception("User not logged in");
                      }
                      final String userEmail = currentUser.email ?? "";

                      // Query Firestore to find the user document by email
                      final QuerySnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
                          .collection('users')
                          .where('email', isEqualTo: userEmail)
                          .get();

                      if (userSnapshot.docs.isEmpty) {
                        throw Exception("No user found with email: $userEmail");
                      }

                      // Get the user's document ID
                      final String userId = userSnapshot.docs.first.id;

                      // Create doctor object
                      Map<String, dynamic> selectedDoctor = {
                        'image': image,
                        'name': doctorName,
                        'specialty': specialty,
                        'rating': rating,
                        'distance': distance,
                        'contactedAt': Timestamp.now(), // Store timestamp for when they were contacted
                      };

                      // Add the doctor to Firestore under the user's `contactedDoctors` subcollection
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('contactedDoctors')
                          .add(selectedDoctor);

                      // Navigate to the chat screen
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: chat_screen(
                            image: image,
                            name: doctorName, receiverEmail: '',

                          ),
                        ),
                      );
                    } catch (e) {
                      // Handle errors gracefully
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Error: ${e.toString()}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },

                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "Start Chat",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}
