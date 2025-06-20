import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/booking_model.dart';
import '../service/booking_service.dart';
import 'package:dashboard_perpus/widgets/custom_header.dart';

class BookingPage extends StatefulWidget {
  final int accountId;

  const BookingPage({super.key, required this.accountId});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<BookingModel> bookings = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null).then((_) {
      fetchBookings();
    });
  }

  Future<void> fetchBookings() async {
    if (!mounted) return;
    setState(() { isLoading = true; errorMessage = null; });

    try {
      final fetchedBookings = await BookingService().fetchBookingsByAccountId(widget.accountId);
      if (!mounted) return;

      final processedBookings = fetchedBookings.map((booking) {
        final today = DateTime.now();
        final todayStart = DateTime(today.year, today.month, today.day);
        final expiredDateStart = DateTime(booking.expiredDate.year, booking.expiredDate.month, booking.expiredDate.day);

        if (expiredDateStart.isBefore(todayStart)) {
          final differenceInDays = todayStart.difference(expiredDateStart).inDays;
          final daysToCharge = differenceInDays > 7 ? 7 : differenceInDays;
          booking.denda = daysToCharge * 30000;
        }
        return booking;
      }).toList();

      setState(() => bookings = processedBookings);

    } catch (e) {
      if (!mounted) return;
      setState(() => errorMessage = 'Terjadi kesalahan saat memuat data.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'id_ID').format(date.toLocal());
  }

  // --- PENAMBAHAN FUNGSI YANG HILANG ---
  String getRakLabel(String rakId) {
    final int id = int.tryParse(rakId) ?? 0;
    switch (id) {
      case 1: return 'Fiksi';
      case 2: return 'Non-Fiksi';
      case 3: return 'Referensi';
      case 4: return 'Science';
      case 5: return 'Comic';
      default: return 'Lainnya';
    }
  }
  // --- AKHIR PENAMBAHAN ---

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey[600]),
          const SizedBox(width: 10),
          Text("$label: ", style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: Colors.grey[800], fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: TextStyle(fontFamily: 'Poppins', fontSize: 13, color: valueColor ?? Colors.black87, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: CustomHeader(
                onMenuTap: () => Scaffold.of(context).openDrawer(),
                onLogoutTap: () {
                  // Logika logout Anda
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Daftar Booking Saya',
                style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 24, color: Colors.blue.shade900),
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
                  : errorMessage != null
                  ? _buildErrorState(errorMessage!)
                  : bookings.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: fetchBookings,
                color: Colors.blue.shade700,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final bool isExpired = booking.expiredDate.isBefore(DateTime.now());

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isExpired ? Colors.red.shade200 : Colors.grey.shade300, width: isExpired ? 1.5 : 1)
                      ),
                      color: isExpired ? Colors.red.shade50 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(booking.namaBuku, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0D47A1))),
                            const SizedBox(height: 10),
                            _buildDetailRow(Icons.person_outline, "Penulis", booking.author),
                            _buildDetailRow(Icons.category_outlined, "Jenis", booking.jenisBuku),
                            _buildDetailRow(Icons.shelves, "Rak", getRakLabel(booking.rakBuku)),
                            _buildDetailRow(Icons.calendar_today_outlined, "Terbit", DateFormat('yyyy').format(DateTime.parse(booking.tglTerbit))),
                            Divider(height: 24, color: Colors.grey.shade300),
                            _buildDetailRow(Icons.bookmark_add_outlined, "Tanggal Booking", _formatDate(booking.bookingDate)),
                            _buildDetailRow(
                              Icons.event_busy_outlined, "Batas Kembali", _formatDate(booking.expiredDate),
                              valueColor: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                              isBold: true,
                            ),
                            if (isExpired && booking.denda > 0)
                              Padding(
                                padding: const EdgeInsets.only(top: 12.0),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber.shade300)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Denda Keterlambatan:", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.orange.shade800)),
                                      Text(NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(booking.denda), style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade800)),
                                    ],
                                  ),
                                ),
                              )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.bookmark_border_rounded, size: 100, color: Colors.blueGrey[200]),
      const SizedBox(height: 20),
      const Text("Belum Ada Booking", style: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
      const SizedBox(height: 8),
      Text("Semua buku yang Anda booking akan muncul di sini.", style: TextStyle(fontFamily: 'Poppins', fontSize: 14, color: Colors.blueGrey[300]), textAlign: TextAlign.center),
    ])));
  }

  Widget _buildErrorState(String message) {
    return Center(child: Padding(padding: const EdgeInsets.all(20.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.cloud_off, size: 80, color: Colors.grey[400]), const SizedBox(height: 16),
      Text("Oops, Terjadi Kesalahan", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
      const SizedBox(height: 8),
      Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600], fontFamily: 'Poppins'), textAlign: TextAlign.center),
      const SizedBox(height: 20),
      ElevatedButton.icon(onPressed: fetchBookings, icon: const Icon(Icons.refresh), label: const Text("Coba Lagi"))
    ])));
  }
}