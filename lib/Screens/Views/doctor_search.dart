import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medical/Screens/Views/Homepage.dart';
import 'package:medical/Screens/Views/doctor_details_screen.dart';
import 'package:medical/Screens/Widgets/doctorList.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
class DoctorSearch extends StatelessWidget {
  const DoctorSearch({super.key});

  final List<Map<String, String>> doctors = const [
    {
      "name": "Dr. Marcus Horizon",
      "specialty": "Cardiologist",
      "rating": "4.7",
      "distance": "800m Away",
      "image": "lib/icons/male-doctor.png"
    },
    {
      "name": "Dr. Alysa Hana",
      "specialty": "Psychiatrist",
      "rating": "4.6",
      "distance": "1.2km Away",
      "image": "lib/icons/doctor2.png"
    },
    {
      "name": "Dr. Maria Elena",
      "specialty": "Dentist",
      "rating": "4.8",
      "distance": "2km Away",
      "image": "lib/icons/doctor2.png"
    },
    {
      "name": "Dr. Jonathan Reid",
      "specialty": "Neurologist",
      "rating": "4.5",
      "distance": "1.5km Away",
      "image": "lib/icons/black-doctor.png"
    },
    {
      "name": "Dr. Samuel Brooks",
      "specialty": "Pediatrician",
      "rating": "4.9",
      "distance": "3km Away",
      "image": "lib/icons/male-doctor.png"
    },
  ];


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
                type: PageTransitionType.leftToRight, // Smooth transition to the homepage
                child: Homepage(), // Replace with your actual homepage widget
              ),
            );

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
          "Top Doctors",
          style: GoogleFonts.poppins(color: Colors.black, fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 100,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: doctors.map((doctor) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: DoctorDetails(
                        doctorName: doctor["name"]!,
                        specialty: doctor["specialty"]!,
                        rating: doctor["rating"]!,
                        distance: doctor["distance"]!,
                        image: doctor["image"]!,
                      ),
                    ),
                  );
                },
                child: doctorList(
                  maintext: doctor["name"]!,
                  subtext: doctor["specialty"]!,
                  numRating: doctor["rating"]!,
                  distance: doctor["distance"]!,
                  image: doctor["image"]!,
                ),
              );
            }).toList(),
          ),
        ),
      ),

    );
  }
}
