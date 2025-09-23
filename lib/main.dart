import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:master_demo_app/Screens/HomeScreen.dart';
import 'package:master_demo_app/Screens/Login.dart';

import 'Api/firebase-config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();
  // await dotenv.load(fileName: "./.env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const apiKey = String.fromEnvironment('API_KEY');
  // This widget is the root of your application.

  	@override
	void initState() {
		print("API Key: $apiKey");
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}