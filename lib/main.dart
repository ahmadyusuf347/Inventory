import 'package:flutter/material.dart';

import 'screens/home_shell.dart';
import 'services/store.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = InventoryStore();
  await store.init();
  runApp(InventarisApp(store: store));
}

class InventarisApp extends StatelessWidget {
  const InventarisApp({super.key, required this.store});

  final InventoryStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventaris Kantor',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      home: HomeShell(store: store),
    );
  }
}
