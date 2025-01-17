import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/global.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';


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

  // Function to fetch appointments from the API
  Future<List<dynamic>> _fetchAppointments() async {
    try {
      // Get the current user's email
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("No user is currently logged in.");
      }
      String docEmail = currentUser.email ?? "";

      // Make the API request
      final response = await http.get(
        Uri.parse(backend+'/api/consultation/consultations/doctor/$docEmail'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load appointments');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Your Appointments",
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
                _buildAppointmentsList('PENDING'),
                _buildAppointmentsList('COMPLETED'),
                _buildAppointmentsList('CANCELLED'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList(String status) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchAppointments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
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
                      "Patient: ${appointment['patientService']['name']}",
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                    ),
                    Text(
                      "Email: ${appointment['patientService']['email']}",
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
                      "Status: ${appointment['etatConsultation']}",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
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