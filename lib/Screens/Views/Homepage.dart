import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:medical/Screens/Login-Signup/Profile_screen.dart';
import 'package:medical/Screens/Login-Signup/shedule_screen.dart';
import 'package:medical/Screens/Views/DashDoctor.dart';
import 'package:medical/Screens/Views/Dashboard_screen.dart';
import 'package:medical/Screens/Views/DoctorAppointements.dart';
import 'package:medical/Screens/Widgets/TabbarPages/message_tab_all.dart';

class Homepage extends StatefulWidget {
  final String name="";
  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<IconData> icons = [
    FontAwesomeIcons.home,
    FontAwesomeIcons.envelope,
    FontAwesomeIcons.clipboardCheck,
    FontAwesomeIcons.user,
  ];

  int page = 0;

  List<Widget> pages = [
    //Dashboard(),
    Dashboard(),
    message_tab_all(),
    shedule_screen(),
    Profile_screen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[page], // Display the selected page
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: icons,
        iconSize: 20,
        activeIndex: page,
        height: 80,
        splashSpeedInMilliseconds: 300,
        gapLocation: GapLocation.none,
        activeColor: const Color.fromARGB(255, 177, 101, 221),
        inactiveColor: const Color.fromARGB(255, 223, 219, 219),
        onTap: (int tappedIndex) {
          setState(() {
            page = tappedIndex; // Update the selected page
          });
        },
      ),
    );
  }
}
