import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class Dashdoctor extends StatelessWidget {
  const Dashdoctor({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user's email
    String? userEmail = FirebaseAuth.instance.currentUser?.email;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        toolbarHeight: 130,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                // Query Firestore for the doctor's profile image and name
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: userEmail)  // Query by the email field
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No data found.");
                    }

                    var doctorData = snapshot.data!.docs.first;
                    String doctorName = doctorData['name'] ?? "Dr. Unknown";
                    String profileImageBase64 = doctorData['profileImageBase64'] ?? "";
                    String profileImage = profileImageBase64.isEmpty
                        ? 'lib/icons/doctor_profile.png'
                        : profileImageBase64;

                    return Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage(profileImage),
                          radius: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Bonjour Docteur",
                              style: GoogleFonts.inter(
                                  fontSize: 16.sp,
                                  color: const Color.fromARGB(255, 51, 47, 47),
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              doctorName,
                              style: GoogleFonts.inter(
                                  fontSize: 20.sp,
                                  color: const Color.fromARGB(255, 3, 190, 150),
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            IconButton(
              onPressed: () {
                // Notification action here
              },
              icon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.06,
                  child: Image.asset(
                    "lib/icons/bell.png",
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              iconSize: 5,
            ),
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
              // Query the patients from Firestore
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'Patient') // Query for patients
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
                      // Use default avatar if no profile image is available
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
