import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Views/doctor_details_screen.dart';
import 'package:medical/Screens/Widgets/doctorList.dart';
import 'package:medical/Screens/Widgets/listicons.dart';
import 'package:page_transition/page_transition.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FindDoctor extends StatefulWidget {
  const FindDoctor({super.key});

  @override
  _FindDoctorState createState() => _FindDoctorState();
}

class _FindDoctorState extends State<FindDoctor> {
  TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<String> categories = ['All', 'General', 'Lungs Prob', 'Psychiatrist', 'Cardiologist'];
  List<Map<String, String>> doctors = [
    {"name": "Dr. Marcus Horizon", "category": "Cardiologist", "distance": "800m away", "image": "lib/icons/male-doctor.png", "rating": "4.7"},
    {"name": "Dr. Maria Smith", "category": "Psychiatrist", "distance": "500m away", "image": "lib/icons/female-doctor.png", "rating": "4.5"},
    {"name": "Dr. Luke Johnson", "category": "General", "distance": "1km away", "image": "lib/icons/black-doctor.png", "rating": "4.6"},
    // Add more doctor data here
  ];

  List<Map<String, String>> getFilteredDoctors() {
    String query = _searchController.text.toLowerCase();
    return doctors.where((doctor) {
      bool matchesName = doctor["name"]!.toLowerCase().contains(query);
      bool matchesCategory = _selectedCategory == 'All' || doctor["category"] == _selectedCategory;
      return matchesName && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.06,
              child: Image.asset("lib/icons/back2.png")),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Column(
          children: [
            Text(
              "Find Doctor",
              style: GoogleFonts.inter(
                  color: Color.fromARGB(255, 51, 47, 47),
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1),
            ),
          ],
        ),
        toolbarHeight: 130,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [
          SizedBox(
            height: 20,
          ),
          // Search bar
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(),
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.start,
                textInputAction: TextInputAction.none,
                obscureText: false,
                keyboardType: TextInputType.text,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  focusColor: Colors.black26,
                  fillColor: Color.fromARGB(255, 247, 247, 247),
                  filled: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                      width: MediaQuery.of(context).size.width * 0.01,
                      child: Image.asset(
                        "lib/icons/search.png",
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                  prefixIconColor: const Color.fromARGB(255, 158, 83, 220),
                  label: Text("Search for a doctor..."),
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Category Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Categories",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 46, 46, 46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Category Buttons
          Row(
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: _selectedCategory == category
                        ? Colors.blue
                        : Colors.grey[300],
                  ),
                  child: Text(category),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 20),
          // Filtered Doctors List
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  "Recommended Doctors",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 46, 46, 46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Column(
            children: getFilteredDoctors().map((doctor) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                        type: PageTransitionType.rightToLeft,
                        child: DoctorDetails(doctorName: "", specialty: "", rating: "", distance: "", image: "")),
                  );
                },
                child: doctorList(
                  distance: doctor['distance']!,
                  image: doctor['image']!,
                  maintext: doctor['name']!,
                  numRating: doctor['rating']!,
                  subtext: doctor['category']!,
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }
}
