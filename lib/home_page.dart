import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:dashboard_perpus/profile_page.dart';
import 'package:dashboard_perpus/widgets/chatbot_page.dart';
import 'package:dashboard_perpus/widgets/custom_header.dart';
import 'package:dashboard_perpus/service/book_service.dart';
import 'package:dashboard_perpus/service/booking_service.dart';
import '../models/book_model.dart';
import '../models/booking_model.dart';
import 'booking_page.dart';


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
  // State untuk navigasi dan data
  int _selectedIndex = 0;
  late Future<List<BookModel>> futureBooks;
  late PageController _pageController;
  String searchQuery = '';

  // State untuk logika denda dan loading
  bool _hasOverdueFine = false;
  bool _isLoadingInitialData = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadInitialData(); // Memuat semua data yang diperlukan saat halaman pertama kali dibuka
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Fungsi utama untuk memuat data buku dan mengecek status pinjaman pengguna
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoadingInitialData = true);

    try {
      // Menyiapkan kedua pemanggilan API untuk dijalankan secara bersamaan
      final booksFuture = BookService.fetchBooks();
      final userBookingsFuture = BookingService().fetchBookingsByAccountId(widget.accountId);

      // Menunggu kedua proses selesai
      final results = await Future.wait([booksFuture, userBookingsFuture]);

      final List<BookModel> books = results[0] as List<BookModel>;
      final List<BookingModel> userBookings = results[1] as List<BookingModel>;

      // Logika untuk mengecek apakah ada pinjaman yang kadaluwarsa
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      final bool hasOverdue = userBookings.any((booking) {
        final expiredDateStart = DateTime(booking.expiredDate.year, booking.expiredDate.month, booking.expiredDate.day);
        return expiredDateStart.isBefore(todayStart);
      });

      if (!mounted) return;
      setState(() {
        futureBooks = Future.value(books); // Set data buku yang berhasil diambil
        _hasOverdueFine = hasOverdue; // Set status denda
        _isLoadingInitialData = false; // Matikan loading utama
      });

      // Jika terdeteksi ada denda, tampilkan pop-up peringatan
      if (hasOverdue) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showOverdueFinePopup());
      }

    } catch (e) {
      if (!mounted) return;
      print("Error loading initial data: $e");
      setState(() {
        futureBooks = Future.error("Gagal memuat data");
        _isLoadingInitialData = false;
      });
    }
  }

  // Fungsi untuk menampilkan Pop-up peringatan denda
  void _showOverdueFinePopup() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false, // User harus menekan tombol untuk menutup
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                const SizedBox(width: 10),
                const Text("Peringatan", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
              ],
            ),
            content: const Text(
              "Anda memiliki pinjaman yang telah kadaluwarsa. Fitur booking dinonaktifkan hingga pinjaman diselesaikan.",
              style: TextStyle(fontFamily: 'Poppins', fontSize: 15),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Mengerti", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold)),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                child: const Text("Lihat Booking", style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _onNavTapped(1); // Otomatis pindah ke halaman booking
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.jumpToPage(index);
  }

  // Fungsi refresh sekarang memanggil _loadInitialData agar status denda juga diperbarui
  Future<void> _refreshBooks() async => await _loadInitialData();

  // --- Sisa fungsi helper tidak ada perubahan ---
  String getRakLabel(int rakId) {
    switch (rakId) { case 1: return 'Fiksi'; case 2: return 'Non-Fiksi'; case 3: return 'Edukasi'; case 4: return 'Sains'; case 5: return 'Comic'; default: return 'Lainnya'; }
  }
  String getStatusLabel(int statusBooking) => statusBooking == 0 ? 'Tersedia' : 'Tidak Tersedia';
  String _formatTanggal(String tanggal) {
    try { return DateFormat('dd MMM yyyy', 'id_ID').format(DateTime.parse(tanggal)); } catch (e) { return tanggal; }
  }
  Future<void> _selectDate(BuildContext context, BookModel book) async {
    final DateTime? picked = await showDatePicker(
      context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 7)),
      helpText: 'Pilih Tanggal Pengambilan',
      builder: (context, child) => Theme(data: ThemeData.light().copyWith(colorScheme: ColorScheme.light(primary: Colors.blue.shade700, onPrimary: Colors.white, onSurface: Colors.black)), child: child!),
    );
    if (picked != null) _showBookingConfirmation(book, picked);
  }
  void _showBookingConfirmation(BookModel book, DateTime bookingDate) {
    final expiredDate = DateTime(bookingDate.year, bookingDate.month, bookingDate.day, 23, 59, 59);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Text("Konfirmasi Booking", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
        content: RichText(
          text: TextSpan(style: TextStyle(fontFamily: 'Poppins', fontSize: 15, color: Colors.black87), children: <TextSpan>[
            const TextSpan(text: "Anda akan melakukan booking untuk buku:\n"), TextSpan(text: "${book.namaBuku}\n", style: TextStyle(fontWeight: FontWeight.bold)), const TextSpan(text: "Tanggal pengambilan: "),
            TextSpan(text: DateFormat('dd MMM yyyy', 'id_ID').format(bookingDate), style: TextStyle(fontWeight: FontWeight.bold)), const TextSpan(text: ".\n\nBatas pengembalian buku adalah 3 hari setelah tanggal booking."),
          ]),
        ),
        actions: <Widget>[
          TextButton(child: const Text("Batal", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)), onPressed: () => Navigator.of(dialogContext).pop()),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
            child: const Text("Booking Sekarang", style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
            onPressed: () { Navigator.of(dialogContext).pop(); _bookBuku(book, expiredDate); },
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      ),
    );
  }
  Future<void> _bookBuku(BookModel book, DateTime expiredDate) async {
    final success = await BookingService().bookBook(accountId: widget.accountId, bukuId: book.bukuId, expiredDate: expiredDate);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking berhasil untuk '${book.namaBuku}'", style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.green));
      _refreshBooks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Booking gagal, buku mungkin sudah dipinjam.", style: TextStyle(fontFamily: 'Poppins')), backgroundColor: Colors.red));
    }
  }
  Widget _buildBookDetailText(String text) => Text(text, style: _textStyle(), maxLines: 1, overflow: TextOverflow.ellipsis);
  TextStyle _textStyle({bool isStatus = false}) => TextStyle(fontSize: isStatus ? 11.5 : 11, fontFamily: 'Poppins', color: Colors.black54);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      drawer: _buildDrawer(),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _selectedIndex = index),
          children: [
            // Tampilkan loading utama jika data awal sedang diambil, jika tidak, tampilkan konten
            _isLoadingInitialData
                ? Center(child: CircularProgressIndicator(color: Colors.blue.shade700))
                : _buildHomeContent(),
            BookingPage(accountId: widget.accountId),
            ProfilePage(accountId: widget.accountId),
            const ChatbotPage(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.blue.shade800, boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(.1))]),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            rippleColor: Colors.blue.shade300, hoverColor: Colors.blue.shade700, gap: 8,
            activeColor: Colors.blue.shade800, iconSize: 24,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.blue.shade100, color: Colors.white,
            tabs: const [
              GButton(icon: Icons.home_outlined, text: 'Beranda'),
              GButton(icon: Icons.collections_bookmark_outlined, text: 'Booking'),
              GButton(icon: Icons.person_outline, text: 'Profil'),
              GButton(icon: Icons.chat_bubble_outline, text: 'AI Chat'),
            ],
            selectedIndex: _selectedIndex, onTabChange: _onNavTapped,
          ),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return FutureBuilder<List<BookModel>>(
      future: futureBooks,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(color: Colors.blue.shade700));
        if (snapshot.hasError) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.error_outline, color: Colors.red.shade300, size: 50), const SizedBox(height: 10), const Text('Gagal memuat data buku.', style: TextStyle(fontFamily: 'Poppins', fontSize: 16)), const SizedBox(height: 10), ElevatedButton.icon(icon: Icon(Icons.refresh, color: Colors.white), label: Text('Coba Lagi', style: TextStyle(fontFamily: 'Poppins', color: Colors.white)), onPressed: _refreshBooks, style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700))]));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyBookList();

        final books = snapshot.data!;
        final displayedBooks = books.where((book) {
          final query = searchQuery.toLowerCase();
          return book.namaBuku.toLowerCase().contains(query) || book.author.toLowerCase().contains(query) || book.jenisBuku.toLowerCase().contains(query) || getRakLabel(book.rakbukuId).toLowerCase().contains(query);
        }).toList();

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: Builder(builder: (context) => _buildHeader(context)),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshBooks,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text('Halo, ${widget.namaUser}!', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 26, color: Colors.blue.shade800)),
                    const Text('Selamat datang di Perpustakaan Jaya Abadi', style: TextStyle(fontFamily: 'Poppins', fontSize: 18, color: Colors.black54)),
                    const SizedBox(height: 24),
                    _buildSearchField(),
                    const SizedBox(height: 24),
                    Text('Daftar Buku', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 20, color: Colors.blue.shade900)),
                    const SizedBox(height: 12),
                    displayedBooks.isEmpty ? _buildEmptyBookList() : GridView.builder(
                      physics: const NeverScrollableScrollPhysics(), shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.50),
                      itemCount: displayedBooks.length,
                      itemBuilder: (context, index) => _buildBookCard(displayedBooks[index]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBookCard(BookModel book) {
    // Tombol akan nonaktif jika buku tidak tersedia ATAU user punya denda
    bool isButtonDisabled = book.statusBooking != 0 || _hasOverdueFine;

    return Card(
      elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 180, color: Colors.blue.shade50, child: Center(child: Icon(Icons.menu_book_rounded, size: 60, color: Colors.blue.shade200))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(book.namaBuku, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0D47A1))),
                const SizedBox(height: 4),
                _buildBookDetailText('Penulis: ${book.author}'),
                _buildBookDetailText('Jenis: ${book.jenisBuku}'),
                _buildBookDetailText('Tipe: ${book.tipeBuku}'),
                _buildBookDetailText('Terbit: ${_formatTanggal(book.tanggalTerbit)}'),
                _buildBookDetailText('Rak: ${getRakLabel(book.rakbukuId)}'),
                Text('Status: ${getStatusLabel(book.statusBooking)}', style: _textStyle(isStatus: true).copyWith(color: book.statusBooking == 0 ? Colors.green.shade700 : Colors.red.shade700, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 0, 10.0, 6.0),
            child: ElevatedButton(
              onPressed: isButtonDisabled ? null : () => _selectDate(context, book),
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonDisabled ? Colors.grey.shade300 : Colors.blue.shade700,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(book.statusBooking == 0 ? 'Booking Buku' : 'Tidak Tersedia', style: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 13, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }

  // --- Sisa widget builder tidak berubah ---
  Widget _buildEmptyBookList() => Center(child: Padding(padding: const EdgeInsets.symmetric(vertical: 50.0), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.search_off_rounded, size: 80, color: Colors.grey[400]), const SizedBox(height: 16), Text(searchQuery.isEmpty ? "Belum ada buku yang tersedia" : "Buku tidak ditemukan", style: TextStyle(fontSize: 18, color: Colors.grey[600], fontFamily: 'Poppins'), textAlign: TextAlign.center), if (searchQuery.isNotEmpty) Text("Coba kata kunci lain.", style: TextStyle(fontSize: 14, color: Colors.grey[500], fontFamily: 'Poppins'), textAlign: TextAlign.center)])));
  Widget _buildHeader(BuildContext context) => CustomHeader(onMenuTap: () => Scaffold.of(context).openDrawer(), onLogoutTap: () => showDialog(context: context, builder: (BuildContext dialogContext) => AlertDialog(title: Text("Konfirmasi Logout", style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.blue.shade800)), content: Text("Apakah Anda yakin ingin keluar?", style: TextStyle(fontFamily: 'Poppins')), actions: <Widget>[TextButton(child: Text("Batal", style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)), onPressed: () => Navigator.of(dialogContext).pop()), ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600), child: Text("Logout", style: TextStyle(fontFamily: 'Poppins', color: Colors.white)), onPressed: () { Navigator.of(dialogContext).pop(); Navigator.of(this.context).pushNamedAndRemoveUntil('/login', (route) => false); })])));
  Widget _buildSearchField() => TextField(decoration: InputDecoration(hintText: 'Cari buku...', hintStyle: TextStyle(fontFamily: 'Poppins', color: Colors.grey.shade600, fontSize: 15), prefixIcon: Icon(Icons.search, color: Colors.blue.shade700), filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0), border: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide(color: Colors.blue.shade200, width: 1.5)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30.0), borderSide: BorderSide(color: Colors.blue.shade700, width: 2.0))), style: TextStyle(fontFamily: 'Poppins', fontSize: 15), onChanged: (value) => setState(() => searchQuery = value.toLowerCase()));
  Widget _buildDrawer() => Drawer(child: ListView(padding: EdgeInsets.zero, children: [DrawerHeader(decoration: BoxDecoration(color: Colors.blue.shade700), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.menu_book_rounded, color: Colors.white, size: 40), const SizedBox(height: 8), Text('Menu Navigasi', style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)), const SizedBox(height: 4), Text(widget.namaUser, style: TextStyle(fontFamily: 'Poppins', color: Colors.white70, fontSize: 14))]))), _drawerItem(Icons.home_outlined, 'Beranda', 0), _drawerItem(Icons.collections_bookmark_outlined, 'Booking Saya', 1), _drawerItem(Icons.person_outline, 'Profil Saya', 2), const Divider(), _drawerItem(Icons.support_agent, 'Pustakawan AI', 3)]));
  Widget _drawerItem(IconData icon, String title, int index) { final bool isSelected = _selectedIndex == index; return ListTile(leading: Icon(icon, color: isSelected ? Colors.blue.shade700 : Colors.blueGrey[600]), title: Text(title, style: TextStyle(fontFamily: 'Poppins', fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.blue.shade700 : Colors.black87, fontSize: 15)), tileColor: isSelected ? Colors.blue.shade50 : null, onTap: () { Navigator.pop(context); _onNavTapped(index); }); }
}