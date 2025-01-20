import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/Homepage.dart';
import 'package:medical/Screens/Views/shedule_tab1.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class shedule_screen extends StatefulWidget {
  const shedule_screen({Key? key}) : super(key: key);

  @override
  _TabBarExampleState createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<shedule_screen> with SingleTickerProviderStateMixin {
  late TabController tabController;
  List<Map<String, String>> appointments = [];

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

  // Function to validate email format
  bool _isValidEmail(String email) {
    final RegExp emailRegExp = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegExp.hasMatch(email);
  }

  // Function to store appointment in Firestore
  Future<void> _storeAppointment(Map<String, String> appointmentData) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Add the appointment to Firestore
        FirebaseFirestore.instance.collection('appointments').add({
          'doctor': appointmentData['doctor'],
          'speciality': appointmentData['speciality'],
          'date': appointmentData['date'],
          'time': appointmentData['time'],
          'email': appointmentData['email'],
          'status': appointmentData['status'],
          'userEmail': user.email, // Store the user's email
          'userId': user.uid, // Store the user's UID
        });
        print('Appointment booked successfully');
      } else {
        print('No user signed in');
      }
    } catch (e) {
      print('Failed to store appointment: $e');
    }
  }

  void _showAppointmentDialog() {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    final TextEditingController emailController = TextEditingController(); // Email controller
    String selectedSpeciality = 'Cardiologist';
    String selectedDoctor = 'Dr. Marcus Horizon';
    String emailError = ''; // To hold the error message for email validation

    List<String> doctors = [
      'Dr. Marcus Horizon',
      'Dr. Emily Stone',
      'Dr. Ava Wilson',
      'Dr. Liam Brown',
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Book an Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  value: selectedSpeciality,
                  items: ['Cardiologist', 'Neurologist', 'Dentist']
                      .map((String speciality) {
                    return DropdownMenuItem<String>(value: speciality, child: Text(speciality));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSpeciality = value!;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: selectedDoctor,
                  items: doctors.map((String doctor) {
                    return DropdownMenuItem<String>(value: doctor, child: Text(doctor));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedDoctor = value!;
                    });
                  },
                ),
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
                        dateController.text = pickedDate.toString().substring(0, 10);
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: dateController,
                      decoration: InputDecoration(labelText: 'Select Date'),
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
                      decoration: InputDecoration(labelText: 'Select Time'),
                    ),
                  ),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    errorText: emailError.isEmpty ? null : emailError,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  // Validate email before proceeding
                  if (!_isValidEmail(emailController.text)) {
                    emailError = 'Please enter a valid email address';
                  } else {
                    emailError = ''; // Clear the error message if valid
                    final appointmentData = {
                      'doctor': selectedDoctor,
                      'speciality': selectedSpeciality,
                      'date': dateController.text,
                      'time': timeController.text,
                      'email': emailController.text, // Add email to the appointment
                      'status': 'Pending' // Set to Pending initially
                    };
                    appointments.add(appointmentData);
                    _storeAppointment(appointmentData); // Store in Firestore
                    Navigator.pop(context);
                  }
                });
              },
              child: Text('Book Appointment'),
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.lightBlueAccent),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Homepage()), // Navigate to Homepage
            );
          },
        ),
        title: Text("Top Doctors",
            style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp)),
        centerTitle: false,
        elevation: 0,
        toolbarHeight: 100,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 20,
              width: 20,
              decoration: const BoxDecoration(
                image: DecorationImage(image: AssetImage("lib/icons/bell.png")),
              ),
            ),
          ),
        ],
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
                  indicatorColor: const Color.fromARGB(255, 241, 241, 241),
                  unselectedLabelColor: const Color.fromARGB(255, 32, 32, 32),
                  labelColor: Color.fromARGB(255, 255, 255, 255),
                  controller: tabController,
                  tabs: const [
                    Tab(text: "Upcoming"),
                    Tab(text: "Accepted"),
                    Tab(text: "Canceled"),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: const [
                shedule_tab1(status: "Pending"), // Pass "Upcoming" status
                shedule_tab1(status: "Completed"), // Pass "Completed" status
                shedule_tab1(status: "Canceled"),

              ],
            ),
          ),
        ],
      ),
      /*floatingActionButton: FloatingActionButton(
        onPressed: _showAppointmentDialog,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Color.fromARGB(255, 177, 124, 241),
      ),*/
    );
  }
}
