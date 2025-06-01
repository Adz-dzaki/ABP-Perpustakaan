import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard_perpus/widgets/custom_header.dart'; // Impor CustomHeader

class ProfilePage extends StatefulWidget {
  final int accountId;

  ProfilePage({required this.accountId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditMode = false;
  bool isLoading = true;

  final _namaDepanController = TextEditingController();
  final _namaBelakangController = TextEditingController();
  final _emailController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/profile/${widget.accountId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _namaDepanController.text = data['nama_depan'];
          _namaBelakangController.text = data['nama_belakang'];
          _emailController.text = data['email'];
          _tanggalLahirController.text = data['tanggal_lahir'];
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat profil');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateProfile() async {
    try {
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/api/profile/${widget.accountId}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_depan': _namaDepanController.text,
          'nama_belakang': _namaBelakangController.text,
          'email': _emailController.text,
          'tanggal_lahir': _tanggalLahirController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Profil berhasil diperbarui')),
        );
        setState(() => isEditMode = false);
      } else {
        throw Exception('Gagal memperbarui profil');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    bool enabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          border: OutlineInputBorder(),
        ),
        style: TextStyle(
          color: enabled ? Colors.black : Colors.grey,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _namaDepanController.dispose();
    _namaBelakangController.dispose();
    _emailController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              onMenuTap: () => Scaffold.of(context).openDrawer(),
              onLogoutTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    buildTextField(
                      label: 'Nama Depan',
                      controller: _namaDepanController,
                      enabled: isEditMode,
                    ),
                    buildTextField(
                      label: 'Nama Belakang',
                      controller: _namaBelakangController,
                      enabled: isEditMode,
                    ),
                    buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      enabled: isEditMode,
                    ),
                    buildTextField(
                      label: 'Tanggal Lahir (YYYY-MM-DD)',
                      controller: _tanggalLahirController,
                      enabled: isEditMode,
                    ),
                    SizedBox(height: 20), // Menambahkan jarak sebelum tombol
                    // Tombol Edit atau Simpan
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          if (isEditMode) {
                            updateProfile(); // Perbarui profil saat mode edit
                          } else {
                            setState(() => isEditMode = true); // Masuk ke mode edit
                          }
                        },
                        child: Text(
                          isEditMode ? 'Simpan' : 'Edit Profil',
                          style: TextStyle(color: isEditMode ? Colors.black : Colors.black), // Warna teks
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // Latar belakang putih
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 16),
                          elevation: 5, // Menambahkan efek shadow
                          shadowColor: Colors.grey.withOpacity(0.5), // Warna shadow
                          side: BorderSide(color: Colors.white), // Border biru jika diinginkan
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
