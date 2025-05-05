import 'package:dashboard_perpus/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:dashboard_perpus/service/book_service.dart';
import '../models/book_model.dart';

class HomePage extends StatefulWidget {
  final String namaUser;
  final int accountId; // ✅ DITAMBAH

  const HomePage({
    super.key,
    required this.namaUser,
    required this.accountId, // ✅ DITAMBAH
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late Future<List<BookModel>> futureBooks;
  late PageController _pageController;

  String searchQuery = '';

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
      default: return 'Unknown';
    }
  }

  String getStatusLabel(int statusBooking) =>
      statusBooking == 0 ? 'Tersedia' : 'Tidak Tersedia';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
            Center(child: Text('Booking Page')), // Placeholder
            ProfilePage(accountId: widget.accountId), // ✅ PERBAIKI INI
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
          child: GNav(
            gap: 8,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.lightBlueAccent,
            padding: const EdgeInsets.all(12),
            selectedIndex: _selectedIndex,
            onTabChange: _onNavTapped,
            tabs: const [
              GButton(icon: Icons.home, text: 'Beranda'),
              GButton(icon: Icons.book_online, text: 'Booking'),
              GButton(icon: Icons.person, text: 'Profil'),
            ],
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Gagal memuat data buku'));
        }

        final books = snapshot.data!;
        final displayedBooks = books.where((book) {
          final query = searchQuery.toLowerCase();
          return book.namaBuku.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query) ||
              book.jenisBuku.toLowerCase().contains(query);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Text(
                'Selamat datang ${widget.namaUser}!',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const Text(
                'di Perpustakaan Jaya Abadi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              _buildSearchField(),
              const SizedBox(height: 20),
              const Text(
                'Daftar Buku',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.62,
                ),
                itemCount: displayedBooks.length,
                itemBuilder: (context, index) =>
                    _buildBookCard(displayedBooks[index]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (Route<dynamic> route) => false);
          },
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Cari buku',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildBookCard(BookModel book) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Icon(Icons.menu_book, size: 64, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            book.namaBuku,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text('Penulis: ${book.author}', style: _textStyle()),
          Text('Jenis: ${book.jenisBuku}', style: _textStyle()),
          Text('Tipe: ${book.tipeBuku}', style: _textStyle()),
          Text('Terbit: ${book.tanggalTerbit}', style: _textStyle()),
          Text('Rak: ${getRakLabel(book.rakbukuId)}', style: _textStyle()),
          Text(
            'Status: ${getStatusLabel(book.statusBooking)}',
            style: _textStyle().copyWith(
              color: book.statusBooking == 0 ? Colors.green : Colors.red,
            ),
          ),
          const Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: book.statusBooking == 0
                  ? () => print('Booking ${book.namaBuku}')
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                book.statusBooking == 0 ? Colors.blue : Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                book.statusBooking == 0 ? 'Booking' : 'Tidak Tersedia',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  TextStyle _textStyle() {
    return const TextStyle(fontSize: 12, fontFamily: 'Poppins');
  }

  Widget _buildDrawer() {
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
          _drawerItem(Icons.home, 'Beranda', 0),
          _drawerItem(Icons.book_online, 'Booking', 1),
          _drawerItem(Icons.person, 'Profil', 2),
        ],
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(
        title,
        style:
        const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
      ),
      onTap: () {
        Navigator.pop(context);
        _onNavTapped(index);
      },
    );
  }
}
