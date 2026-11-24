import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/item.dart';
import '../util.dart';

class ExportService {
  static Future<File> _tulis(String nama, List<int> bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$nama');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ---------------------------------------------------------------- Excel
  static Future<File> buildExcel(List<Item> items) async {
    final now = DateTime.now();
    final ex = Excel.createExcel();

    const sheetData = 'Inventaris';
    final defaultSheet = ex.getDefaultSheet();
    if (defaultSheet != null && defaultSheet != sheetData) {
      ex.rename(defaultSheet, sheetData);
    }
    final sheet = ex[sheetData];

    final headers = [
      'No', 'Kode', 'Nama Barang', 'Kategori', 'Jumlah', 'Satuan',
      'Stok Min.', 'Harga Satuan (Rp)', 'Nilai Total (Rp)', 'Lokasi',
      'Status', 'Catatan', 'Terakhir Diperbarui',
    ];

    final headStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#D97757'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final totalStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#F6E3DA'),
    );

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());
    for (var c = 0; c < headers.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: 0))
          .cellStyle = headStyle;
    }

    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      sheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(it.kode),
        TextCellValue(it.nama),
        TextCellValue(it.kategori),
        IntCellValue(it.jumlah),
        TextCellValue(it.satuan),
        IntCellValue(it.minStok),
        IntCellValue(it.harga),
        IntCellValue(it.nilai),
        TextCellValue(it.lokasi),
        TextCellValue(it.status),
        TextCellValue(it.catatan),
        TextCellValue('${tgl(it.updatedAt)} ${jam(it.updatedAt)}'),
      ]);
    }

    final totalStok = items.fold<int>(0, (s, i) => s + i.jumlah);
    final totalNilai = items.fold<int>(0, (s, i) => s + i.nilai);
    sheet.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('TOTAL'),
      TextCellValue(''),
      IntCellValue(totalStok),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      IntCellValue(totalNilai),
    ]);
    final totalRow = items.length + 1;
    for (var c = 0; c < headers.length; c++) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: totalRow))
          .cellStyle = totalStyle;
    }

    const widths = [5.0, 11.0, 30.0, 16.0, 9.0, 9.0, 10.0, 18.0, 17.0, 20.0, 11.0, 28.0, 20.0];
    for (var c = 0; c < widths.length; c++) {
      sheet.setColumnWidth(c, widths[c]);
    }

    // Lembar ringkasan
    final ring = ex['Ringkasan'];
    ring.appendRow([TextCellValue('Laporan Inventaris Barang Kantor')]);
    ring.appendRow([TextCellValue('')]);
    ring.appendRow([
      TextCellValue('Tanggal ekspor'),
      TextCellValue('${tgl(now)} ${jam(now)}'),
    ]);
    ring.appendRow([TextCellValue('Jumlah jenis barang'), IntCellValue(items.length)]);
    ring.appendRow([TextCellValue('Total stok'), IntCellValue(totalStok)]);
    ring.appendRow([
      TextCellValue('Barang menipis / habis'),
      IntCellValue(items.where((i) => i.menipis).length),
    ]);
    ring.appendRow([TextCellValue('Nilai total aset (Rp)'), IntCellValue(totalNilai)]);
    ring.setColumnWidth(0, 28);
    ring.setColumnWidth(1, 24);
    ring.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle =
        CellStyle(bold: true, fontSize: 14);

    final bytes = ex.encode();
    if (bytes == null) throw Exception('Gagal membuat file Excel');
    return _tulis('Inventaris_Kantor_${stamp(now)}.xlsx', bytes);
  }

  // ------------------------------------------------------------------ PDF
  static Future<File> buildPdf(List<Item> items) async {
    final now = DateTime.now();
    final accent = PdfColor.fromInt(0xFFD97757);
    final totalStok = items.fold<int>(0, (s, i) => s + i.jumlah);
    final totalNilai = items.fold<int>(0, (s, i) => s + i.nilai);
    final low = items.where((i) => i.menipis).length;

    pw.Widget kpi(String label, String value) => pw.Container(
          margin: const pw.EdgeInsets.only(right: 10),
          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(label,
                  style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
              pw.SizedBox(height: 2),
              pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 13, fontWeight: pw.FontWeight.bold)),
            ],
          ),
        );

    final doc = pw.Document(title: 'Laporan Inventaris Kantor');
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.fromLTRB(32, 32, 32, 36),
        footer: (ctx) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text('Inventaris Barang Kantor',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            pw.Text('Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
          ],
        ),
        build: (ctx) => [
          pw.Text('Laporan Inventaris Barang Kantor',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text('Dibuat ${tgl(now)} pukul ${jam(now)}',
              style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
          pw.SizedBox(height: 14),
          pw.Row(children: [
            kpi('Jenis barang', '${items.length}'),
            kpi('Total stok', ribuan(totalStok)),
            kpi('Menipis / habis', '$low'),
            kpi('Nilai aset', rupiah(totalNilai)),
          ]),
          pw.SizedBox(height: 14),
          pw.TableHelper.fromTextArray(
            headers: [
              'No', 'Kode', 'Nama Barang', 'Kategori', 'Jumlah', 'Min.',
              'Harga', 'Nilai', 'Lokasi', 'Status',
            ],
            data: [
              for (var i = 0; i < items.length; i++)
                [
                  '${i + 1}',
                  items[i].kode,
                  items[i].nama,
                  items[i].kategori,
                  '${items[i].jumlah} ${items[i].satuan}',
                  '${items[i].minStok}',
                  rupiah(items[i].harga),
                  rupiah(items[i].nilai),
                  items[i].lokasi,
                  items[i].status,
                ],
            ],
            headerStyle: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white),
            headerDecoration: pw.BoxDecoration(color: accent),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellPadding:
                const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            border: pw.TableBorder(
              horizontalInside: pw.BorderSide(color: PdfColors.grey300),
              bottom: pw.BorderSide(color: PdfColors.grey400),
            ),
            oddRowDecoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFFFAF9F5)),
            columnWidths: {
              0: const pw.FixedColumnWidth(26),
              1: const pw.FixedColumnWidth(48),
              2: const pw.FlexColumnWidth(2.6),
              3: const pw.FlexColumnWidth(1.5),
              8: const pw.FlexColumnWidth(1.6),
            },
            cellAlignments: {
              0: pw.Alignment.center,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.centerRight,
              6: pw.Alignment.centerRight,
              7: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    return _tulis('Inventaris_Kantor_${stamp(now)}.pdf', bytes);
  }

  // -------------------------------------------------------------- Bagikan
  static Future<void> share(File file) async {
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Laporan Inventaris Kantor',
    );
  }
}
