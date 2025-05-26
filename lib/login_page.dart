import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'home_page.dart';
import 'register_page.dart';

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
        final data = json.decode(response.body);

        final role = data['role'];
        if (role == 'admin') {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Akses Ditolak"),
              content: Text("Akun admin hanya bisa login melalui website."),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("OK"),
                ),
              ],
            ),
          );
          return;
        }

        final firstName = data['firstName'];
        final fullName = data['name'];
        final token = data['token'];
        final accountId = data['accountId'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('firstName', firstName);
        await prefs.setString('fullName', fullName);
        await prefs.setString('email', data['email']);
        await prefs.setInt('accountId', accountId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'])),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              namaUser: firstName,
              accountId: accountId,
            ),
          ),
        );
      } else {
        final error = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: ${error['message'] ?? 'Terjadi kesalahan'}')),
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
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                colors: [
                  Colors.blue.shade900,
                  Colors.blue.shade800,
                  Colors.blue.shade400
                ]
            )
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 80),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(duration: Duration(milliseconds: 1000), child: Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 40))),
                  SizedBox(height: 10),
                  FadeInUp(duration: Duration(milliseconds: 1300), child: Text("Selamat datang kembali di Perpustakaan Jaya Abadi!", style: TextStyle(color: Colors.white, fontSize: 18))),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FadeInUp(
                duration: Duration(milliseconds: 1350),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 60),
                            FadeInUp(
                                duration: Duration(milliseconds: 1400),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [BoxShadow(
                                          color: Color.fromRGBO(13, 71, 161, 0.3),
                                          blurRadius: 20,
                                          offset: Offset(0, 10)
                                      )]
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                        ),
                                        child: TextFormField(
                                          controller: emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                              hintText: "Email",
                                              hintStyle: TextStyle(color: Colors.grey),
                                              border: InputBorder.none
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Email tidak boleh kosong';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                        ),
                                        child: TextFormField(
                                          controller: passwordController,
                                          obscureText: true,
                                          decoration: InputDecoration(
                                              hintText: "Password",
                                              hintStyle: TextStyle(color: Colors.grey),
                                              border: InputBorder.none
                                          ),
                                          validator: (value) {
                                            if (value == null || value.isEmpty) {
                                              return 'Password tidak boleh kosong';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                            ),
                            SizedBox(height: 40),
                            FadeInUp(duration: Duration(milliseconds: 1500), child: Text("Lupa Password?", style: TextStyle(color: Colors.grey))),
                            SizedBox(height: 40),
                            FadeInUp(
                                duration: Duration(milliseconds: 1600),
                                child: MaterialButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                    if (_formKey.currentState!.validate()) {
                                      loginUser();
                                    }
                                  },
                                  height: 50,
                                  minWidth: double.infinity,
                                  color: Colors.blue[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: isLoading
                                      ? CircularProgressIndicator(color: Colors.white)
                                      : Text("Masuk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                )
                            ),
                            SizedBox(height: 40),
                            FadeInUp(
                              duration: Duration(milliseconds: 1700),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Belum memiliki akun? ", style: TextStyle(color: Colors.grey)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => RegisterPage()),
                                      );
                                    },
                                    child: Text("Daftar", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
