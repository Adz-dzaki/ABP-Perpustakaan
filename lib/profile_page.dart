import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dashboard_perpus/widgets/custom_header.dart'; // Pastikan path ini benar
// import 'package:intl/intl.dart'; // Jika menggunakan intl

class ProfilePage extends StatefulWidget {
  final int accountId;

  const ProfilePage({super.key, required this.accountId}); // Tambahkan super.key

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditMode = false;
  bool isLoading = true;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

  final _namaDepanController = TextEditingController();
  final _namaBelakangController = TextEditingController();
  final _emailController = TextEditingController();
  final _tanggalLahirController = TextEditingController();

  Map<String, String> _initialData = {};

  @override
  void initState() {
    super.initState();
    fetchProfileData();
  }

  Future<void> fetchProfileData() async {
    // ... (fungsi fetchProfileData tetap sama)
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/profile/${widget.accountId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _namaDepanController.text = data['nama_depan'] ?? '';
        _namaBelakangController.text = data['nama_belakang'] ?? '';
        _emailController.text = data['email'] ?? '';
        _tanggalLahirController.text = data['tanggal_lahir'] ?? '';

        _initialData = {
          'nama_depan': _namaDepanController.text,
          'nama_belakang': _namaBelakangController.text,
          'email': _emailController.text,
          'tanggal_lahir': _tanggalLahirController.text,
        };

        setState(() => isLoading = false);
      } else {
        throw Exception('Gagal memuat profil (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memuat profil: ${e.toString()}')),
      );
    }
  }

  void _revertChanges() {
    // ... (fungsi _revertChanges tetap sama)
    _namaDepanController.text = _initialData['nama_depan'] ?? '';
    _namaBelakangController.text = _initialData['nama_belakang'] ?? '';
    _emailController.text = _initialData['email'] ?? '';
    _tanggalLahirController.text = _initialData['tanggal_lahir'] ?? '';
    setState(() => isEditMode = false);
  }

  Future<void> updateProfile() async {
    // ... (fungsi updateProfile tetap sama)
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isSaving = true);

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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Profil berhasil diperbarui'), backgroundColor: Colors.green),
        );
        _initialData = {
          'nama_depan': _namaDepanController.text,
          'nama_belakang': _namaBelakangController.text,
          'email': _emailController.text,
          'tanggal_lahir': _tanggalLahirController.text,
        };
        setState(() => isEditMode = false);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal memperbarui profil (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error memperbarui profil: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // ... (fungsi _selectDate tetap sama)
    DateTime? initialDate;
    try {
      if (_tanggalLahirController.text.isNotEmpty) {
        initialDate = DateTime.parse(_tanggalLahirController.text);
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade700,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate = "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      setState(() {
        _tanggalLahirController.text = formattedDate;
      });
    }
  }

  Widget buildTextField({
    // ... (fungsi buildTextField tetap sama)
    required String label,
    required TextEditingController controller,
    bool enabled = false,
    TextInputType keyboardType = TextInputType.text,
    IconData? prefixIcon,
    bool isDateField = false,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: isDateField ? TextInputType.none : keyboardType,
        readOnly: isDateField,
        onTap: (isDateField && enabled) ? () => _selectDate(context) : null,
        decoration: InputDecoration(
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blue.shade700) : null,
          labelText: label,
          hintText: isDateField ? 'YYYY-MM-DD' : null,
          labelStyle: TextStyle(color: Colors.black54, fontSize: 16),
          filled: true,
          fillColor: enabled ? Colors.grey[50] : Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red.shade700, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2.0),
          ),
        ),
        style: TextStyle(color: Colors.black87, fontSize: 16),
        validator: validator,
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
      backgroundColor: Colors.grey[100],
      // Drawer tidak didefinisikan di sini, akan menggunakan drawer dari HomePage jika ProfilePage
      // adalah bagian dari PageView di HomePage dan CustomHeader memanggil Scaffold.of(context).openDrawer()
      body: SafeArea(
        child: Column(
          children: [
            // --- PERUBAHAN BAGIAN HEADER DIMULAI DI SINI ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0), // Sama seperti BookingPage
              child: CustomHeader(
                onMenuTap: () {
                  // Jika ProfilePage ditampilkan dalam PageView dari HomePage yang memiliki drawer:
                  Scaffold.of(context).openDrawer();
                },
                onLogoutTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) { // Ganti nama context
                      return AlertDialog(
                        title: Text("Konfirmasi Logout", style: TextStyle(fontFamily: 'Poppins')),
                        content: Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontFamily: 'Poppins')),
                        actions: <Widget>[
                          TextButton(
                            child: Text("Batal", style: TextStyle(color: Colors.grey, fontFamily: 'Poppins')),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                          ),
                          TextButton(
                            child: Text("Logout", style: TextStyle(color: Colors.red, fontFamily: 'Poppins')),
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
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
            const SizedBox(height: 20), // Sama seperti BookingPage
            Text( // Judul halaman disesuaikan gayanya
              'Profil Saya',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 22, // Sama seperti BookingPage
                color: Color(0xFF0D47A1), // Warna biru gelap (Colors.blue.shade900)
              ),
            ),
            // --- PERUBAHAN BAGIAN HEADER SELESAI ---
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
                  : RefreshIndicator(
                onRefresh: fetchProfileData,
                color: Colors.blue.shade700,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0), // Padding atas disesuaikan
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.blue.shade100,
                          child: Icon(Icons.person_outline, size: 70, color: Colors.blue.shade700),
                        ),
                        SizedBox(height: 25),
                        Card(
                          // ... (isi Card tetap sama)
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                buildTextField(
                                  label: 'Nama Depan',
                                  controller: _namaDepanController,
                                  enabled: isEditMode,
                                  prefixIcon: Icons.person_outline,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nama depan tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                buildTextField(
                                  label: 'Nama Belakang',
                                  controller: _namaBelakangController,
                                  enabled: isEditMode,
                                  prefixIcon: Icons.person_outline,
                                ),
                                buildTextField(
                                  label: 'Email',
                                  controller: _emailController,
                                  enabled: isEditMode,
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Email tidak boleh kosong';
                                    }
                                    if (!value.contains('@') || !value.contains('.')) {
                                      return 'Format email tidak valid';
                                    }
                                    return null;
                                  },
                                ),
                                buildTextField(
                                  label: 'Tanggal Lahir',
                                  controller: _tanggalLahirController,
                                  enabled: isEditMode,
                                  prefixIcon: Icons.calendar_today_outlined,
                                  isDateField: true,
                                  validator: (value) {
                                    if (isEditMode && (value == null || value.isEmpty)) {
                                      return 'Tanggal lahir tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        if (_isSaving)
                          CircularProgressIndicator(color: Colors.blue.shade700)
                        else if (isEditMode)
                        // ... (Tombol Simpan dan Batal tetap sama)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                icon: Icon(Icons.cancel_outlined),
                                label: Text('Batal'),
                                onPressed: _revertChanges,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.red.shade700, backgroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                                  textStyle: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                                  elevation: 2,
                                  side: BorderSide(color: Colors.red.shade700),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                              ElevatedButton.icon(
                                icon: Icon(Icons.save_alt_outlined, color: Colors.white),
                                label: Text('Simpan', style: TextStyle(color: Colors.white, fontFamily: 'Poppins')),
                                onPressed: updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                            ],
                          )
                        else
                        // ... (Tombol Edit Profil tetap sama)
                          ElevatedButton.icon(
                            icon: Icon(Icons.edit_outlined, color: Colors.blue.shade700),
                            label: Text('Edit Profil', style: TextStyle(color: Colors.blue.shade700, fontFamily: 'Poppins')),
                            onPressed: () => setState(() => isEditMode = true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Poppins'),
                              elevation: 3,
                              side: BorderSide(color: Colors.blue.shade700, width: 1.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}