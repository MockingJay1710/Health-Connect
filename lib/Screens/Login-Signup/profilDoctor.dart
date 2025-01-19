import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/ProfilMedical.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ProfileDoctor extends StatelessWidget {
  const ProfileDoctor({super.key});

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
      backgroundColor: Colors.white,
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
                // Profile Header
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade500],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                    child: Column(
                      children: [
                        // Profile Picture
                        Stack(
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
                                  border: Border.all(width: 2, color: Colors.white),
                                  color: Colors.blue.shade700,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          name,
                          style: GoogleFonts.poppins(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          email,
                          style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

                // Profile Details Section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ProfileDetailRow(
                        icon: Icons.phone,
                        title: "Phone",
                        value: phoneNumber,
                      ),
                      ProfileDetailRow(
                        icon: Icons.cake,
                        title: "Date of Birth",
                        value: dateNaissance,
                      ),
                    ],
                  ),
                ),

                // Links Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ProfileListItem(
                        icon: Icons.medical_services,
                        title: "Medecines",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProfilMedical(patientEmail: patientEmail),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ProfileListItem(
                        icon: Icons.favorite,
                        title: "My Saved",
                      ),
                      const Divider(),
                      ProfileListItem(
                        icon: Icons.calendar_today,
                        title: "Appointments",
                      ),
                      const Divider(),
                      ProfileListItem(
                        icon: Icons.settings,
                        title: "Settings",
                      ),
                      const SizedBox(height: 20),
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

class ProfileListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const ProfileListItem({
    Key? key,
    required this.icon,
    required this.title,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue.shade700, size: 30),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      onTap: onTap,
    );
  }
}

class ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileDetailRow({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 15),
          Text(
            "$title: ",
            style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.black54),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
