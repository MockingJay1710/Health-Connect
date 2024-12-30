import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilMedical extends StatelessWidget {
  final String patientEmail;

  const ProfilMedical({Key? key, required this.patientEmail}) : super(key: key);

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
            // Allergies Section
            _buildAllergiesSection(),
            const SizedBox(height: 20),

            // Vaccinations Section
            _buildVaccinationsSection(),
            const SizedBox(height: 20),

            // Medical History Section
            _buildSection(
              title: 'Medical History',
              content: 'The patient has a history of asthma and high blood pressure. Asthma requires careful management to prevent shortness of breath, while high blood pressure should be regularly monitored to avoid cardiovascular issues.',
              imageUrl: 'lib/icons2/history.png',
            ),
            const SizedBox(height: 20),

            // Registered Diseases Section
            _buildDiseasesSection(),
            const SizedBox(height: 20),

            // Exam Results Section
            _buildSection(
              title: 'Exam Results',
              content: 'Recent exam results show the following: Blood Pressure: 130/80 (normal range), Cholesterol: Normal. These results indicate stable health, but regular check-ups are recommended.',
              imageUrl: 'lib/icons2/resultat.png',
            ),
            const SizedBox(height: 20),

            // Doctor Notes Section
            _buildSection(
              title: 'Doctor Notes',
              content: 'The patient is doing well. Follow-up recommended in 6 months for a routine check-up and to ensure continued health management.',
              imageUrl: 'lib/icons2/notes.jpg',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Section for Allergies with a Table
  Widget _buildAllergiesSection() {
    return _buildSectionWithTable(
      title: 'Allergies',
      content: 'The patient has allergies to peanuts, dust, and pollen. These allergens can cause reactions such as hives, swelling, and difficulty breathing.',
      imageUrl: 'lib/icons2/allergy.png',
      tableData: [
        ['Allergen', 'Peanuts', 'Dust', 'Pollen'],
        ['Severity', 'High', 'Medium', 'Low'],
        ['Symptoms', 'Swelling, Hives', 'Sneezing, Itchiness', 'Eye Irritation'],
        ['Treatment', 'Epinephrine', 'Antihistamines', 'Antihistamines'],
      ],
    );
  }

  // Section for Vaccinations with a Table
  Widget _buildVaccinationsSection() {
    return _buildSectionWithTable(
      title: 'Vaccinations',
      content: 'The patient has received the following vaccinations: COVID-19, Flu Shot, and Hepatitis B. These vaccinations are crucial in preventing contagious diseases.',
      imageUrl: 'lib/icons2/vaccine.png',
      tableData: [
        ['Vaccine Name', 'COVID-19', 'Flu Shot', 'Hepatitis B'],
        ['Date Administered', '2021-04-01', '2022-09-15', '2020-06-20'],
        ['Booster', 'Yes', 'No', 'No'],
        ['Next Due', '2024-04-01', 'N/A', 'N/A'],
      ],
    );
  }

  // Section for Registered Diseases with a Table
  Widget _buildDiseasesSection() {
    return _buildSectionWithTable(
      title: 'Registered Diseases',
      content: 'The patient is registered with hypertension and diabetes. Proper medication and lifestyle changes are essential for managing these chronic conditions.',
      imageUrl: 'lib/icons2/disease.png',
      tableData: [
        ['Disease Name', 'Hypertension', 'Diabetes'],
        ['Diagnosis Date', '2019-03-15', '2018-11-10'],
        ['Severity', 'Moderate', 'High'],
        ['Treatment', 'Beta-blockers', 'Insulin Therapy'],
        ['Cured', 'No', 'No'],
      ],
    );
  }

  // General method to build a section with a table
  Widget _buildSectionWithTable({required String title, required String content, required String imageUrl, required List<List<String>> tableData}) {
    return GestureDetector(
      onTap: () {
        // Optional: Add a tap action if you want to do something when the section is tapped
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                title,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                content,
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),

            // Table with blue lines
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Table(
                border: TableBorder.all(
                  color: Colors.blue,  // Set the border color to blue
                  style: BorderStyle.solid,
                  width: 1.0,
                ),
                children: tableData.map((row) {
                  return TableRow(
                    children: row.map((cell) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(cell, style: GoogleFonts.inter(fontSize: 14)),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 10),

            // Image and content in a Row (Image on the Right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imageUrl,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Generic method to build sections without a table
  Widget _buildSection({required String title, required String content, required String imageUrl}) {
    return GestureDetector(
      onTap: () {
        // Optional: Add a tap action if you want to do something when the section is tapped
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
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
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                title,
                style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                content,
                style: GoogleFonts.inter(fontSize: 16),
              ),
            ),
            const SizedBox(height: 10),

            // Image and content in a Row (Image on the Right)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      imageUrl,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
