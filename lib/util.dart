const _bulan = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
  'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
];

String _dua(int n) => n.toString().padLeft(2, '0');

/// 1250000 -> "1.250.000"
String ribuan(int v) {
  final s = v.abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write('.');
    out.write(s[i]);
  }
  return '${v < 0 ? '-' : ''}$out';
}

String rupiah(int v) => 'Rp ${ribuan(v)}';

String tgl(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

String jam(DateTime d) => '${_dua(d.hour)}.${_dua(d.minute)}';

/// Untuk nama file: 20261124_1242
String stamp(DateTime d) =>
    '${d.year}${_dua(d.month)}${_dua(d.day)}_${_dua(d.hour)}${_dua(d.minute)}';

String sapaan() {
  final h = DateTime.now().hour;
  if (h < 11) return 'Selamat pagi';
  if (h < 15) return 'Selamat siang';
  if (h < 18) return 'Selamat sore';
  return 'Selamat malam';
}
