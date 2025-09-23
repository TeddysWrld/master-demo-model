import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Your web app's Firebase configuration
const firebaseConfig = FirebaseOptions(
  apiKey: "AIzaSyBIwgtiPMbYEf8h-LAKUKk3jB6RCIpHxnU",
  authDomain: "masters-demo-app.firebaseapp.com",
  projectId: "masters-demo-app",
  storageBucket: "masters-demo-app.appspot.com",
  messagingSenderId: "979285665506",
  appId: "1:979285665506:web:8ae28970bf706ae1c6a0bb",
  measurementId: "G-CS06F1DMGH",
);

Future<FirebaseApp> initFirebase() async {
  return await Firebase.initializeApp(options: firebaseConfig);
}

final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore db = FirebaseFirestore.instance;
