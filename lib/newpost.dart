import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class NewPostPage extends StatefulWidget {
  const NewPostPage({super.key});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isUploading = false;

  // Fungsi untuk memilih gambar dari galeri
  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengambil gambar dari kamera
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Fungsi untuk mengupload gambar ke Firebase Storage dan menyimpan URL ke Firestore
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload gambar ke Firebase Storage
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = FirebaseStorage.instance.ref().child('posts/$fileName');
      final uploadTask = await storageRef.putFile(_selectedImage!);
      final imageUrl = await uploadTask.ref.getDownloadURL();

      // Simpan URL gambar ke Firestore
      await FirebaseFirestore.instance.collection('posts').add({
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gambar berhasil diupload')),
      );

      // Reset setelah upload
      setState(() {
        _selectedImage = null;
        _isUploading = false;
      });

      // Navigasi ke langkah berikutnya (misalnya halaman feed)
      Navigator.pop(context); // Sesuaikan sesuai kebutuhan
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'New Post',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _uploadImage,
            child: const Text(
              'Next',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Bagian Foto Utama
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => _showImagePickerOptions(context),
              child: Container(
                width: double.infinity,
                color: Colors.grey[200],
                child: _selectedImage != null
                    ? Stack(
                        children: [
                          Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                          if (_isUploading)
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      )
                    : const Icon(
                        Icons.add_a_photo,
                        color: Colors.grey,
                        size: 50,
                      ),
              ),
            ),
          ),
          // Bagian Tambahan (Placeholder GridView atau lainnya)
          const Expanded(
            flex: 3,
            child: Center(
              child: Text('Tambahkan gambar lainnya di sini'),
            ),
          ),
          // Bagian Navigasi Bawah
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.home, color: Colors.black),
                Icon(Icons.search, color: Colors.black),
                Icon(Icons.add_box, color: Colors.black),
                Icon(Icons.favorite, color: Colors.black),
                Icon(Icons.person, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Menampilkan opsi untuk memilih gambar
  void _showImagePickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFromCamera();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
