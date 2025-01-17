import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import '../../global.dart';
import 'package:intl/intl.dart';


class shedule_tab1 extends StatefulWidget {

  final String status;

  const shedule_tab1({Key? key, required this.status}) : super(key: key);


  @override
  _ScheduleTab1State createState() => _ScheduleTab1State();
}

class _ScheduleTab1State extends State<shedule_tab1 > {

  late String userEmail;
  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email ?? ''; // Get current user email
  }

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    try {
      final response = await http.get(
        Uri.parse(backend+'/api/consultation/consultations/patient/$userEmail/${widget.status}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            'id': item['id'],
            'doctorName': item['docteurService']['name'],
            'specialty': item['docteurService']['specialiteDocteur'],
            'date': item['date'],
            'time': item['time'],
            'status': item['etatConsultation'],
          };
        }).toList();
      } else {
        throw Exception("Failed to fetch appointments: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error fetching appointments: $e");
    }
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    try {
      final response = await http.patch(
        Uri.parse(backend+'/api/consultation/cancel/$appointmentId'),
      );

      if (response.statusCode == 200) {
        setState(() {}); // Refresh UI after cancellation
      } else {
        throw Exception("Failed to cancel appointment: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error canceling appointment: $e")),
      );
    }
  }

  Future<void> _rescheduleAppointment(int appointmentId) async {
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
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    dateController.text = pickedDate.toString().substring(0, 10);
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
                  final DateFormat inputFormat = DateFormat("h:mm a"); // For input like "2:30 PM"
                  final DateFormat outputFormat = DateFormat("HH:mm"); // Converts to "14:30"
                  final String formattedTime =
                  outputFormat.format(inputFormat.parse(timeController.text));
                  final response = await http.put(
                    Uri.parse(backend+
                        '/api/consultation/reschedule/${dateController.text}/${formattedTime}/$appointmentId'));
                  if (response.statusCode == 200) {
                    Navigator.pop(context);
                    setState(() {}); // Refresh UI after rescheduling
                  } else {
                    throw Exception("Failed to reschedule: ${response.body}");
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error rescheduling: $e")),
                  );
                }
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.red),
              ),
            );
          }

          var appointments = snapshot.data ?? [];

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
                        "Doctor: ${appointment['doctorName']}",
                        style: GoogleFonts.poppins(fontSize: 16.sp),
                      ),
                      Text(
                        "Specialty: ${appointment['specialty']}",
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
                        style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          if (appointment['status'] == 'Pending')
                            ElevatedButton(
                              onPressed: () => _cancelAppointment(appointment['id']),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                              child: const Text('Cancel'),
                            ),
                          const SizedBox(width: 10),
                          if (appointment['status'] != 'Cancelled')
                            ElevatedButton(
                              onPressed: () => _rescheduleAppointment(appointment['id']),
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
