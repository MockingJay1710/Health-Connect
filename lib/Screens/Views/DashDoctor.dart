import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'ProfilMedical.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Dashdoctor extends StatelessWidget {
  const Dashdoctor({super.key});

  @override
  Widget build(BuildContext context) {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Row(
          children: [
            // Doctor's profile details
            // ...
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                "Your Patients",
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color.fromARGB(255, 46, 46, 46),
                ),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'Patient')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  var patients = snapshot.data?.docs ?? [];

                  return patients.isEmpty
                      ? Center(
                    child: Text(
                      "No patients found.",
                      style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: patients.length,
                    itemBuilder: (context, index) {
                      var patient = patients[index];
                      String profileImageBase64 = patient['profileImageBase64'];
                      String profileImage = profileImageBase64.isEmpty
                          ? 'lib/icons/avatar.png'
                          : profileImageBase64;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(10),
                          leading: CircleAvatar(
                            backgroundImage: AssetImage(profileImage),
                            radius: 25,
                          ),
                          title: Text(
                            patient['name'] ?? "Patient ${index + 1}",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Birthdate: ${patient['dateNaissance']}",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color.fromARGB(255, 117, 117, 117),
                                ),
                              ),
                              Text(
                                "Email: ${patient['email']}",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: const Color.fromARGB(255, 117, 117, 117),
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Navigate to the ProfilMedical page with the patient's email
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfilMedical(
                                  patientEmail: patient['email'],
                                ),
                              ),
                            );
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              // Action for menu items
                            },
                            itemBuilder: (BuildContext context) {
                              return {'View Details', 'Edit', 'Remove'}
                                  .map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                            child: const Icon(Icons.more_vert),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
