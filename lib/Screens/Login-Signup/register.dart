import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:medical/Screens/Views/HomeDoctor.dart';
import 'package:medical/Screens/Views/Homepage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
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

  //doctor specialities
  List<String> _specialities = ['Generaliste', 'Cardiologie', 'Pediatrie', 'Neurologie', 'Psychiatrie'];
  String? _selectedSpeciality;
  File? _selectedImage; // For mobile/desktop (non-web)
  XFile? _selectedImageWeb;
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'US'); // Default country code

  // Function to handle country code and phone number formatting
  Future<void> _onPhoneNumberChanged(PhoneNumber number) async {
    setState(() {
      _phoneNumber = number;
    });
  }

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();

      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          setState(() {
            _selectedImageWeb = pickedFile;
          });
        } else {
          setState(() {
            _selectedImage = File(pickedFile.path);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image selected')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  // Function to encode the image to Base64
  Future<String?> _getBase64EncodedImage() async {
    if (kIsWeb && _selectedImageWeb != null) {
      final bytes = await _selectedImageWeb!.readAsBytes();
      return base64Encode(bytes);
    } else if (!kIsWeb && _selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      return base64Encode(bytes);
    }
    return null; // No image selected
  }

  // Function to pick a date using DatePicker
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dateNaissanceController.text =
        pickedDate.toLocal().toString().split(' ')[0];
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
          UserCredential userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          String userId = userCredential.user!.uid;
          String? base64Image = await _getBase64EncodedImage();
          String phoneNumberFormatted = _phoneNumber.phoneNumber ?? '';

          // Save user info to Firestore
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'email': _emailController.text.trim(),
            'name': _nameController.text.trim(),
            'role': _selectedRole,
            'phoneNumber': phoneNumberFormatted,
            'dateNaissance': _dateNaissanceController.text.trim(),
            'profileImageBase64': base64Image ?? '',
            'created_at': FieldValue.serverTimestamp(),
          });

          Provider.of<UserModel>(context, listen: false).setEmail(
              _emailController.text.trim());

          if (_selectedRole == 'Doctor') {
            Navigator.pushReplacement(
              context,
              PageTransition(
                  type: PageTransitionType.fade, child: HomeDoctor()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              PageTransition(type: PageTransitionType.fade, child: Homepage()),
            );
          }
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
          icon: Image.asset("lib/icons/back1.png"),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Register'),
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
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : null,
                      child: _selectedImage == null
                          ? Image.asset(
                        "lib/icons/camera.png",
                        width: 40,
                        height: 40,
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      labelText: "Enter your email"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    final emailRegex = RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: "Enter your name"),
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
                      child: Image.asset("lib/icons/down-arrow.png",
                          width: 20, height: 20),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  icon: const SizedBox.shrink(),
                  items: _roles.map((String role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue;
                      _selectedSpeciality =
                      null; // Reset speciality when role changes
                    });
                  },
                ),
                if (_selectedRole == 'Doctor') ...[
                  const SizedBox(height: 15),
                  // Specialities Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSpeciality,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: "Select a speciality",
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset("lib/icons/down-arrow.png",
                            width: 20, height: 20),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    icon: const SizedBox.shrink(),
                    items: _specialities.map((String speciality) {
                      return DropdownMenuItem<String>(
                        value: speciality,
                        child: Text(speciality),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedSpeciality = newValue;
                      });
                    },
                  ),
                ],
                const SizedBox(height: 15),
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      labelText: "Enter your password"),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Phone Number Input Field
                InternationalPhoneNumberInput(
                  onInputChanged: _onPhoneNumberChanged,
                  selectorConfig: const SelectorConfig(
                    selectorType: PhoneInputSelectorType.DIALOG,
                  ),
                  initialValue: _phoneNumber,
                  inputDecoration: const InputDecoration(
                      labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Birthdate Picker
                TextFormField(
                  controller: _dateNaissanceController,
                  readOnly: true,
                  onTap: _pickDate,
                  decoration: const InputDecoration(
                    labelText: 'Birthdate',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your birthdate';
                    }
                    final DateTime? birthdate = DateTime.tryParse(value);
                    if (birthdate == null) {
                      return 'Invalid birthdate';
                    }
                    int age = DateTime
                        .now()
                        .year - birthdate.year;
                    if (DateTime
                        .now()
                        .month < birthdate.month ||
                        (DateTime
                            .now()
                            .month == birthdate.month &&
                            DateTime
                                .now()
                                .day < birthdate.day)) {
                      age--;
                    }
                    if (_selectedRole == 'Doctor' && age < 25) {
                      return 'Doctors must be at least 25 years old';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Checkbox for terms agreement
                Row(
                  children: [
                    Checkbox(
                      value: _isChecked,
                      onChanged: (value) {
                        setState(() {
                          _isChecked = value!;
                        });
                      },
                    ),
                    const Text("I agree to the terms and conditions."),
                  ],
                ),
                const SizedBox(height: 20),
                // Register Button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

