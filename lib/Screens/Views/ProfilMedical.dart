import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:medical/global.dart';

class ProfilMedical extends StatelessWidget {
  final String? patientEmail;

  const ProfilMedical({Key? key, this.patientEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Medical Profile', style: GoogleFonts.inter(fontSize: 18)),
        backgroundColor: const Color.fromARGB(255, 3, 190, 150),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAllergiesSection(context),
            const SizedBox(height: 20),
            _buildVaccinationsSection(context),
            const SizedBox(height: 20),
            _buildMedicalHistorySection(),
            const SizedBox(height: 20),
            _buildDiseasesSection(context),
            const SizedBox(height: 20),
            _buildExamResultsSection(context),
            const SizedBox(height: 20),
            _buildDoctorNotesSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesSection(BuildContext context) {
    // Initialize the table data with headers
    List<List<String>> tableData = [
      ['Allergen', 'Name', 'Severity', 'Symptoms', 'Treatment'],
    ];

    List<String> dropdownOptions = [
      'Pollen',
      'Poussière',
      'Arachides',
      'Poisson',
      'Lait',
      'Œufs',
      'Fruits de mer',
      'Pollen d\'arbres',
      'Poils d\'animaux',
      'Gluten',
    ];

    String selectedAllergy = dropdownOptions[0];

    // Fetch all allergies assigned to the patient
    Future<List<List<String>>> fetchAllergies() async {
      final response = await http.get(Uri.parse('$backend/api/profil-medical/$patientEmail/allergies'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Map the fetched data into List<List<String>> format
        return data.map<List<String>>((e) {
          return [
            e['nomAllergie'] ?? '',
            e['nomAllergie'] ?? '',
            e['severity'] ?? '',
            e['symptomes'] ?? '',
            e['treatement'] ?? '',
          ];
        }).toList();
      } else {
        throw Exception('Failed to load allergies');
      }
    }

    // Add selected allergy to the patient's profile
    Future<void> addAllergy(String allergen) async {
      final response = await http.post(
        Uri.parse('$backend/api/profil-medical/$patientEmail/$allergen/addAllergies'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add allergy');
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Initially fetch all allergies when the page is loaded
        if (tableData.length == 1) {
          fetchAllergies().then((allergies) {
            setState(() {
              tableData.addAll(allergies);
            });
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load allergies: $error')),
            );
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('lib/icons2/allergy.png', width: 40, height: 40),
                const SizedBox(width: 10),
                Text(
                  'Allergies',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'The patient has the following allergies :',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2),
              },
              children: tableData
                  .map(
                    (row) => TableRow(
                  children: row
                      .map(
                        (cell) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(cell),
                    ),
                  )
                      .toList(),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedAllergy,
                    isExpanded: true,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedAllergy = newValue!;
                      });
                    },
                    items: dropdownOptions.map((String allergen) {
                      return DropdownMenuItem<String>(
                        value: allergen,
                        child: Text(allergen),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    addAllergy(selectedAllergy).then((_) {
                      // After adding allergy, fetch the updated list
                      fetchAllergies().then((allergies) {
                        setState(() {
                          tableData = [
                            ['Allergen', 'Name', 'Severity', 'Symptoms', 'Treatment'],
                            ...allergies,
                          ];
                        });
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to load allergies: $error')),
                        );
                      });
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add allergy: $error')),
                      );
                    });
                  },
                  child: const Text('Add Allergy'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }




  Widget _buildVaccinationsSection(BuildContext context) {
    // Initialize the table data with headers
    List<List<String>> tableData = [
      ['Vaccine Name', 'Date Administered', 'Next Due']
    ];

    // Fetch vaccinations assigned to the patient (dummy data or API call)
    Future<List<List<String>>> fetchVaccinations() async {
      final response = await http.get(Uri.parse('$backend/api/profil-medical/$patientEmail/vaccinations'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Map the fetched data into List<List<String>> format
        return data.map<List<String>>((e) {
          return [
            e['vaccineName'] ?? '',
            e['vaccineDate'] ?? '',
            e['nextDue'] ?? 'N/A', // Default to 'N/A' if not provided
          ];
        }).toList();
      } else {
        throw Exception('Failed to load vaccinations');
      }
    }

    // Add new vaccination to the API and then update the UI
    Future<void> addVaccination(String vaccineName, String lastDate, String nextDueDate) async {
      final response = await http.post(
        Uri.parse('$backend/api/profil-medical/$patientEmail/AddVaccination'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'vaccineName': vaccineName,
          'vaccineDate': lastDate,
          'nextDue': nextDueDate,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add vaccination');
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Initially fetch all vaccinations when the page is loaded
        if (tableData.length == 1) {
          fetchVaccinations().then((vaccinations) {
            setState(() {
              tableData.addAll(vaccinations);
            });
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load vaccinations: $error')),
            );
          });
        }

        // Function to show dialog and get vaccination details from the user
        Future<void> showAddVaccinationDialog() async {
          final TextEditingController vaccineController = TextEditingController();
          final TextEditingController lastDateController = TextEditingController();
          final TextEditingController nextDueController = TextEditingController();

          DateTime selectedLastDate = DateTime.now();
          DateTime selectedNextDueDate = DateTime.now();

          // Function to show date picker and set the selected date in the controller
          Future<void> _selectDate(BuildContext context, bool isLastDate) async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null && picked != (isLastDate ? selectedLastDate : selectedNextDueDate)) {
              setState(() {
                if (isLastDate) {
                  selectedLastDate = picked;
                  lastDateController.text = "${selectedLastDate.toLocal()}".split(' ')[0]; // Format date
                } else {
                  selectedNextDueDate = picked;
                  nextDueController.text = "${selectedNextDueDate.toLocal()}".split(' ')[0]; // Format date
                }
              });
            }
          }

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Vaccination'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: vaccineController,
                      decoration: InputDecoration(labelText: 'Vaccine Name'),
                    ),
                    TextField(
                      controller: lastDateController,
                      decoration: InputDecoration(labelText: 'Last Date Administered'),
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                    ),
                    TextField(
                      controller: nextDueController,
                      decoration: InputDecoration(labelText: 'Next Due Date'),
                      readOnly: true,
                      onTap: () => _selectDate(context, false),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final vaccineName = vaccineController.text;
                      final lastDate = lastDateController.text;
                      final nextDueDate = nextDueController.text;

                      if (vaccineName.isNotEmpty && lastDate.isNotEmpty) {
                        addVaccination(vaccineName, lastDate, nextDueDate).then((_) {
                          setState(() {
                            tableData.add([
                              vaccineName,
                              lastDate,
                              nextDueDate.isNotEmpty ? nextDueDate : 'N/A',
                            ]);
                          });
                          Navigator.of(context).pop();
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add vaccination: $error')),
                          );
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all required fields')),
                        );
                      }
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset('lib/icons2/vaccine.png', width: 40, height: 40),
                const SizedBox(width: 10),
                Text(
                  'Vaccinations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'The patient has received these vaccinations:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
              },
              children: tableData
                  .map(
                    (row) => TableRow(
                  children: row
                      .map(
                        (cell) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(cell),
                    ),
                  )
                      .toList(),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: showAddVaccinationDialog,
              child: const Text('Add Vaccination'),
            ),
          ],
        );
      },
    );
  }





  Widget _buildMedicalHistorySection() {
    return _buildSection(
      title: 'Medical History',
      content: 'The patient has a history of asthma and high blood pressure.',
      imageUrl: 'lib/icons2/history.png',
    );
  }

  Widget _buildDiseasesSection(BuildContext context) {
    return _buildSectionWithTableAndButton(
      context,
      title: 'Registered Diseases',
      content: 'The patient is registered with hypertension and diabetes.',
      imageUrl: 'lib/icons2/disease.png',
      tableData: [
        ['Disease Name', 'Hypertension', 'Diabetes'],
        ['Diagnosis Date', '2019-03-15', '2018-11-10'],
        ['Severity', 'Moderate', 'High'],
        ['Treatment', 'Beta-blockers', 'Insulin Therapy'],
        ['Cured', 'No', 'No'],
      ],
      dropdownOptions: ['Hypertension', 'Diabetes', 'Asthma', 'COPD', 'Heart Disease'],
    );
  }

  Widget _buildExamResultsSection(BuildContext context) {
    return _buildSectionWithTableAndButton(
      context,
      title: 'Exam Results',
      content: 'Recent exam results show the following: Blood Pressure and Cholesterol are normal.',
      imageUrl: 'lib/icons2/resultat.png',
      tableData: [
        ['Test', 'Blood Pressure', 'Cholesterol'],
        ['Result', '130/80', 'Normal'],
        ['Range', 'Normal', 'Normal'],
        ['Follow-Up', 'No', 'No'],
      ],
      dropdownOptions: ['Blood Pressure', 'Cholesterol', 'Blood Sugar', 'ECG', 'Liver Function'],
    );
  }

  Widget _buildDoctorNotesSection() {
    return _buildSection(
      title: 'Doctor Notes',
      content: 'The patient is doing well. Follow-up recommended in 6 months.',
      imageUrl: 'lib/icons2/notes.jpg',
    );
  }

  Widget _buildSectionWithTableAndButton(BuildContext context, {
    required String title,
    required String content,
    required String imageUrl,
    required List<List<String>> tableData,
    required List<String> dropdownOptions,
  }) {
    return GestureDetector(
      onTap: () {
        // Optional: Add a tap action
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.blue),
                    onPressed: () => _showAddItemDialog(context, title, dropdownOptions),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(content, style: GoogleFonts.inter(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: {0: FlexColumnWidth(), 1: FlexColumnWidth()},
                children: tableData.map((row) {
                  return TableRow(
                    children: row.map((cell) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          cell,
                          style: GoogleFonts.inter(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, String sectionTitle, List<String> dropdownOptions) {
    // Show a dialog to add an item
  }

  Widget _buildSection({required String title, required String content, required String imageUrl}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(imageUrl, width: 40, height: 40),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(content, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
