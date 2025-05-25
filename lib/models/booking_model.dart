class BookingModel {
  final String namaBuku;
  final String author;
  final String jenisBuku;
  final String tipeBuku;
  final String tglTerbit;
  final String rakBuku;
  final DateTime bookingDate;  // Ganti String menjadi DateTime
  final DateTime expiredDate;  // Ganti String menjadi DateTime

  BookingModel({
    required this.namaBuku,
    required this.author,
    required this.jenisBuku,
    required this.tipeBuku,
    required this.tglTerbit,
    required this.rakBuku,
    required this.bookingDate,
    required this.expiredDate,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      namaBuku: json['nama_buku'],
      author: json['author'],
      jenisBuku: json['jenis_buku'],
      tipeBuku: json['tipe_buku'],
      tglTerbit: json['tgl_terbit'],
      rakBuku: json['rakbuku_id_fk'].toString(),  // Asumsi rakbuku_id_fk adalah angka
      bookingDate: DateTime.parse(json['booking_date']), // Mengonversi ke DateTime
      expiredDate: DateTime.parse(json['expired_date']), // Mengonversi ke DateTime
    );
  }
}
