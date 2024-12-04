import 'package:flutter/material.dart';

class DetailBukuScreen extends StatelessWidget {
  final Map<String, dynamic> book;

  const DetailBukuScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['judul'] ?? 'Detail Buku'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book['url_gambar'] ?? '',
                  height: 300,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.book, size: 100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              book['judul'] ?? '',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Pengarang: ${book['pengarang'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Penerbit: ${book['penerbit'] ?? ''}'),
            const SizedBox(height: 8),
            Text('Tahun Terbit: ${book['tahun_terbit'] ?? ''}'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: book['status'] == 'dipinjam'
                    ? Colors.orange[100]
                    : Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                book['status'] == 'dipinjam' ? 'Dipinjam' : 'Tersedia',
                style: TextStyle(
                  color: book['status'] == 'dipinjam'
                      ? Colors.orange[900]
                      : Colors.green[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
