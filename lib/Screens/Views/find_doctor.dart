import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON parsing

import 'package:medical/Screens/Views/doctor_details_screen.dart';
import 'package:medical/Screens/Widgets/doctorList.dart';
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
  List<String> categories = ['All', 'Generaliste', 'Cardiologie', 'Pediatrie', 'Neurologie', 'Psychiatrie'];
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    try {
      final response = await http.get(Uri.parse('http://10.72.101.154:8080/api/doctors/allDoctors'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          doctors = data.map((item) {
            return {
              "name": item["name"],                      // Map 'name' from API response
              "category": item["specialiteDocteur"],      // Map 'specialiteDocteur' to 'category'
              "distance": "3.0",                          // Hardcode distance for now
              "image": "lib/icons/male-doctor.png", // Hardcode image URL
              "rating": "4.5",
              "email": item["email"],
              // Hardcode rating
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> getFilteredDoctors() {
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        title: Column(
          children: [
            Text(
              "Find Doctor",
              style: GoogleFonts.inter(
                  color: const Color.fromARGB(255, 51, 47, 47),
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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text("Error: $errorMessage"))
          : SingleChildScrollView(
        child: Column(children: [
          const SizedBox(height: 20),
          Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.9,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  fillColor: const Color.fromARGB(255, 247, 247, 247),
                  filled: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.asset(
                      "lib/icons/search.png",
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  labelText: "Search for a doctor...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                    color: const Color.fromARGB(255, 46, 46, 46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory == category
                          ? Colors.blue
                          : Colors.grey[300],
                      foregroundColor: Colors.white,
                    ),
                    child: Text(category),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
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
                    color: const Color.fromARGB(255, 46, 46, 46),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Column(
            children: getFilteredDoctors().map((doctor) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    PageTransition(
                      type: PageTransitionType.rightToLeft,
                      child: DoctorDetails(
                        doctorName: doctor["name"]!,
                        specialty: doctor["category"]!,
                        rating: doctor["rating"]!,
                        distance: doctor["distance"]!,
                        image: doctor["image"]!,
                        docEmail: doctor["email"]!,
                      ),
                    ),
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
