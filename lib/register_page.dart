import 'package:dashboard_perpus/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FDFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.grey.shade200, blurRadius: 10)
              ],
            ),
            width: 400,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Formulir Registrasi',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),

                  _buildTextField(emailController, 'Email', TextInputType.emailAddress),
                  _buildTextField(passwordController, 'Password', TextInputType.visiblePassword, obscure: true),
                  _buildTextField(confirmPasswordController, 'Konfirmasi Password', TextInputType.visiblePassword, obscure: true),
                  _buildTextField(firstNameController, 'Nama Depan', TextInputType.name),
                  _buildTextField(lastNameController, 'Nama Belakang', TextInputType.name),

                  const SizedBox(height: 10),
                  _buildDatePicker(context),
                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (passwordController.text != confirmPasswordController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password dan konfirmasi tidak cocok')),
                          );
                          return;
                        }
                        if (selectedDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tanggal lahir harus diisi')),
                          );
                          return;
                        }
                        registerUser();
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: const Text('Daftar'),
                  ),

                  const SizedBox(height: 10),
                  const Text('Sudah mempunyai akun?'),
                  const SizedBox(height: 5),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: const Text('Masuk'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, TextInputType inputType, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: const InputDecoration(
        labelText: 'Tanggal Lahir',
        border: OutlineInputBorder(),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime(2000),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
        );
        if (pickedDate != null) {
          setState(() {
            selectedDate = pickedDate;
          });
        }
      },
      controller: TextEditingController(
        text: selectedDate == null
            ? ''
            : '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}',
      ),
    );
  }

  Future<void> registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final namaDepan = firstNameController.text.trim();
    final namaBelakang = lastNameController.text.trim();
    final tanggalLahir = "${selectedDate!.year.toString().padLeft(4, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nama_depan': namaDepan,
          'nama_belakang': namaBelakang,
          'tanggal_lahir': tanggalLahir,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil, silakan login')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal daftar: ${data['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

}
