import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/item.dart';

/// Penyimpanan data lokal (SQLite) + state untuk UI.
class InventoryStore extends ChangeNotifier {
  late final Database _db;
  List<Item> items = [];

  Future<void> init() async {
    final path = p.join(await getDatabasesPath(), 'inventaris.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) => db.execute('''
        CREATE TABLE items(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          kode TEXT NOT NULL,
          nama TEXT NOT NULL,
          kategori TEXT NOT NULL,
          jumlah INTEGER NOT NULL DEFAULT 0,
          satuan TEXT NOT NULL DEFAULT 'pcs',
          min_stok INTEGER NOT NULL DEFAULT 0,
          harga INTEGER NOT NULL DEFAULT 0,
          lokasi TEXT NOT NULL DEFAULT '',
          catatan TEXT NOT NULL DEFAULT '',
          updated_at INTEGER NOT NULL
        )
      '''),
    );
    final rows = await _db.query('items');
    items = rows.map(Item.fromMap).toList();
    _sort();
  }

  void _sort() =>
      items.sort((a, b) => a.nama.toLowerCase().compareTo(b.nama.toLowerCase()));

  // ---- Statistik ----
  int get totalJenis => items.length;
  int get totalStok => items.fold(0, (s, i) => s + i.jumlah);
  int get totalNilai => items.fold(0, (s, i) => s + i.nilai);
  List<Item> get menipis => items.where((i) => i.menipis).toList();

  List<String> get categories =>
      (items.map((i) => i.kategori).toSet().toList()..sort());

  Map<String, int> get stokPerKategori {
    final m = <String, int>{};
    for (final i in items) {
      m[i.kategori] = (m[i.kategori] ?? 0) + i.jumlah;
    }
    final entries = m.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  String nextKode() {
    var maxN = 0;
    for (final i in items) {
      final m = RegExp(r'(\d+)$').firstMatch(i.kode);
      if (m != null) maxN = math.max(maxN, int.parse(m.group(1)!));
    }
    return 'BRG-${(maxN + 1).toString().padLeft(3, '0')}';
  }

  // ---- Operasi data ----
  Future<void> save(Item it) async {
    if (it.id == null) {
      final id = await _db.insert('items', it.toMap());
      items = [...items, it.copyWith(id: id)];
    } else {
      await _db.update('items', it.toMap(), where: 'id = ?', whereArgs: [it.id]);
      items = [for (final x in items) x.id == it.id ? it : x];
    }
    _sort();
    notifyListeners();
  }

  Future<void> adjust(Item it, int delta) async {
    final baru = math.max(0, it.jumlah + delta);
    if (baru == it.jumlah) return;
    await save(it.copyWith(jumlah: baru, updatedAt: DateTime.now()));
  }

  Future<void> delete(int id) async {
    items = items.where((x) => x.id != id).toList();
    notifyListeners();
    await _db.delete('items', where: 'id = ?', whereArgs: [id]);
  }
}
