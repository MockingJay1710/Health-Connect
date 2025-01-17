import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:http/http.dart' as http;
import '../../global.dart';
import 'package:intl/intl.dart';


class DoctorSchedule extends StatefulWidget {

  final String status;

  const DoctorSchedule({Key? key, required this.status}) : super(key: key);


  @override
  _ScheduleTab1State createState() => _ScheduleTab1State();
}

class _ScheduleTab1State extends State<DoctorSchedule > {

  late String userEmail;
  @override
  void initState() {
    super.initState();
    userEmail = FirebaseAuth.instance.currentUser?.email ?? ''; // Get current user email
  }

  Future<List<Map<String, dynamic>>> fetchAppointments() async {
    try {
      final response = await http.get(
        Uri.parse(backend+'/api/consultation/consultations/doctor/$userEmail/${widget.status}'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          return {
            'id': item['id'],
            'patientName': item['patientService']['name'],
            'email': item['patientService']['email'],
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

  Future<void> _acceptAppointment(int appointmentId) async {
    try {
      final response = await http.patch(
        Uri.parse(backend + '/api/consultation/accept/$appointmentId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': 'Completed'}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Appointment marked as completed.")),
        );
        setState(() {}); // Refresh UI after updating
      } else {
        throw Exception("Failed to accept appointment: ${response.body}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error accepting appointment: $e")),
      );
    }
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
                        "Patient: ${appointment['patientName']}",
                        style: GoogleFonts.poppins(fontSize: 16.sp),
                      ),
                      Text(
                        "Email: ${appointment['email']}",
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
                          if (appointment['status'] == 'Pending')
                            ElevatedButton(
                              onPressed: () => _acceptAppointment(appointment['id']),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.green,
                              ),
                              child: const Text('Accept'),
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
