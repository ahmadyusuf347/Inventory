import 'package:flutter/material.dart';

import '../services/export_service.dart';
import '../services/store.dart';
import '../theme.dart';
import '../widgets.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key, required this.store});

  final InventoryStore store;

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  bool _onlyLow = false;
  String? _busy;

  Future<void> _run(String kind) async {
    final data = _onlyLow ? widget.store.menipis : widget.store.items;
    if (data.isEmpty) {
      _snack('Tidak ada data untuk diekspor.');
      return;
    }
    setState(() => _busy = kind);
    try {
      final file = kind == 'xlsx'
          ? await ExportService.buildExcel(data)
          : await ExportService.buildPdf(data);
      await ExportService.share(file);
    } catch (e) {
      _snack('Gagal ekspor: $e');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.store,
      builder: (context, _) {
        final n = _onlyLow ? widget.store.menipis.length : widget.store.totalJenis;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text('Ekspor data', style: serif(30)),
            const SizedBox(height: 4),
            const Text(
              'Simpan atau kirim laporan inventaris dalam bentuk file.',
              style: TextStyle(color: C.muted),
            ),
            const SizedBox(height: 20),
            Panel(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Hanya stok menipis',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('$n barang akan diekspor',
                            style: const TextStyle(
                                color: C.muted, fontSize: 13)),
                      ],
                    ),
                  ),
                  Switch(
                    value: _onlyLow,
                    onChanged: (v) => setState(() => _onlyLow = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _FormatCard(
              icon: Icons.table_chart_outlined,
              color: C.ok,
              bg: C.okSoft,
              title: 'Excel (.xlsx)',
              desc: 'Tabel lengkap untuk diolah lagi, plus lembar ringkasan.',
              loading: _busy == 'xlsx',
              enabled: _busy == null,
              onTap: () => _run('xlsx'),
            ),
            const SizedBox(height: 12),
            _FormatCard(
              icon: Icons.picture_as_pdf_outlined,
              color: C.danger,
              bg: C.dangerSoft,
              title: 'PDF (.pdf)',
              desc: 'Laporan siap cetak dalam format A4 lanskap.',
              loading: _busy == 'pdf',
              enabled: _busy == null,
              onTap: () => _run('pdf'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Setelah file dibuat, pilih tujuan di menu berbagi: simpan ke '
              'penyimpanan, Google Drive, WhatsApp, email, dan lainnya.',
              style: TextStyle(color: C.muted, fontSize: 13, height: 1.4),
            ),
          ],
        );
      },
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.icon,
    required this.color,
    required this.bg,
    required this.title,
    required this.desc,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final String title;
  final String desc;
  final bool loading;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: serif(18)),
                    const SizedBox(height: 2),
                    Text(desc,
                        style: const TextStyle(color: C.muted, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: enabled ? onTap : null,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.ios_share, size: 18),
              label: Text(loading ? 'Membuat file…' : 'Ekspor & bagikan'),
            ),
          ),
        ],
      ),
    );
  }
}
