import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:master_demo_app/Api/firebase-config.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


// Add a new user
Future<DocumentReference> addNewUser(String id, String email, String name, String surname) {
  final usersCollectionRef = db.collection('users');
  return usersCollectionRef.add({
    'Email': email,
    'Uid': id,
    'Name': name,
    'Surname': surname,
  });
}

// Check if user exists
Future<bool> userExists(String id) async {
  final usersCollectionRef = db.collection('users');
  final userQuery = await usersCollectionRef.where('Uid', isEqualTo: id).get();
  return userQuery.docs.isNotEmpty;
}

// Add Expense Transaction
Future<DocumentReference> addETransaction(Map<String, dynamic> expense) async {
  final expenseCollectionRef = db.collection('ExpenseTransactions');
  return expenseCollectionRef.add(expense);
}

// Add Income Transaction
Future<void> addITransaction(Map<String, dynamic> income) async {
  final incomeCollectionRef = db.collection('IncomeTransactions');
  final existing = await existingITransaction(income['Description']);
  if (existing.length > 1) {
    final docRef = existing.first.reference;
    await docRef.update({
      'ExpectedAmount': income['ExpectedAmount'],
      'Received': income['Received'],
      'Category': income['Category'],
    });
  } else {
    await incomeCollectionRef.add(income);
  }
}

// Find existing income transactions by description
Future<List<QueryDocumentSnapshot>> existingITransaction(String description) async {
  final incomeCollectionRef = db.collection('IncomeTransactions');
  final transactionQuery = await incomeCollectionRef.where('Description', isEqualTo: description).get();
  return transactionQuery.docs;
}

// Find existing expense transactions by description
Future<List<QueryDocumentSnapshot>> existingETransaction(String description) async {
  final expenseCollectionRef = db.collection('ExpenseTransactions');
  final transactionQuery = await expenseCollectionRef.where('Description', isEqualTo: description).get();
  return transactionQuery.docs;
}

// Get income transactions for current user, current month
Future<List<QueryDocumentSnapshot>> getIncomeTransactions(String uid) async {
  final incomeCollectionRef = db.collection('IncomeTransactions');
  final now = DateTime.now();
  final transactionQuery = await incomeCollectionRef.where('Uid', isEqualTo: uid).get();
  return transactionQuery.docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? dateObj;
    if (data['Date'] is Timestamp) {
      dateObj = (data['Date'] as Timestamp).toDate();
    } else if (data['Date'] is String) {
      dateObj = DateTime.tryParse(data['Date']);
    }
    return dateObj != null &&
        dateObj.month == now.month &&
        dateObj.year == now.year;
  }).toList();
}

// Get expense transactions for current user, current month
Future<List<QueryDocumentSnapshot>> getExpenseTransactions(String uid) async {
  final expenseCollectionRef = db.collection('ExpenseTransactions');
  final now = DateTime.now();
  final transactionQuery = await expenseCollectionRef.where('Uid', isEqualTo: uid).get();
  return transactionQuery.docs.where((doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? dateObj;
    if (data['Date'] is Timestamp) {
      dateObj = (data['Date'] as Timestamp).toDate();
    } else if (data['Date'] is String) {
      dateObj = DateTime.tryParse(data['Date']);
    }
    return dateObj != null &&
        dateObj.month == now.month &&
        dateObj.year == now.year;
  }).toList();
}

// Add a new chapter document to Firestore
Future<DocumentReference> addChapter(Map<String, dynamic> chapter) async {
  final chaptersCollectionRef = db.collection('chapters');
  return chaptersCollectionRef.add(chapter);
}

// Function to add all chapters from a JSON array
Future<void> addAllChaptersFromJsonAsset(String assetPath) async {
  final jsonString = await rootBundle.loadString(assetPath);
  final List<dynamic> chaptersJson = jsonDecode(jsonString);
  for (final chapter in chaptersJson) {
    await addChapter(chapter as Map<String, dynamic>);
  }
}

// Get all chapters from Firestore
Future<List<Map<String, dynamic>>> getAllChapters() async {
  final chaptersCollectionRef = db.collection('chapters');
  final querySnapshot = await chaptersCollectionRef.get();
  return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}

// Example usage of addChapter:
//
// import 'package:master_demo_app/Api/hooks/database.dart';
//
// void createSampleChapter() async {
//   final chapter = {
//     "chapter": "Sample Chapter",
//     "content": [
//       {"type": "heading", "text": "Sample Heading", "style": {"fontSize": 28, "color": "#1E3A8A", "bold": true}},
//       {"type": "paragraph", "text": "This is a sample paragraph for the new chapter."}
//     ],
//     "language": "English"
//   };
//   final docRef = await addChapter(chapter);
//   print('Chapter added with ID: \\${docRef.id}');
// }
//
// Call createSampleChapter() from your UI or logic to add a chapter to Firestore.
//
// Usage for adding chapters from JSON asset:
// await addAllChaptersFromJsonAsset('lib/Api/data/chapter1content.json');
//
// Example usage of getAllChapters:
//
// void fetchAndPrintChapters() async {
//   final chapters = await getAllChapters();
//   for (final chapter in chapters) {
//     print('Chapter: \\${chapter['chapter']}');
//     // You can also access chapter['content']
//   }
// }
//
// Call fetchAndPrintChapters() from your UI or logic to print all chapters from Firestore.