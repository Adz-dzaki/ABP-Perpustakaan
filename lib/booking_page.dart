import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/booking_model.dart'; // import model
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

  // Mengubah endpoint API sesuai dengan yang benar
  Future<void> fetchBookings() async {
    final url = Uri.parse("http://10.0.2.2:8080/api/booking/bookings/${widget.accountId}");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> bookingList = json.decode(response.body);

        setState(() {
          bookings = bookingList.map((b) => BookingModel.fromJson(b)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load bookings');
      }
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              CustomHeader(
                onMenuTap: () => Scaffold.of(context).openDrawer(),
                onLogoutTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Daftar Booking Aktif',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : bookings.isEmpty
                    ? const Center(child: Text("Tidak ada booking aktif"))
                    : ListView.builder(
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(booking.namaBuku),
                        subtitle: Text(
                          "Penulis: ${booking.author}\n"
                              "Rak: ${booking.rakBuku}\n"
                              "Jenis: ${booking.jenisBuku} | ${booking.tipeBuku}\n"
                              "Terbit: ${booking.tglTerbit}\n"
                              "Booking: ${booking.bookingDate.toLocal()}\n"
                              "Expired Date: ${booking.expiredDate.toLocal()}",  // Format tanggal
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Center(
              child: Text(
                'Menu',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Beranda'),
            onTap: () => Navigator.pushNamed(context, '/dashboard', arguments: widget.accountId),
          ),
          ListTile(
            leading: const Icon(Icons.book_online),
            title: const Text('Booking'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () => Navigator.pushNamed(context, '/profile', arguments: widget.accountId),
          ),
        ],
      ),
    );
  }
}
