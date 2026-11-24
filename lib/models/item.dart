class Item {
  const Item({
    this.id,
    required this.kode,
    required this.nama,
    required this.kategori,
    this.jumlah = 0,
    this.satuan = 'pcs',
    this.minStok = 0,
    this.harga = 0,
    this.lokasi = '',
    this.catatan = '',
    required this.updatedAt,
  });

  final int? id;
  final String kode;
  final String nama;
  final String kategori;
  final int jumlah;
  final String satuan;
  final int minStok;
  final int harga;
  final String lokasi;
  final String catatan;
  final DateTime updatedAt;

  static const kategoriDefault = [
    'Alat Tulis',
    'Kertas & Cetak',
    'Elektronik',
    'Furnitur',
    'Kebersihan',
    'Konsumsi',
    'Lainnya',
  ];

  bool get menipis => jumlah <= minStok;
  int get nilai => jumlah * harga;
  String get status => jumlah == 0 ? 'Habis' : (menipis ? 'Menipis' : 'Aman');

  Item copyWith({int? id, int? jumlah, DateTime? updatedAt}) => Item(
        id: id ?? this.id,
        kode: kode,
        nama: nama,
        kategori: kategori,
        jumlah: jumlah ?? this.jumlah,
        satuan: satuan,
        minStok: minStok,
        harga: harga,
        lokasi: lokasi,
        catatan: catatan,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'kode': kode,
        'nama': nama,
        'kategori': kategori,
        'jumlah': jumlah,
        'satuan': satuan,
        'min_stok': minStok,
        'harga': harga,
        'lokasi': lokasi,
        'catatan': catatan,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      };

  factory Item.fromMap(Map<String, Object?> m) => Item(
        id: m['id'] as int,
        kode: m['kode'] as String,
        nama: m['nama'] as String,
        kategori: m['kategori'] as String,
        jumlah: m['jumlah'] as int,
        satuan: m['satuan'] as String,
        minStok: m['min_stok'] as int,
        harga: m['harga'] as int,
        lokasi: m['lokasi'] as String,
        catatan: m['catatan'] as String,
        updatedAt:
            DateTime.fromMillisecondsSinceEpoch(m['updated_at'] as int),
      );
}
