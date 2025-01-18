import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../global.dart';
import 'ProfilMedical.dart';

class Dashdoctor extends StatefulWidget {

  const Dashdoctor({super.key});

  @override
  _DashdoctorState createState() => _DashdoctorState();
}

class _DashdoctorState extends State<Dashdoctor>
{  List<dynamic> patients = [];bool isLoadingPatients = true;

String? doctorName;
  List<dynamic> allAppointments = [];
  List<dynamic> filteredAppointments = [];
  DateTime selectedDate = DateTime.now();
  int numberOfPatients = 0;
  int pendingAppointments = 0;
  int completedAppointments = 0;
  List<DateTime> appointmentDates = [];



  @override
  void initState() {
    super.initState();
    fetchDoctorName();
    fetchAllAppointments();
    fetchAppointmentsByStatus('Pending');
    fetchAppointmentsByStatus('Completed');
    fetchPatients();

  }

Widget _buildPatientsSection() {

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        "Your Patients",
        style: GoogleFonts.inter(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      const SizedBox(height: 10),
      Container(
        height: 1,
        color: Colors.grey[300], // Separation line
      ),
      const SizedBox(height: 10),
      isLoadingPatients
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: patients.map((patient) {
          return _buildPatientCard(patient);
        }).toList(),
      ),
    ],
  );
}



Future<void> fetchPatients() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? userEmail = currentUser?.email;

      if (userEmail == null) return;

      final response = await http.get(Uri.parse('$backend/api/doctors/$userEmail/patients'));

      if (response.statusCode == 200) {
        setState(() {
          patients = json.decode(response.body);
          isLoadingPatients = false; // Set loading to false after fetching
        });
      } else {
        print("Failed to fetch patients: ${response.body}");
      }
    } catch (e) {
      print("Error fetching patients: $e");
    }
  }


  Future<void> fetchDoctorName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? email = currentUser?.email;

      if (email != null) {
        var userQuerySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

        setState(() {
          var userdata = userQuerySnapshot.docs.first.data();
          doctorName = userdata?['name'] ?? "Doctor";
        });
      }
    } catch (e) {
      print("Error fetching doctor name: $e");
    }
  }

  Future<void> fetchAllAppointments() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? docEmail = currentUser?.email;

      if (docEmail == null) return;

      final response = await http.get(Uri.parse(
          '$backend/api/consultation/consultations/doctor/$docEmail'));

      if (response.statusCode == 200) {
        setState(() {
          allAppointments = json.decode(response.body);
          appointmentDates = allAppointments
              .map<DateTime>((appointment) =>
              DateTime.parse(appointment['date']))
              .toList();
          filterAppointmentsByDate(selectedDate);
        });
      } else {
        print("Failed to fetch appointments: ${response.body}");
      }
    } catch (e) {
      print("Error fetching appointments: $e");
    }
  }

  Future<void> fetchAppointmentsByStatus(String status) async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      String? userEmail = currentUser?.email;

      if (userEmail == null) return;

      final response = await http.get(
        Uri.parse(
            '$backend/api/consultation/consultations/doctor/$userEmail/$status'),
      );

      if (response.statusCode == 200) {
        setState(() {
          if (status == 'Pending') {
            // Filter today's pending appointments
            pendingAppointments = json.decode(response.body).where((appointment) {
              DateTime appointmentDate = DateTime.parse(appointment['date']);
              return appointmentDate.year == DateTime.now().year &&
                  appointmentDate.month == DateTime.now().month &&
                  appointmentDate.day == DateTime.now().day;
            }).toList().length;
          } else if (status == 'Completed') {
            completedAppointments = json.decode(response.body).length;
          }
        });
      } else {
        print("Failed to fetch appointments by status: ${response.body}");
      }
    } catch (e) {
      print("Error fetching appointments by status: $e");
    }
  }

  void filterAppointmentsByDate(DateTime date) {
    setState(() {
      filteredAppointments = allAppointments
          .where((appointment) {
        var appointmentDate = DateTime.parse(appointment['date']);
        return appointmentDate.year == date.year &&
            appointmentDate.month == date.month &&
            appointmentDate.day == date.day;
      })
          .toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Hi, Dr. ${doctorName ?? 'Loading...'}",
          style: GoogleFonts.inter(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: Colors.lightBlue,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildProfileCard(),  // Updated Profile Card
              const SizedBox(height: 20),
              _buildStatsRow(),
              const SizedBox(height: 20),
              _buildNotificationsSection(),
              const SizedBox(height: 20),
              _buildCalendar(),
              const SizedBox(height: 20),
              _buildAppointmentsList(),
              const SizedBox(height: 20),
              _buildPatientsSection(),  // Section for Patients
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProfileCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('images/doctor1.png'), // Replace with a real image
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dr. ${doctorName ?? 'Loading...'}",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Specialist in Cardiology", // Replace with dynamic specialization
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatsCard(
          icon: Icons.person,
          title: "Patients",
          value: numberOfPatients.toString(),
          onTap: () {
            // Navigate to patients screen
          },
        ),
        _buildStatsCard(
          icon: Icons.pending,
          title: "Pending",
          value: pendingAppointments.toString(),
          onTap: () {
            // Navigate to pending appointments screen
          },
        ),
        _buildStatsCard(
          icon: Icons.check_circle,
          title: "Completed",
          value: completedAppointments.toString(),
          onTap: () {
            // Navigate to completed appointments screen
          },
        ),
      ],
    );
  }

  Widget _buildStatsCard(
      {required IconData icon,
        required String title,
        required String value,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.lightBlue.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Icon(icon, size: 24.sp, color: Colors.lightBlue),
              const SizedBox(height: 5),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notifications",
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Text(
              "You have $pendingAppointments new appointment requests today.",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.black.withOpacity(0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.lightBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Select a Day",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = selectedDate.add(Duration(days: index - selectedDate.weekday + 1));
              final isSelected = day.year == selectedDate.year &&
                  day.month == selectedDate.month &&
                  day.day == selectedDate.day;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedDate = day;
                  });
                  filterAppointmentsByDate(day);
                },
                child: Container(
                  width: 40, // Width for each day widget
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.lightBlue : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat('EEE').format(day), // Weekday abbreviation
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        day.day.toString(), // Day number
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    return filteredAppointments.isEmpty
        ? Center(
      child: Text(
        "No appointments for ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
        style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.grey),
      ),
    )
        : Column(
      children: filteredAppointments.map((appointment) {
        return Card(
          elevation: 5,
          margin: const EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.lightBlue,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(
              appointment['patientName'] ?? "Patient",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              "Time: ${appointment['time']}\nStatus: ${appointment['etatConsultation']}",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: Colors.grey,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.arrow_forward, color: Colors.lightBlue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilMedical(
                      patientEmail: appointment['patientEmail'],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

Widget _buildPatientCard(Map<String, dynamic> patient) {
  return Card(
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.greenAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                patient['name'] ?? 'No name available',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Date of Birth: ${patient['dateNaissance'] ?? 'Unknown'}",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "Phone: ${patient['phone_number'] ?? 'Unknown'}",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
