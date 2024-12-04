import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TambahBukuScreen extends StatefulWidget {
  const TambahBukuScreen({Key? key}) : super(key: key);

  @override
  State<TambahBukuScreen> createState() => _TambahBukuScreenState();
}

class _TambahBukuScreenState extends State<TambahBukuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _judulController = TextEditingController();
  final TextEditingController _pengarangController = TextEditingController();
  final TextEditingController _penerbitController = TextEditingController();
  final TextEditingController _tahunTerbitController = TextEditingController();
  final TextEditingController _urlGambarController = TextEditingController();
  bool _isLoading = false;

  Future<void> _tambahBuku() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse("http://localhost/Perpustakaan_2301082001/database/buku.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'tambah',
          'judul': _judulController.text,
          'pengarang': _pengarangController.text,
          'penerbit': _penerbitController.text,
          'tahun_terbit': _tahunTerbitController.text,
          'url_gambar': _urlGambarController.text,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Buku berhasil ditambahkan')),
          );
          Navigator.pop(context);
        }
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan buku: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Buku'),
        backgroundColor: Colors.blue[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul Buku',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Judul buku tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pengarangController,
                decoration: const InputDecoration(
                  labelText: 'Pengarang',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Pengarang tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _penerbitController,
                decoration: const InputDecoration(
                  labelText: 'Penerbit',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Penerbit tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tahunTerbitController,
                decoration: const InputDecoration(
                  labelText: 'Tahun Terbit',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tahun terbit tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Tahun terbit harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlGambarController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar (Opsional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _tambahBuku,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Tambah Buku'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _pengarangController.dispose();
    _penerbitController.dispose();
    _tahunTerbitController.dispose();
    _urlGambarController.dispose();
    super.dispose();
  }
}