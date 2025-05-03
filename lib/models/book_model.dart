class BookModel {
  final String namaBuku;
  final String author;
  final String jenisBuku;
  final String tipeBuku;
  final String tanggalTerbit;
  final int rakbukuId;
  final int statusBooking;

  BookModel({
    required this.namaBuku,
    required this.author,
    required this.jenisBuku,
    required this.tipeBuku,
    required this.tanggalTerbit,
    required this.rakbukuId,
    required this.statusBooking,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      namaBuku: json['nama_buku'],
      author: json['author'],
      jenisBuku: json['jenis_buku'],
      tipeBuku: json['tipe_buku'],
      tanggalTerbit: json['tgl_terbit'],
      rakbukuId: json['rakbuku_id_fk'],
        statusBooking: json['status_booking'] is bool
            ? (json['status_booking'] ? 1 : 0)
            : json['status_booking'] ?? 0,
    );
  }

  String get rakLabel {
    switch (rakbukuId) {
      case 1: return 'Fiksi';
      case 2: return 'Non-Fiksi';
      case 3: return 'Referensi';
      case 4: return 'Science';
      case 5: return 'Comic';
      default: return 'Tidak diketahui';
    }
  }

  String get statusLabel => statusBooking == 0 ? 'Tersedia' : 'Tidak Tersedia';
}
