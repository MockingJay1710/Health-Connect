import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/HomeDoctor.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'Homepage.dart';

class DoctorAppointments extends StatefulWidget {
  @override
  State<DoctorAppointments> createState() => _DoctorAppointmentsState();
}

class _DoctorAppointmentsState extends State<DoctorAppointments> with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  // Function to cancel an appointment
  Future<void> _cancelAppointment(DocumentSnapshot appointment) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(appointment.id).update({
        'status': 'Cancelled',
      });
      print('Appointment cancelled successfully');
    } catch (e) {
      print('Failed to cancel appointment: $e');
    }
  }

  // Function to accept an appointment
  Future<void> _acceptAppointment(DocumentSnapshot appointment) async {
    try {
      await FirebaseFirestore.instance.collection('appointments').doc(appointment.id).update({
        'status': 'Accepted',
      });
      print('Appointment accepted successfully');
    } catch (e) {
      print('Failed to accept appointment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeDoctor()), // Navigate to Homepage
            );
          },
        ),
        title: Text(
          "Your Appointements Demands",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 235, 235, 235)),
                color: Color.fromARGB(255, 241, 241, 241),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.all(5),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: Color.fromARGB(255, 177, 124, 241),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  controller: tabController,
                  tabs: const [
                    Tab(text: "Pending"),
                    Tab(text: "Completed"),
                    Tab(text: "Cancelled"),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                _buildAppointmentsList(userEmail, 'Pending'),
                _buildAppointmentsList(userEmail, 'Completed'),
                _buildAppointmentsList(userEmail, 'Cancelled'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the appointment list for a specific status
  Widget _buildAppointmentsList(String userEmail, String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('appointments')
          .where('email', isEqualTo: userEmail)  // Query by user email
          .where('status', isEqualTo: status)  // Filter by status
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
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (appointment['status'] == 'Pending')
                          ElevatedButton(
                            onPressed: () => _acceptAppointment(appointment),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                            child: const Text('Accept'),
                          ),
                        const SizedBox(width: 10),
                        if (appointment['status'] == 'Pending')
                          ElevatedButton(
                            onPressed: () => _cancelAppointment(appointment),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: const Text('Cancel'),
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
    );
  }
}
