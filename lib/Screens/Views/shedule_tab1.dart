import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class shedule_tab1 extends StatefulWidget {

  final String status; // Add a status parameter

  const shedule_tab1({Key? key, required this.status}) : super(key: key);


  @override
  _ScheduleTab1State createState() => _ScheduleTab1State();
}

class _ScheduleTab1State extends State<shedule_tab1 > {
  late FirebaseAuth _auth;
  late FirebaseFirestore _firestore;
  late String userEmail;

  @override
  void initState() {
    super.initState();
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;
    userEmail = _auth.currentUser?.email ?? ''; // Get current user email
  }

  void _cancelAppointment(DocumentSnapshot appointment) {
    _firestore.collection('appointments').doc(appointment.id).update({
      'status': 'Cancelled',
    });
  }

  void _rescheduleAppointment(DocumentSnapshot appointment) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reschedule Appointment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Reschedule for: ${appointment['doctor']}"),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      dateController.text =
                          pickedDate.toString().substring(0, 10);
                    });
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
                    setState(() {
                      timeController.text = pickedTime.format(context);
                    });
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
              onPressed: () {
                _firestore.collection('appointments')
                    .doc(appointment.id)
                    .update({
                  'date': dateController.text,
                  'time': timeController.text,
                  'status': 'Pending', // Reset status to "Pending"
                });
                Navigator.pop(context);
              },
              child: const Text("Save Changes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
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
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('appointments')
            .where('userEmail', isEqualTo: userEmail) // Query by user email
            .where(
            'status', isEqualTo: widget.status) // Filter by passed status
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          var appointments = snapshot.data?.docs ?? [];

          return appointments.isEmpty
              ? Center(
            child: Text(
              "No appointments available.",
              style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: appointments.length,
            itemBuilder: (context, i) {
              var appointment = appointments[i];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Doctor: ${appointment['doctor']}",
                        style: GoogleFonts.poppins(fontSize: 16.sp),
                      ),
                      Text(
                        "Speciality: ${appointment['speciality']}",
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      Text(
                        "Date: ${appointment['date']}",
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      Text(
                        "Time: ${appointment['time']}",
                        style: GoogleFonts.poppins(fontSize: 14.sp),
                      ),
                      Text(
                        "Status: ${appointment['status']}",
                        style: GoogleFonts.poppins(
                            fontSize: 14.sp, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (appointment['status'] == 'Pending')
                            ElevatedButton(
                              onPressed: () => _cancelAppointment(appointment),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Cancel'),
                            ),
                          const SizedBox(width: 10),
                          if (appointment['status'] != 'Cancelled')
                            ElevatedButton(
                              onPressed: () =>
                                  _rescheduleAppointment(appointment),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.blue,
                              ),
                              child: const Text('Reschedule'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}