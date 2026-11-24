import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key, required this.store, required this.onEdit});

  final InventoryStore store;
  final void Function(Item) onEdit;

  @override
  State<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends State<ItemsPage> {
  String _q = '';
  String _cat = 'Semua';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final cats = ['Semua', ...widget.store.categories];
        final active = cats.contains(_cat) ? _cat : 'Semua';
        final list = widget.store.items.where((i) {
          final okCat = active == 'Semua' || i.kategori == active;
          final okQ = _q.isEmpty ||
              i.nama.toLowerCase().contains(_q) ||
              i.kode.toLowerCase().contains(_q);
          return okCat && okQ;
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Barang', style: serif(30)),
                  const Spacer(),
                  Text('${list.length} item',
                      style: const TextStyle(color: C.muted)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
                decoration: const InputDecoration(
                  hintText: 'Cari nama atau kode barang',
                  prefixIcon: Icon(Icons.search, color: C.muted),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: cats.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final c = cats[i];
                  final sel = c == active;
                  return ChoiceChip(
                    label: Text(c),
                    selected: sel,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _cat = c),
                    selectedColor: C.accentSoft,
                    backgroundColor: C.card,
                    side: BorderSide(color: sel ? C.accent : C.border),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: sel ? C.accent : C.text,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? Center(
                      child: Text(
                        widget.store.items.isEmpty
                            ? 'Belum ada barang.'
                            : 'Tidak ada barang yang cocok.',
                        style: const TextStyle(color: C.muted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _tile(list[i]),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _tile(Item it) {
    final Color pillColor = it.jumlah == 0
        ? C.danger
        : (it.menipis ? C.warn : C.ok);
    final Color pillBg = it.jumlah == 0
        ? C.dangerSoft
        : (it.menipis ? C.warnSoft : C.okSoft);

    return Dismissible(
      key: ValueKey(it.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: C.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) => confirmDialog(
        context,
        title: 'Hapus barang?',
        message: '"${it.nama}" akan dihapus permanen.',
      ),
      onDismissed: (_) => widget.store.delete(it.id!),
      child: Panel(
        padding: const EdgeInsets.all(12),
        onTap: () => widget.onEdit(it),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: C.accentSoft,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconFor(it.kategori), color: C.accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    it.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    it.lokasi.isEmpty ? it.kode : '${it.kode} • ${it.lokasi}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: C.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Pill(it.status, color: pillColor, bg: pillBg),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _StepBtn(Icons.remove, () => widget.store.adjust(it, -1)),
            SizedBox(
              width: 44,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${it.jumlah}', style: serif(18, weight: FontWeight.w700)),
                  Text(
                    it.satuan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: C.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            _StepBtn(Icons.add, () => widget.store.adjust(it, 1)),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  const _StepBtn(this.icon, this.onTap);

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.surface,
      shape: const CircleBorder(side: BorderSide(color: C.border)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 30,
          height: 30,
          child: Icon(icon, size: 16),
        ),
      ),
    );
  }
}
