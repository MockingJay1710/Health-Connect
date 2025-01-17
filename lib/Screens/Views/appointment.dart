import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/doctor_details_screen.dart';
import 'package:medical/Screens/Widgets/doctorList.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:page_transition/page_transition.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  List<Map<String, String>> appointments = [
    {
      "doctorName": "Dr. Marcus Horizon",
      "specialization": "Cardiologist",
      "rating": "4.7",
      "distance": "800m away",
      "image": "lib/icons/male-doctor.png",
      "date": "Wednesday, Jun 23, 2021 | 10:00 AM",
      "reason": "Chest pain",
      "payment": "\$61.00",
    },
    // Add initial appointments here if needed
  ];

  void addAppointment(Map<String, String> newAppointment) {
    setState(() {
      appointments.add(newAppointment);
    });
  }

  void removeAppointment(int index) {
    setState(() {
      appointments.removeAt(index);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
                context,
                PageTransition(

                    type: PageTransitionType.fade, child:  DoctorDetails(doctorName: '', specialty: '',distance: '', rating: '', image: '',docEmail: "",)));

          },
          child: Container(
            height: 10,
            width: 10,
            decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("lib/icons/back1.png"),
                )),

          ),
        ),
        title: Text(
          "Top Doctors",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 100,

        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Column(
            children: [
              const SizedBox(height: 5),
              for (int i = 0; i < appointments.length; i++) ...[
                // Display appointment
                doctorList(
                  distance: appointments[i]["distance"]!,
                  image: appointments[i]["image"]!,
                  maintext: appointments[i]["doctorName"]!,
                  numRating: appointments[i]["rating"]!,
                  subtext: appointments[i]["specialization"]!,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Date",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "Change",
                        style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(137, 56, 56, 56)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.1300,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 247, 247),
                            borderRadius: BorderRadius.circular(18),
                            image: const DecorationImage(
                              image: AssetImage("lib/icons/callender.png"),
                            )),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          appointments[i]["date"]!,
                          style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Reason",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        "Change",
                        style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color.fromARGB(137, 56, 56, 56)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height * 0.06,
                        width: MediaQuery.of(context).size.width * 0.1300,
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 247, 247, 247),
                            borderRadius: BorderRadius.circular(18),
                            image: const DecorationImage(
                              image: AssetImage("lib/icons/pencil.png"),
                            )),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        appointments[i]["reason"]!,
                        style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.black12),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Payment Details",
                        style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Consultation",
                        style: GoogleFonts.poppins(
                            fontSize: 15.sp, color: Colors.black54),
                      ),
                      Text(
                        appointments[i]["payment"]!,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.black12),
                ),
                const SizedBox(height: 10),
                // Add or remove buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () {
                        removeAppointment(i);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle, color: Colors.green),
                      onPressed: () {
                        addAppointment({
                          "doctorName": "Dr. New Doctor",
                          "specialization": "Specialist",
                          "rating": "5.0",
                          "distance": "500m away",
                          "image": "lib/icons/male-doctor.png",
                          "date": "Monday, Feb 15, 2024 | 11:00 AM",
                          "reason": "Headache",
                          "payment": "\$50.00",
                        });
                      },
                    ),
                  ],
                ),
              ],

            ],
          ),
        ]),
      ),
    );
  }
}
