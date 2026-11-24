import 'package:flutter/material.dart';

import '../models/item.dart';
import '../services/store.dart';
import '../theme.dart';
import '../util.dart';
import '../widgets.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.store,
    required this.onEdit,
    required this.onSeeAll,
  });

  final InventoryStore store;
  final void Function(Item) onEdit;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final low = store.menipis;
        final cats = store.stokPerKategori;
        final maxCat = cats.values.fold<int>(1, (m, v) => v > m ? v : m);
        final recent = [...store.items]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          children: [
            Row(
              children: [
                const Text('✻',
                    style: TextStyle(fontSize: 30, color: C.accent)),
                const SizedBox(width: 10),
                Expanded(child: Text(sapaan(), style: serif(30))),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Ringkasan inventaris barang kantor',
              style: TextStyle(color: C.muted, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Jenis barang',
                    value: ribuan(store.totalJenis),
                    icon: Icons.category_outlined,
                    color: C.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Total stok',
                    value: ribuan(store.totalStok),
                    icon: Icons.layers_outlined,
                    color: C.ok,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Stok menipis',
                    value: ribuan(low.length),
                    icon: Icons.warning_amber_rounded,
                    color: low.isEmpty ? C.muted : C.danger,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Nilai aset',
                    value: rupiah(store.totalNilai),
                    icon: Icons.payments_outlined,
                    color: C.warn,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (store.items.isEmpty)
              Panel(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 40, color: C.muted),
                    const SizedBox(height: 12),
                    Text('Belum ada barang', style: serif(20)),
                    const SizedBox(height: 6),
                    const Text(
                      'Tekan tombol Tambah untuk mencatat barang pertama.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: C.muted),
                    ),
                  ],
                ),
              )
            else ...[
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                            child: Text('Perlu diisi ulang', style: serif(18))),
                        if (low.isNotEmpty)
                          Pill('${low.length} barang',
                              color: C.danger, bg: C.dangerSoft),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (low.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text('Semua stok masih aman.',
                            style: TextStyle(color: C.muted)),
                      )
                    else
                      for (var i = 0; i < low.length && i < 5; i++) ...[
                        if (i > 0) const Divider(height: 1, color: C.border),
                        InkWell(
                          onTap: () => onEdit(low[i]),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        low[i].nama,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Min. ${low[i].minStok} ${low[i].satuan}',
                                        style: const TextStyle(
                                            color: C.muted, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Pill('${low[i].jumlah} ${low[i].satuan}',
                                    color: C.danger, bg: C.dangerSoft),
                              ],
                            ),
                          ),
                        ),
                      ],
                    if (low.length > 5)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: onSeeAll,
                          child: const Text('Lihat semua barang'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stok per kategori', style: serif(18)),
                    const SizedBox(height: 12),
                    for (final e in cats.entries) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(e.key,
                                style: const TextStyle(fontSize: 13)),
                          ),
                          Text('${ribuan(e.value)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: e.value / maxCat,
                          minHeight: 8,
                          backgroundColor: C.accentSoft,
                          color: C.accent,
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Terakhir diperbarui', style: serif(18)),
                    const SizedBox(height: 6),
                    for (var i = 0; i < recent.length && i < 5; i++) ...[
                      if (i > 0) const Divider(height: 1, color: C.border),
                      InkWell(
                        onTap: () => onEdit(recent[i]),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Icon(iconFor(recent[i].kategori),
                                  size: 20, color: C.muted),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  recent[i].nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(tgl(recent[i].updatedAt),
                                  style: const TextStyle(
                                      color: C.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: C.muted, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: serif(26)),
            ),
          ),
        ],
      ),
    );
  }
}
