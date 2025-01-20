import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:medical/global.dart';

class ProfilMedicalDoc extends StatelessWidget {
  final String? patientEmail;

  const ProfilMedicalDoc({Key? key, this.patientEmail}) : super(key: key);

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
            // const SizedBox(height: 20),
            // _buildMedicalHistorySection(),
            const SizedBox(height: 20),
            _buildExamResultsSection(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergiesSection(BuildContext context) {
    // Initialize the table data with headers
    List<List<String>> tableData = [
      ['Name', 'Severity', 'Symptoms', 'Treatment'],
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
                            ['Name', 'Severity', 'Symptoms', 'Treatment'],
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





  /*Widget _buildMedicalHistorySection() {
    // Initialize the table data with headers
    List<List<String>> tableData = [
      ['Name', 'Diagnostic Date', 'Description']
    ];

    // Fetch medical history assigned to the patient (dummy data or API call)
    Future<List<List<String>>> fetchMedicalHistory() async {
      print('Email'+patientEmail!);
      final response = await http.get(Uri.parse('$backend/api/profil-medical/$patientEmail/antecedants'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        // Map the fetched data into List<List<String>> format
        return data.map<List<String>>((e) {
          return [
            e['name'] ?? '',
            e['dateDiagnostic'] ?? '',
            e['description'] ?? 'N/A', // Default to 'N/A' if not provided
          ];
        }).toList();
      } else {
        throw Exception('Failed to load medical history');
      }
    }

    // Add new medical history to the API and then update the UI
    Future<void> addMedicalHistory(String name, String diagnosticDate, String description) async {
      final response = await http.post(
        Uri.parse('$backend/api/profil-medical/$patientEmail/AddAntecedant'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'name': name,
          'dateDiagnostic': diagnosticDate,
          'description': description,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to add medical history');
      }
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Initially fetch all medical history when the page is loaded
        if (tableData.length == 1) {
          fetchMedicalHistory().then((history) {
            setState(() {
              tableData.addAll(history);
            });
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to load medical history: $error')),
            );
          });
        }

        // Function to show dialog and get medical history details from the user
        Future<void> showAddMedicalHistoryDialog() async {
          final TextEditingController nameController = TextEditingController();
          final TextEditingController diagDateController = TextEditingController();
          final TextEditingController descriptionController = TextEditingController();

          DateTime selectedDiagnosticDate = DateTime.now();

          // Function to show date picker and set the selected date in the controller
          Future<void> _selectDate(BuildContext context) async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                selectedDiagnosticDate = picked;
                diagDateController.text = "${selectedDiagnosticDate.toLocal()}".split(' ')[0]; // Format date
              });
            }
          }

          await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Add Medical History'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: diagDateController,
                      decoration: InputDecoration(labelText: 'Diagnostic Date'),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Description'),
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
                      final name = nameController.text;
                      final diagnosticDate = diagDateController.text;
                      final description = descriptionController.text;

                      if (name.isNotEmpty && diagnosticDate.isNotEmpty) {
                        addMedicalHistory(name, diagnosticDate, description).then((_) {
                          setState(() {
                            tableData.add([
                              name,
                              diagnosticDate,
                              description.isNotEmpty ? description : 'N/A',
                            ]);
                          });
                          Navigator.of(context).pop();
                        }).catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add medical history: $error')),
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
                Icon(Icons.history, size: 40),
                const SizedBox(width: 10),
                Text(
                  'Medical History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'The patient\'s medical history:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(3),
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
              onPressed: showAddMedicalHistoryDialog,
              child: const Text('Add Medical History'),
            ),
          ],
        );
      },
    );
  }*/




  Widget _buildExamResultsSection(BuildContext context) {
    // Initialize the list of exam results
    List<Map<String, String>> examResults = [];

    // Fetch exam results from the backend
    Future<void> fetchExamResults() async {
      try {
        final response = await http.get(Uri.parse('$backend/api/profil-medical/$patientEmail/resultats-examen'));
        if (response.statusCode == 200) {
          List<dynamic> data = json.decode(response.body);
          List<Map<String, String>> results = data.map<Map<String, String>>((e) {
            return {
              'date': e['date'] ?? '',
              'notesDoctor': e['notesDoctor'] ?? '',
            };
          }).toList();

          // Update the UI with fetched results
          examResults = results;
        } else {
          throw Exception('Failed to fetch exam results');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load exam results: $error')),
        );
      }
    }

    // Add a new exam result to the backend
    Future<void> addExamResult(String date, String notesDoctor) async {
      try {
        final response = await http.post(
          Uri.parse('$backend/api/profil-medical/$patientEmail/AddResultatExamen'),
          headers: {'Content-Type': 'application/json; charset=UTF-8'},
          body: json.encode({'date': date, 'notesDoctor': notesDoctor}),
        );

        if (response.statusCode != 200) {
          throw Exception('Failed to add exam result');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add exam result: $error')),
        );
      }
    }

    // Function to display dialog for adding a new exam result
    Future<void> showAddExamResultDialog() async {
      final TextEditingController dateController = TextEditingController();
      final TextEditingController noteController = TextEditingController();

      DateTime selectedDate = DateTime.now();

      Future<void> _selectDate() async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != selectedDate) {
          selectedDate = picked;
          dateController.text = "${selectedDate.toLocal()}".split(' ')[0];
        }
      }

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Exam Result'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  onTap: _selectDate,
                ),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final date = dateController.text;
                  final note = noteController.text;

                  if (date.isNotEmpty && note.isNotEmpty) {
                    addExamResult(date, note).then((_) {
                      Navigator.of(context).pop();
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add exam result: $error')),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all fields')),
                    );
                  }
                },
                child: const Text('Add'),
              ),
            ],
          );
        },
      );
    }

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        // Fetch results when the section is built
        if (examResults.isEmpty) {
          fetchExamResults().then((_) {
            setState(() {});
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
                  'Exam Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'The patient has the following exam results:',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            ...examResults.map(
                  (result) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  '${result['date']}: ${result['notesDoctor']}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: showAddExamResultDialog,
              child: const Text('Add Exam Result'),
            ),
          ],
        );
      },
    );
  }






}
