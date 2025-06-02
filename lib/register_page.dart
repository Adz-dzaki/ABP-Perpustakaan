import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'login_page.dart';

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
  bool isLoading = false;
  bool _obscurePassword = true;

  Future<void> registerUser() async {
    setState(() => isLoading = true);

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
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FadeInUp(duration: Duration(milliseconds: 1000), child: Text("Daftar", style: TextStyle(color: Colors.white, fontSize: 40))),
                  SizedBox(height: 10),
                  FadeInUp(duration: Duration(milliseconds: 1300), child: Text("Daftar akun dengan Email", style: TextStyle(color: Colors.white, fontSize: 18))),
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
                            SizedBox(height: 30),
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
                                    // Email
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

                                    // Password
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
                                            border: InputBorder.none,
                                            suffixIcon: IconButton( // Tambahkan IconButton
                                              icon: Icon(
                                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                            },
                                          )
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Password tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    // Konfirmasi Password
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                        controller: confirmPasswordController,
                                        obscureText: true,
                                        decoration: InputDecoration(
                                            hintText: "Konfirmasi Password",
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: InputBorder.none,
                                            suffixIcon: IconButton( // Tambahkan IconButton
                                              icon: Icon(
                                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                                color: Colors.grey,
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  _obscurePassword = !_obscurePassword;
                                                });
                                              },
                                            )
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Konfirmasi Password tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 20),

                            FadeInUp(
                              duration: Duration(milliseconds: 1500),
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
                                    // Nama Depan
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                        controller: firstNameController,
                                        decoration: InputDecoration(
                                            hintText: "Nama Depan",
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: InputBorder.none
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Nama Depan tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    // Nama Belakang
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          border: Border(bottom: BorderSide(color: Colors.grey.shade200))
                                      ),
                                      child: TextFormField(
                                        controller: lastNameController,
                                        decoration: InputDecoration(
                                            hintText: "Nama Belakang",
                                            hintStyle: TextStyle(color: Colors.grey),
                                            border: InputBorder.none
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Nama Belakang tidak boleh kosong';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    // Tanggal Lahir
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: TextFormField(
                                        readOnly: true,
                                        decoration: InputDecoration(
                                          hintText: "Tanggal Lahir",
                                          hintStyle: TextStyle(color: Colors.grey),
                                          border: InputBorder.none,
                                          suffixIcon: Icon(Icons.calendar_today, color: Colors.blue[900]),
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
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 40),

                            FadeInUp(
                              duration: Duration(milliseconds: 1600),
                              child: MaterialButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
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
                                height: 50,
                                minWidth: double.infinity,
                                color: Colors.blue[900],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: isLoading
                                    ? CircularProgressIndicator(color: Colors.white)
                                    : Text("Daftar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ),
                            ),

                            SizedBox(height: 20),

                            FadeInUp(
                              duration: Duration(milliseconds: 1700),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Sudah memiliki akun? ", style: TextStyle(color: Colors.grey)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => LoginPage()),
                                      );
                                    },
                                    child: Text("Masuk", style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 50),
                          ],
                        ),
                      ),
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