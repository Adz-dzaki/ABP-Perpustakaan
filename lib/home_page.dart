import 'package:dashboard_perpus/profile_page.dart';
import 'package:dashboard_perpus/widgets/custom_header.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dashboard_perpus/service/book_service.dart';
import '../models/book_model.dart'; // Pastikan path ini benar
import 'booking_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  final String namaUser;
  final int accountId;

  const HomePage({
    super.key,
    required this.namaUser,
    required this.accountId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<BookModel>> futureBooks;
  late PageController _pageController;

  String searchQuery = '';
  // DateTime? _selectedDate; // Tampaknya tidak digunakan secara global, hanya lokal di _selectDate

  @override
  void initState() {
    super.initState();
    futureBooks = BookService.fetchBooks();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  String getRakLabel(int rakId) {
    switch (rakId) {
      case 1: return 'Fiksi';
      case 2: return 'Non-Fiksi';
      case 3: return 'Referensi';
      case 4: return 'Science';
      case 5: return 'Comic';
      default: return 'Lainnya';
    }
  }

  String getStatusLabel(int statusBooking) =>
      statusBooking == 0 ? 'Tersedia' : 'Tidak Tersedia';

  String _formatTanggal(String tanggal) {
    try {
      DateTime parsedDate = DateTime.parse(tanggal);
      return DateFormat('dd MMM yyyy', 'id_ID').format(parsedDate);
    } catch (e) {
      return tanggal;
    }
  }

  Future<void> _selectDate(BuildContext context, BookModel book) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      helpText: 'Pilih Tanggal Pengambilan',
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
      _showBookingConfirmation(book, picked);
    }
  }

  void _showBookingConfirmation(BookModel book, DateTime bookingDate) {
    final expiredDate = DateTime(bookingDate.year, bookingDate.month, bookingDate.day, 23, 59, 59);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text("Konfirmasi Booking", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
          content: RichText(
            text: TextSpan(
              style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: Colors.black87),
              children: <TextSpan>[
                TextSpan(text: "Anda akan melakukan booking untuk buku:\n"),
                TextSpan(text: "${book.namaBuku}\n", style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: "Tanggal pengambilan: "),
                TextSpan(text: DateFormat('dd MMM yyyy', 'id_ID').format(bookingDate), style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: ".\n\nBatas pengambilan buku adalah pada hari yang sama sebelum perpustakaan tutup."),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Batal", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
              child: const Text("Booking Sekarang", style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _bookBuku(book, expiredDate);
              },
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        );
      },
    );
  }

  Future<void> _bookBuku(BookModel book, DateTime expiredDate) async {
    final url = Uri.parse("http://10.0.2.2:8080/api/booking");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'bukuId': book.bukuId,
        'accountId': widget.accountId,
        'expiredDate': expiredDate.toIso8601String(),
      }),
    );

    if (!mounted) return;

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking berhasil untuk '${book.namaBuku}'", style: TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.green,
        ),
      );
      _refreshBooks();
    } else {
      final errorData = json.decode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking gagal: ${errorData['message'] ?? 'Terjadi kesalahan'}", style: TextStyle(fontFamily: 'Poppins')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshBooks() async {
    setState(() {
      futureBooks = BookService.fetchBooks();
    });
  }

  // --- METODE HELPER DIPINDAHKAN KE SINI (LEVEL KELAS) ---
  Widget _buildBookDetailText(String text) {
    return Text(
      text,
      style: _textStyle(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  TextStyle _textStyle({bool isStatus = false}) => TextStyle(
    fontSize: isStatus ? 11.5 : 11,
    fontFamily: 'Poppins',
    color: Colors.black54,
  );
  // --- AKHIR PEMINDAHAN METODE HELPER ---


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: [
            _buildHomeContent(),
            BookingPage(accountId: widget.accountId),
            ProfilePage(accountId: widget.accountId),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          boxShadow: [
            BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.blue.shade300,
            hoverColor: Colors.blue.shade700,
            gap: 8,
            activeColor: Colors.blue.shade800,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.blue.shade100,
            color: Colors.white,
            tabs: const [
              GButton(icon: Icons.home_outlined, text: 'Beranda'),
              GButton(icon: Icons.collections_bookmark_outlined, text: 'Booking'),
              GButton(icon: Icons.person_outline, text: 'Profil'),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: _onNavTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return FutureBuilder<List<BookModel>>(
      future: futureBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator(color: Colors.blue.shade700));
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade300, size: 50),
                const SizedBox(height: 10),
                const Text('Gagal memuat data buku.', style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text('Coba Lagi', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                  onPressed: _refreshBooks,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                )
              ],
            ),
          );
        }

        final books = snapshot.data!;
        final displayedBooks = books.where((book) {
          final query = searchQuery.toLowerCase();
          final rakLabel = getRakLabel(book.rakbukuId).toLowerCase();
          return book.namaBuku.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.jenisBuku.toLowerCase().contains(query) ||
              rakLabel.contains(query);
        }).toList();

        return Column( // Untuk header sticky
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Builder(builder: (context) => _buildHeader(context)),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshBooks,
                color: Colors.blue.shade700,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text('Halo, ${widget.namaUser}!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 26, color: Colors.blue.shade800)),
                      const Text('Selamat datang di Perpustakaan Jaya Abadi', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Colors.black54)),
                      const SizedBox(height: 24),
                      _buildSearchField(),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Daftar Buku', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade900)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      displayedBooks.isEmpty
                          ? _buildEmptyBookList()
                          : GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.50, // Disesuaikan, mungkin perlu di-tweak lagi
                        ),
                        itemCount: displayedBooks.length,
                        itemBuilder: (context, index) => _buildBookCard(displayedBooks[index]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyBookList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty ? "Belum ada buku yang tersedia" : "Buku tidak ditemukan",
              style: TextStyle(fontSize: 18, color: Colors.grey[600], fontFamily: 'Poppins'),
              textAlign: TextAlign.center,
            ),
            if (searchQuery.isNotEmpty)
              Text(
                "Coba kata kunci lain.",
                style: TextStyle(fontSize: 14, color: Colors.grey[500], fontFamily: 'Poppins'),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 180,
            color: Colors.blue.shade50,
            child: Center(child: Icon(Icons.menu_book_rounded, size: 60, color: Colors.blue.shade200)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  book.namaBuku,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D47A1)),
                ),
                const SizedBox(height: 4),
                _buildBookDetailText('Penulis: ${book.author}'), // Memanggil metode kelas
                _buildBookDetailText('Jenis: ${book.jenisBuku}'), // Memanggil metode kelas
                _buildBookDetailText('Tipe: ${book.tipeBuku}'),   // Memanggil metode kelas
                _buildBookDetailText('Terbit: ${_formatTanggal(book.tanggalTerbit)}'), // Memanggil metode kelas
                _buildBookDetailText('Rak: ${getRakLabel(book.rakbukuId)}'), // Memanggil metode kelas
                Text(
                  'Status: ${getStatusLabel(book.statusBooking)}',
                  style: _textStyle(isStatus: true).copyWith( // Memanggil metode kelas
                      color: book.statusBooking == 0 ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w600
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 6.0),
            child: ElevatedButton(
              onPressed: book.statusBooking == 0 ? () => _selectDate(context, book) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: book.statusBooking == 0 ? Colors.blue.shade700 : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(
                book.statusBooking == 0 ? 'Booking Buku' : 'Tidak Tersedia',
                style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) => CustomHeader(
    onMenuTap: () => Scaffold.of(context).openDrawer(),
    onLogoutTap: () {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text("Konfirmasi Logout", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
            content: Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontFamily: 'Poppins')),
            actions: <Widget>[
              TextButton(
                child: Text("Batal", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
                child: Text("Logout", style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(this.context).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          );
        },
      );
    },
  );

  Widget _buildSearchField() => TextField(
    decoration: InputDecoration(
      hintText: 'Cari buku, penulis, jenis, atau rak...',
      hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade600, fontSize: 15),
      prefixIcon: Icon(Icons.search, color: Colors.blue.shade700),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30.0),
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0),
      ),
    ),
    style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
    onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
  );

  Widget _buildDrawer() => Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.blue.shade700),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text('Menu Navigasi', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                SizedBox(height: 4),
                Text(widget.namaUser, style: TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
        ),
        _drawerItem(Icons.home_outlined, 'Beranda', 0),
        _drawerItem(Icons.collections_bookmark_outlined, 'Booking Saya', 1),
        _drawerItem(Icons.person_outline, 'Profil Saya', 2),
      ],
    ),
  );

  Widget _drawerItem(IconData icon, String title, int index) {
    final bool isSelected = _selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? Colors.blue.shade700 : Colors.blueGrey[600]),
      title: Text(
        title,
        style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.blue.shade700 : Colors.black87,
            fontSize: 15),
      ),
      tileColor: isSelected ? Colors.blue.shade50 : null,
      onTap: () {
        Navigator.pop(context);
        _onNavTapped(index);
      },
    );
  }
}