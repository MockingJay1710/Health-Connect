import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class shedule_tab1 extends StatefulWidget {
  final List<Map<String, String>> appointments;
  final String status;

  const shedule_tab1({super.key, required this.appointments, required this.status});

  @override
  _shedule_tab1State createState() => _shedule_tab1State();
}

class _shedule_tab1State extends State<shedule_tab1> {
  void _cancelAppointment(int index) {
    // Removing the appointment or updating its status
    setState(() {
      widget.appointments[index]['status'] = 'Cancelled'; // Update status to Cancelled
    });
  }

  void _rescheduleAppointment(int index) {
    final TextEditingController dateController = TextEditingController();
    final TextEditingController timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reschedule Appointment"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Reschedule for: ${widget.appointments[index]['doctor']}"),
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
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Update the appointment with new date and time
                setState(() {
                  widget.appointments[index]['date'] = dateController.text;
                  widget.appointments[index]['time'] = timeController.text;
                  // Reset status to "Pending" after rescheduling
                  widget.appointments[index]['status'] = "Pending";
                });
                Navigator.pop(context);
              },
              child: Text("Save Changes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter appointments based on the selected status
    List<Map<String, String>> filteredAppointments = widget.appointments
        .where((appointment) => appointment['status'] == widget.status)
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 30),
          // Display filtered appointments
          for (var i = 0; i < filteredAppointments.length; i++)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Doctor: ${filteredAppointments[i]['doctor']}",
                      style: GoogleFonts.poppins(fontSize: 16.sp),
                    ),
                    Text(
                      "Speciality: ${filteredAppointments[i]['speciality']}",
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    Text(
                      "Date: ${filteredAppointments[i]['date']}",
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    Text(
                      "Time: ${filteredAppointments[i]['time']}",
                      style: GoogleFonts.poppins(fontSize: 14.sp),
                    ),
                    Text(
                      "Status: ${filteredAppointments[i]['status']}",
                      style: GoogleFonts.poppins(fontSize: 14.sp, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (widget.status == 'Pending')
                          ElevatedButton(
                            onPressed: () => _cancelAppointment(i),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            child: Text('Cancel'),
                          ),
                        const SizedBox(width: 10),
                        if (widget.status != 'Cancelled')
                          ElevatedButton(
                            onPressed: () => _rescheduleAppointment(i),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                            child: Text('Reschedule'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),

    );
  }
}
