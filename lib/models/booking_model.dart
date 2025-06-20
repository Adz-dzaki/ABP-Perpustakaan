class BookingModel {
  final String namaBuku;
  final String author;
  final String jenisBuku;
  final String tipeBuku;
  final String tglTerbit;
  final String rakBuku;
  final DateTime bookingDate;
  final DateTime expiredDate;
  int denda;

  BookingModel({
    required this.namaBuku,
    required this.author,
    required this.jenisBuku,
    required this.tipeBuku,
    required this.tglTerbit,
    required this.rakBuku,
    required this.bookingDate,
    required this.expiredDate,
    this.denda = 0,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      namaBuku: json['nama_buku'],
      author: json['author'],
      jenisBuku: json['jenis_buku'],
      tipeBuku: json['tipe_buku'],
      tglTerbit: json['tgl_terbit'],
      rakBuku: json['rakbuku_id_fk'].toString(),
      bookingDate: DateTime.parse(json['booking_date'] ),
      expiredDate: DateTime.parse(json['expired_date'] ),
    );
  }
}
