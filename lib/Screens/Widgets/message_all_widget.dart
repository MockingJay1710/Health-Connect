import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class message_all_widget extends StatelessWidget {
  final String Maintext;
  final String subtext;
  final String image;
  final String time;
  final String message_count;

  message_all_widget({
    required this.Maintext,
    required this.subtext,
    required this.image,
    required this.message_count,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        SizedBox(
          height: 20,
        ),
        Container(
          height: MediaQuery.of(context).size.height * 0.07, // Increased slightly
          width: MediaQuery.of(context).size.width * 0.9,
          color: Colors.white,
          child: Row(children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.1500,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(image),
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.6,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center, // Adjusted alignment
                children: [
                  // Main text
                  Text(
                    Maintext,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2), // Reduced spacing
                  // Subtext
                  Text(
                    subtext,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.1200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Adjusted alignment
                children: [
                  // Time of chat
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 5), // Reduced spacing
                  Container(
                    height: 16,
                    width: 16,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 2, 134, 117),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        message_count,
                        style: TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
