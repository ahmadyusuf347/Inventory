import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/store.dart';
import '../theme.dart';
import 'dashboard_page.dart';
import 'export_page.dart';
import 'item_form_page.dart';
import 'items_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.store});

  final InventoryStore store;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _idx = 0;

  void _openForm([Item? item]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ItemFormPage(store: widget.store, item: item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _idx,
          children: [
            DashboardPage(
              store: widget.store,
              onEdit: _openForm,
              onSeeAll: () => setState(() => _idx = 1),
            ),
            ItemsPage(store: widget.store, onEdit: _openForm),
            ExportPage(store: widget.store),
          ],
        ),
      ),
      floatingActionButton: _idx == 2
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _openForm(),
              backgroundColor: C.accent,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.add),
              label: const Text('Tambah',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.space_dashboard_outlined),
            selectedIcon: Icon(Icons.space_dashboard, color: C.accent),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: C.accent),
            label: 'Barang',
          ),
          NavigationDestination(
            icon: Icon(Icons.ios_share_outlined),
            selectedIcon: Icon(Icons.ios_share, color: C.accent),
            label: 'Ekspor',
          ),
        ],
      ),
    );
  }
}
