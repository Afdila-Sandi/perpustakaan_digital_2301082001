import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'detail_buku_screen.dart';
import 'peminjaman_screen.dart';
import 'pengembalian_screen.dart';
import 'buku_screen.dart';
import 'anggota_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse("http://localhost/Perpustakaan_2301082001/database/buku.php"),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final books = List<Map<String, dynamic>>.from(data['data']);
          
          for (var book in books) {
            try {
              final statusResponse = await http.get(
                Uri.parse("http://localhost/Perpustakaan_2301082001/database/peminjaman.php?id_buku=${book['id']}"),
              );
              
              print('Status response for book ${book['id']}: ${statusResponse.body}');
              
              if (statusResponse.statusCode == 200) {
                final statusData = jsonDecode(statusResponse.body);
                if (statusData['success'] && statusData['data'] != null) {
                  book['status'] = statusData['data']['status'] ?? 'tersedia';
                } else {
                  book['status'] = 'tersedia';
                }
              }
            } catch (e) {
              print('Error checking status: $e');
              book['status'] = 'tersedia';
            }
          }
          
          books.sort((a, b) {
            int idA = int.parse(a['id'].toString());
            int idB = int.parse(b['id'].toString());
            return idB.compareTo(idA);
          });
          
          setState(() {
            _books = books;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pinjamBuku(String id) async {
    try {
      print('Meminjam buku dengan ID: $id');
      
      final response = await http.post(
        Uri.parse("http://localhost/Perpustakaan_2301082001/database/peminjaman.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'pinjam',
          'id_buku': id,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['success']) {
        _getData(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dipinjam')),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _kembalikanBuku(String id) async {
    try {
      final response = await http.post(
        Uri.parse("http://localhost/Perpustakaan_2301082001/database/peminjaman.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'kembali',
          'id_buku': id,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _getData(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dikembalikan')),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Halaman Home - tidak perlu navigasi
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PeminjamanScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PengembalianScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BukuScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnggotaScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perpustakaan Digital'),
        backgroundColor: Colors.blue[700],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari buku...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _books.length,
                    itemBuilder: (context, index) {
                      final book = _books[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  book['url_gambar'] ?? '',
                                  width: 100,
                                  height: 150,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    width: 100,
                                    height: 150,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.book, size: 50),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book['judul'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Pengarang: ${book['pengarang'] ?? ''}'),
                                    Text('Penerbit: ${book['penerbit'] ?? ''}'),
                                    Text(
                                        'Tahun: ${book['tahun_terbit'] ?? ''}'),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: book['status'] == 'dipinjam'
                                            ? Colors.orange[100]
                                            : Colors.green[100],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        book['status'] == 'dipinjam'
                                            ? 'Dipinjam'
                                            : 'Tersedia',
                                        style: TextStyle(
                                          color: book['status'] == 'dipinjam'
                                              ? Colors.orange[900]
                                              : Colors.green[900],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailBukuScreen(book: book),
                                            ),
                                          ),
                                          child: const Text('Detail'),
                                        ),
                                        const SizedBox(width: 8),
                                        if (book['status'] == 'tersedia')
                                          ElevatedButton(
                                            onPressed: () =>
                                                _pinjamBuku(book['id']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green,
                                            ),
                                            child: const Text('Pinjam'),
                                          ),
                                        if (book['status'] == 'dipinjam')
                                          ElevatedButton(
                                            onPressed: () =>
                                                _kembalikanBuku(book['id']),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange,
                                            ),
                                            child: const Text('Kembalikan'),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Peminjaman',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'Pengembalian',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Buku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Anggota',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[700],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
