import  'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:medical/Screens/Views/Screen1.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:provider/provider.dart';  // Add the provider package
import 'firebase_options.dart';
import 'package:medical/UserModel.dart';  // Import the UserModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Check if the error is a FlutterError (this is typically the overflow error)

      return Container(); // Return an empty container to suppress the error message

  // Default error widget for other exceptions
  };

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Provide UserModel at the top of the widget tree
    ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: const Medics(),
    ),
  );

}

class Medics extends StatelessWidget {
  const Medics({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Screen1(),
      );
    });
  }
}
