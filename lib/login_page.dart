import 'package:dashboard_perpus/register_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart'; // untuk navigasi ke register

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Sukses login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        // Gagal login
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: ${error['message'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

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
                    'Masuk ke Akun',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(emailController, 'Email', TextInputType.emailAddress),
                  _buildTextField(passwordController, 'Password', TextInputType.visiblePassword, obscure: true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        loginUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Masuk'),
                  ),
                  const SizedBox(height: 10),
                  const Text('Belum punya akun?'),
                  const SizedBox(height: 5),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => RegisterPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size.fromHeight(45),
                    ),
                    child: const Text('Daftar'),
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
}
