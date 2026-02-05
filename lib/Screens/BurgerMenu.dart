import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Models/models.dart';
import 'Login.dart';

class BurgerMenu extends StatelessWidget {
  final List<Chapter> chapters;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;
  final bool loading;

  const BurgerMenu({
    super.key,
    required this.chapters,
    this.selectedIndex,
    this.onSelect,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'Menu',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
                if (loading || chapters.isEmpty) ...[
                  const ListTile(
                    title: Text('Loading chapters...'),
                  ),
                ] else ...chapters.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final chap = entry.value;
                  return ListTile(
                    title: Text(
                      chap.chapter,
                      style: TextStyle(
                        fontWeight: selectedIndex == idx ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: selectedIndex == idx,
                    selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                    onTap: () {
                      Navigator.pop(context);
                      if (onSelect != null) onSelect!(idx);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: ElevatedButton.icon(
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.red,
          //       foregroundColor: Colors.white,
          //       minimumSize: const Size.fromHeight(48),
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //     ),
          //     icon: const Icon(Icons.logout),
          //     label: const Text('Logout'),
          //     onPressed: () {
          //       logout(context);
          //     },
          //   ),
          // ),
        ],
      ),
    );
  }
}

void logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (route) => false,
  );
}
