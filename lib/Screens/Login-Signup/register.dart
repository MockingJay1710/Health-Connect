import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medical/Screens/Login-Signup/login.dart';
import 'package:medical/Screens/Views/Homepage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import '../../UserModel.dart';


class register extends StatefulWidget {
  const register({super.key});

  @override
  State<register> createState() => _RegisterState();
}

class _RegisterState extends State<register> {
  final _formKey = GlobalKey<FormState>();

  // Controllers to handle input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dateNaissanceController = TextEditingController();

  bool _isChecked = false; // Checkbox state
  String? _selectedRole; // Role selection
  final List<String> _roles = ['Doctor', 'Patient'];

  File? _selectedImage; // To store the selected image
  String? _imageBase64; // To store the base64 string of the image

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      final bytes = await imageFile.readAsBytes();
      setState(() {
        _selectedImage = imageFile;
        _imageBase64 = base64Encode(bytes); // Convert image to Base64 string
      });
    }
  }

  // Function to pick a date using DatePicker
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default to current date
      firstDate: DateTime(1900), // The earliest selectable date
      lastDate: DateTime.now(), // The latest selectable date (current date)
    );

    if (pickedDate != null) {
      setState(() {
        _dateNaissanceController.text = pickedDate.toLocal().toString().split(' ')[0]; // Format the date
      });
    }
  }


  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_isChecked) {
        if (_selectedRole == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a role.')),
          );
          return;
        }

        try {
          // Register user in Firebase Auth
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          String userId = userCredential.user!.uid; // Firebase-generated UID

          // Store user info in Firestore
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'role': _selectedRole,
            'phoneNumber': _phoneController.text.trim(),
            'dateNaissance': _dateNaissanceController.text.trim(),
            'profileImageBase64': _imageBase64 ?? '', // Save Base64 image
            'created_at': FieldValue.serverTimestamp(),
          });

          // Set email in UserModel globally
          Provider.of<UserModel>(context, listen: false).setEmail(_emailController.text.trim());

          // Navigate to Homepage on success
          Navigator.pushReplacement(
            context,
            PageTransition(type: PageTransitionType.fade, child: Homepage()),
          );

        } on FirebaseAuthException catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message ?? "Registration failed")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the terms.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset("lib/icons/back1.png"), // Use back1.png for the back button
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
        title: Text('Register'),

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Profile Image Picker
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? Image.asset("lib/icons/camera.png") // Use camera.png when no image is selected
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(labelText: "Enter your email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Enter your name"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                isDense: true,
                decoration: InputDecoration(
                  labelText: "Select a role",
                  suffixIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      "lib/icons/down-arrow.png",
                      width: 20,
                      height: 20,
                    ),
                  ),
                  border: OutlineInputBorder(),
                ),
                icon: SizedBox.shrink(), // Hides the default dropdown icon
                items: _roles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRole = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';

                  }
                  return null;
                },
              ),


              const SizedBox(height: 15),
                // Phone Number Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: "Enter your phone number"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Date of Birth Field (Now with Date Picker)
                TextFormField(
                  controller: _dateNaissanceController,
                  readOnly: true, // Prevent manual entry
                  decoration: InputDecoration(
                    labelText: "Select your date of birth",
                    suffixIcon: IconButton(
                      icon: Image.asset("lib/icons/calendrier.png"), // Add your calendrier.png icon here
                      onPressed: _pickDate,
                    ),
                  ),
                  onTap: _pickDate, // Show date picker when tapped
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your date of birth';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: "Enter your password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                // Checkbox for Terms
                CheckboxListTile(
                  value: _isChecked,
                  onChanged: (value) {
                    setState(() {
                      _isChecked = value ?? false;
                    });
                  },
                  title: Text("Agree to terms"),
                ),
                const SizedBox(height: 20),
                // Register Button
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    child: Text('Register'),
                  ),
                ),
              ],
            ),

          ),
        ),
      ),
    );
  }
}
