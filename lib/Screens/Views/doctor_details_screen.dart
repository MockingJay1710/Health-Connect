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
  final String docEmail;

  const DoctorDetails({
    Key? key,
    required this.doctorName,
    required this.specialty,
    required this.rating,
    required this.distance,
    required this.image,
    required this.docEmail,
  }) : super(key: key);

  Future<void> _addAppointment(BuildContext context) async {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Appointment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    dateController.text =
                        pickedDate.toString().substring(0, 10);
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: dateController,
                    decoration: const InputDecoration(labelText: 'Select Date'),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    timeController.text = pickedTime.format(context);
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: timeController,
                    decoration: const InputDecoration(labelText: 'Select Time'),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  final User? currentUser =
                      FirebaseAuth.instance.currentUser;
                  if (currentUser == null) {
                    throw Exception("User not logged in");
                  }
                  final String userEmail = currentUser.email ?? "";

                  final appointmentData = {
                    'userEmail': userEmail,
                    'doctor': doctorName,
                    'speciality': specialty,
                    'date': dateController.text,
                    'time': timeController.text,
                    'status': 'Pending',
                  };

                  await FirebaseFirestore.instance
                      .collection('appointments')
                      .add(appointmentData);
                  print(docEmail);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Appointment added successfully."),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Error: ${e.toString()}"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text("Add Appointment"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Start chat logic
                      Navigator.push(
                        context,
                        PageTransition(
                          type: PageTransitionType.bottomToTop,
                          child: chat_screen(
                            image: image,
                            name: doctorName,
                            receiverEmail: '', // Adjust as necessary
                          ),
                        ),
                      );
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
                  const SizedBox(width: 10),
                  IconButton(
                    icon: Icon(Icons.add, color: Colors.blue, size: 30),
                    onPressed: () => _addAppointment(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}