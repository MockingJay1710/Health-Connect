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

  void _showAppointmentDialog() {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();
    String selectedSpeciality = 'Cardiologist';
    String selectedDoctor = 'Dr. Marcus Horizon';

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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedSpeciality,
                items: ['Cardiologist', 'Neurologist', 'Dentist']
                    .map((String speciality) {
                  return DropdownMenuItem<String>(
                    value: speciality,
                    child: Text(speciality),
                  );
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
                  return DropdownMenuItem<String>(
                    value: doctor,
                    child: Text(doctor),
                  );
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
                      dateController.text =
                          pickedDate.toString().substring(0, 10);
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  appointments.add({
                    'doctor': selectedDoctor,
                    'speciality': selectedSpeciality,
                    'date': dateController.text,
                    'time': timeController.text,
                    'status': 'Pending' // Set to Pending initially
                  });
                });
                Navigator.pop(context);
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
     // Navigate back to the previous screen
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
      body: SingleChildScrollView( // Wrap the entire body in a SingleChildScrollView
        child: Column(
          children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height - 150, // Adjust this if needed
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .height,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 235, 235, 235),
                        ),
                        color: Color.fromARGB(255, 241, 241, 241),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(5),
                            child: TabBar(
                              indicator: BoxDecoration(
                                color: Color.fromARGB(255, 177, 124, 241),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              indicatorColor: const Color.fromARGB(
                                  255, 241, 241, 241),
                              unselectedLabelColor: const Color.fromARGB(
                                  255, 32, 32, 32),
                              labelColor: Color.fromARGB(255, 255, 255, 255),
                              controller: tabController,
                              tabs: const [
                                Tab(text: "Upcoming"),
                                Tab(text: "Completed"),
                                Tab(text: "Cancelled"),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Use Expanded to give TabBarView space
                  Expanded(
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        shedule_tab1(
                            appointments: appointments, status: 'Pending'),
                        shedule_tab1(
                            appointments: appointments, status: 'Completed'),
                        shedule_tab1(
                            appointments: appointments, status: 'Cancelled'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAppointmentDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}