import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
// import 'package:intl/date_symbol_data_local.dart'; // Jika belum di main.dart
import '../models/booking_model.dart';
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

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  Future<void> fetchBookings() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    final url = Uri.parse("http://10.0.2.2:8080/api/booking/bookings/${widget.accountId}");

    try {
      final response = await http.get(url);
      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> bookingList = json.decode(response.body);
        setState(() {
          bookings = bookingList.map((b) => BookingModel.fromJson(b)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat booking: Status ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date.toLocal());
  }

  String _getShelfName(String shelfIdFromModel) {
    switch (shelfIdFromModel) {
      case '1':
        return "Fiksi";
      case '2':
        return "Non-Fiksi";
      case '3':
        return "Referensi";
      case '4':
        return "Science";
      case '5':
        return "Comic";
      default:
        return shelfIdFromModel; // Fallback jika ID tidak dikenal
    }
  }


  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.blueGrey[700]),
          const SizedBox(width: 8),
          Text(
            "$label: ",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: Colors.blueGrey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                color: valueColor ?? Colors.black87,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0,16.0,16.0,0),
              child: CustomHeader(
                onMenuTap: () => Scaffold.of(context).openDrawer(),
                onLogoutTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) { // Ganti nama context jika bentrok
                      return AlertDialog(
                        title: Text("Konfirmasi Logout", style: TextStyle(fontFamily: 'Poppins')),
                        content: Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontFamily: 'Poppins')),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Batal", style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                            onPressed: () => Navigator.of(dialogContext).pop(),
                          ),
                          TextButton(
                            child: Text("Logout", style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Tutup dialog
                              // Gunakan context dari build method untuk navigasi utama
                              Navigator.of(this.context).pushNamedAndRemoveUntil('/login', (route) => false);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Daftar Booking Saya',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Color(0xFF0D47A1),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
                  : bookings.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                onRefresh: fetchBookings,
                color: Colors.blue.shade700,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final bool isExpired = booking.expiredDate.isBefore(DateTime.now());

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isExpired ? Colors.red.shade200 : Colors.transparent,
                            width: 1,
                          )
                      ),
                      color: isExpired ? Colors.red.shade50 : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 70,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.menu_book, color: Colors.grey[700], size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.namaBuku,
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: Color(0xFF0D47A1),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(Icons.person_outline, "Penulis", booking.author),
                                  // Menggunakan fungsi _getShelfName untuk menampilkan nama rak
                                  _buildDetailRow(Icons.shelves, "Rak", _getShelfName(booking.rakBuku)),
                                  _buildDetailRow(Icons.category_outlined, "Jenis", booking.jenisBuku),
                                  _buildDetailRow(Icons.calendar_today_outlined, "Terbit", booking.tglTerbit),
                                  const SizedBox(height: 6),
                                  Divider(color: Colors.grey.shade300),
                                  const SizedBox(height: 6),
                                  _buildDetailRow(Icons.bookmark_add_outlined, "Booking", _formatDate(booking.bookingDate)),
                                  _buildDetailRow(
                                    Icons.event_busy_outlined,
                                    "Kedaluwarsa",
                                    _formatDate(booking.expiredDate),
                                    valueColor: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                                    isBold: true,
                                  ),
                                  if (isExpired)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        "BOOKING KEDALUWARSA",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: Colors.red.shade700,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    )
                                ],
                              ),
                            ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border_rounded, size: 100, color: Colors.blueGrey[200]),
            const SizedBox(height: 20),
            const Text(
              "Belum Ada Booking",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blueGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Anda belum melakukan booking buku. Silakan cari dan booking buku yang Anda inginkan!",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.blueGrey[300],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
            ),
            child: const Center(
              child: Text(
                'PerpusApp Menu',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          _buildDrawerItem(context, icon: Icons.home_outlined, title: 'Beranda', routeName: '/dashboard'),
          _buildDrawerItem(context, icon: Icons.bookmark_added_outlined, title: 'Booking Saya', isActive: true, onTapAction: () => Navigator.pop(context)),
          _buildDrawerItem(context, icon: Icons.person_outline, title: 'Profil Saya', routeName: '/profile'),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, {required IconData icon, required String title, String? routeName, bool isActive = false, VoidCallback? onTapAction}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blue.shade700 : Colors.blueGrey[600]),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.blue.shade700 : Colors.black87,
          fontSize: 15,
        ),
      ),
      tileColor: isActive ? Colors.blue.shade50 : null,
      onTap: () {
        if (onTapAction != null) {
          onTapAction();
        } else if (routeName != null) {
          Navigator.pop(context);
          Navigator.pushNamed(context, routeName, arguments: widget.accountId);
        }
      },
    );
  }
}