import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Widgets/profile_list.dart';
import 'package:medical/Screens/Views/ProfilMedical.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Profile_screen extends StatelessWidget {

  const Profile_screen({super.key});

  Future<Map<String, dynamic>> getUserData() async {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    if (userEmail != null) {
      var userQuerySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .get();

      if (userQuerySnapshot.docs.isNotEmpty) {
        return userQuerySnapshot.docs.first.data();
      } else {
        throw Exception('User not found');
      }
    } else {
      throw Exception('No user logged in');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 226, 215),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          // Extract user data from snapshot
          var userData = snapshot.data!;
          String name = userData['name'] ?? 'Unknown';
          String email = userData['email'] ?? '';
          String phoneNumber = userData['phoneNumber'] ?? '';
          String profileImageBase64 = userData['profileImageBase64'] ?? '';
          String dateNaissance = userData['dateNaissance'] ?? 'Unknown';

          // Use default avatar if no profile image is available
          ImageProvider profileImageProvider;
          if (profileImageBase64.isEmpty) {
            profileImageProvider = const AssetImage('lib/icons/avatar.png');
          } else {
            Uint8List decodedBytes = base64Decode(profileImageBase64);
            profileImageProvider = MemoryImage(decodedBytes);
          }
          User? currentUser = FirebaseAuth.instance.currentUser;
          String? patientEmail = currentUser?.email;

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          border: Border.all(width: 4, color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              spreadRadius: 2,
                              blurRadius: 10,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: profileImageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(width: 1, color: Colors.white),
                            color: Colors.white,
                            image: const DecorationImage(
                              image: AssetImage("lib/icons/camra.png"),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Email: $email",
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  "Phone: $phoneNumber",
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                ),

                const SizedBox(height: 10),
                Text(
                  "Date of Birth: $dateNaissance",
                  style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white),
                ),
                const SizedBox(height: 30),
                // Profile Links Section
                Container(
                  height: 550,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),
                      profile_list(
                        image: "lib/icons/pngegg.png",
                        title: "My Medical Profile",
                        color: Colors.black87,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilMedical(patientEmail: patientEmail),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      const profile_list(
                        image: "lib/icons/heart2.png",
                        title: "My Saved",
                        color: Colors.black87,
                      ),
                      const Divider(),
                      const profile_list(
                        image: "lib/icons/appoint.png",
                        title: "Appointments",
                        color: Colors.black87,
                      ),
                      const Divider(),
                      const profile_list(
                        image: "lib/icons/setting.png",
                        title: "Settings",
                        color: Colors.black87,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
