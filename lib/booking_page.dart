import 'package:flutter/material.dart';
import 'package:dashboard_perpus/widgets/custom_header.dart';

class BookingPage extends StatelessWidget {
  final int accountId;

  const BookingPage({super.key, required this.accountId});

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
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login', (route) => false);
                },
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Halaman Booking',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const Center(child: Text('Under Construction')),
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
            onTap: () {
              Navigator.pop(context);
              // Navigasi ke Home
            },
          ),
          ListTile(
            leading: const Icon(Icons.book_online),
            title: const Text('Booking'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              // Navigasi ke Profil
            },
          ),
        ],
      ),
    );
  }
}
