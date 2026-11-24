import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/item.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets.dart';

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({super.key, required this.store, this.item});

  final InventoryStore store;
  final Item? item;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _key = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _jumlah;
  late final TextEditingController _satuan;
  late final TextEditingController _min;
  late final TextEditingController _harga;
  late final TextEditingController _lokasi;
  late final TextEditingController _catatan;
  late String _kategori;
  bool _saving = false;

  bool get _edit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final i = widget.item;
    _nama = TextEditingController(text: i?.nama ?? '');
    _jumlah = TextEditingController(text: '${i?.jumlah ?? 0}');
    _satuan = TextEditingController(text: i?.satuan ?? 'pcs');
    _min = TextEditingController(text: '${i?.minStok ?? 0}');
    _harga = TextEditingController(text: '${i?.harga ?? 0}');
    _lokasi = TextEditingController(text: i?.lokasi ?? '');
    _catatan = TextEditingController(text: i?.catatan ?? '');
    _kategori = i?.kategori ?? Item.kategoriDefault.first;
  }

  @override
  void dispose() {
    for (final c in [_nama, _jumlah, _satuan, _min, _harga, _lokasi, _catatan]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_key.currentState!.validate()) return;
    setState(() => _saving = true);
    final it = Item(
      id: widget.item?.id,
      kode: widget.item?.kode ?? widget.store.nextKode(),
      nama: _nama.text.trim(),
      kategori: _kategori,
      jumlah: int.tryParse(_jumlah.text.trim()) ?? 0,
      satuan: _satuan.text.trim().isEmpty ? 'pcs' : _satuan.text.trim(),
      minStok: int.tryParse(_min.text.trim()) ?? 0,
      harga: int.tryParse(_harga.text.trim()) ?? 0,
      lokasi: _lokasi.text.trim(),
      catatan: _catatan.text.trim(),
      updatedAt: DateTime.now(),
    );
    await widget.store.save(it);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final ok = await confirmDialog(
      context,
      title: 'Hapus barang?',
      message: '"${widget.item!.nama}" akan dihapus permanen.',
    );
    if (!ok) return;
    await widget.store.delete(widget.item!.id!);
    if (mounted) Navigator.of(context).pop();
  }

  Widget _num(String label, TextEditingController c) => TextFormField(
        controller: c,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: label),
      );

  @override
  Widget build(BuildContext context) {
    final opts = <String>{
      ...Item.kategoriDefault,
      ...widget.store.categories,
      _kategori,
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_edit ? 'Ubah barang' : 'Barang baru', style: serif(22)),
        actions: [
          if (_edit)
            IconButton(
              onPressed: _delete,
              icon: const Icon(Icons.delete_outline, color: C.danger),
              tooltip: 'Hapus',
            ),
        ],
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (_edit)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text('Kode ${widget.item!.kode}',
                    style: const TextStyle(color: C.muted)),
              ),
            TextFormField(
              controller: _nama,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Nama barang'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Nama barang wajib diisi'
                  : null,
            ),
            const SizedBox(height: 18),
            const Text('Kategori',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: C.muted, fontSize: 13)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in opts)
                  ChoiceChip(
                    label: Text(k),
                    selected: k == _kategori,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _kategori = k),
                    selectedColor: C.accentSoft,
                    backgroundColor: C.card,
                    side: BorderSide(
                        color: k == _kategori ? C.accent : C.border),
                    labelStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: k == _kategori ? C.accent : C.text,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _num('Jumlah stok', _jumlah)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _satuan,
                    decoration: const InputDecoration(
                        labelText: 'Satuan', hintText: 'pcs, rim, box'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _num('Stok minimum', _min)),
                const SizedBox(width: 12),
                Expanded(child: _num('Harga satuan (Rp)', _harga)),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _lokasi,
              decoration: const InputDecoration(
                  labelText: 'Lokasi penyimpanan',
                  hintText: 'Contoh: Lemari A, Rak 2'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _catatan,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Catatan'),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: Text(_edit ? 'Simpan perubahan' : 'Simpan barang'),
            ),
          ],
        ),
      ),
    );
  }
}
