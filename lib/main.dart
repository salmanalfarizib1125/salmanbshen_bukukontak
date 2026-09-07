import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const BukuKontakApp());
}

class BukuKontakApp extends StatelessWidget {
  const BukuKontakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Buku Kontak',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const BerandaPage(),
    );
  }
}

// Model data kontak (Tugas 4)
class Kontak {
  final String nama;
  final String email;
  final String noHp;
  final String? kategori;
  bool isFavorit;

  Kontak({
    required this.nama,
    required this.email,
    required this.noHp,
    this.kategori,
    this.isFavorit = false,
  });
}

// Global list kontak
List<Kontak> globalDaftarKontak = [];

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // TUGAS 6: Controller & StreamController untuk Pencarian
  late StreamController<String> _searchController;
  final TextEditingController _searchQueryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Menggunakan broadcast stream agar bisa didengar oleh StreamBuilder
    _searchController = StreamController<String>.broadcast();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchQueryController.dispose();
    _searchController.close(); // TUGAS 6: Wajib menutup stream controller agar tidak memory leak[cite: 1]
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Kontak> daftarFavorit = globalDaftarKontak.where((k) => k.isFavorit).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('BUKU KONTAK'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Kontak'),
            Tab(icon: Icon(Icons.star), text: 'Favorit'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'BUKU KONTAK',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Kontak'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Tambah Kontak'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TambahKontakPage()),
                ).then((_) => setState(() {}));
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Favorit'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Tentang'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TentangPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Pencarian & Daftar Semua Kontak (Tugas 6)[cite: 1]
          Column(
            children: [
              // TUGAS 6: Input TextField Pencarian Kontak[cite: 1]
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _searchQueryController,
                  decoration: const InputDecoration(
                    labelText: 'Cari Kontak (Nama / Kategori)',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (teks) {
                    _searchController.add(teks); // TUGAS 6: Mengirim teks input ke stream[cite: 1]
                  },
                ),
              ),
              Expanded(
                // TUGAS 6: StreamBuilder untuk mendengarkan perubahan kata kunci pencarian[cite: 1]
                child: StreamBuilder<String>(
                  stream: _searchController.stream,
                  initialData: '',
                  builder: (context, snapshot) {
                    final query = (snapshot.data ?? '').toLowerCase();

                    // TUGAS 6: Filtering daftar kontak berdasarkan nama ATAU kategori (tidak case-sensitive)[cite: 1]
                    final filteredKontak = globalDaftarKontak.where((kontak) {
                      final namaMatch = kontak.nama.toLowerCase().contains(query);
                      final kategoriMatch = (kontak.kategori ?? '').toLowerCase().contains(query);
                      return namaMatch || kategoriMatch;
                    }).toList();

                    if (filteredKontak.isEmpty) {
                      return const Center(child: Text('Kontak tidak ditemukan / Belum ada kontak'));
                    }

                    return ListView.builder(
                      itemCount: filteredKontak.length,
                      itemBuilder: (context, index) {
                        final kontak = filteredKontak[index];
                        final String inisial = kontak.nama.isNotEmpty 
                            ? kontak.nama[0].toUpperCase() 
                            : '?';

                        return ListTile(
                          // CircleAvatar inisial (Tugas 3)[cite: 1]
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Text(
                              inisial,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            kontak.nama, 
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          // Subtitle dengan kategori (Tugas 4)[cite: 1]
                          subtitle: Text(
                            'Email: ${kontak.email}\nNo HP: ${kontak.noHp}\nKategori: ${kontak.kategori ?? 'Tanpa kategori'}',
                          ),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: Icon(
                              kontak.isFavorit ? Icons.star : Icons.star_border,
                              color: kontak.isFavorit ? Colors.amber : Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                kontak.isFavorit = !kontak.isFavorit;
                              });
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // Tab 2: Daftar Kontak Favorit
          daftarFavorit.isEmpty
              ? const Center(child: Text('Belum ada kontak favorit'))
              : ListView.builder(
                  itemCount: daftarFavorit.length,
                  itemBuilder: (context, index) {
                    final kontak = daftarFavorit[index];
                    final String inisial = kontak.nama.isNotEmpty 
                        ? kontak.nama[0].toUpperCase() 
                        : '?';

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber,
                        child: Text(
                          inisial,
                          style: const TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        kontak.nama, 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Email: ${kontak.email}\nNo HP: ${kontak.noHp}\nKategori: ${kontak.kategori ?? 'Tanpa kategori'}',
                      ),
                      isThreeLine: true,
                      trailing: const Icon(Icons.star, color: Colors.amber),
                    );
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple.shade100,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahKontakPage()),
          ).then((_) => setState(() {}));
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}

// Halaman Form Tambah Kontak (Tugas 5)[cite: 1]
class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() => _TambahKontakPageState();
}

class _TambahKontakPageState extends State<TambahKontakPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _kategoriController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        globalDaftarKontak.add(
          Kontak(
            nama: _namaController.text.trim(),
            email: _emailController.text.trim(),
            noHp: _noHpController.text.trim(),
            kategori: _kategoriController.text.trim().isEmpty 
                ? null 
                : _kategoriController.text.trim(),
          ),
        );
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kontak'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: _namaController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email harus mengandung karakter @';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noHpController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'No Handphone'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'No Handphone wajib diisi';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                      return 'No Handphone hanya boleh berisi angka';
                    }
                    if (value.trim().length < 10) {
                      return 'No Handphone minimal 10 digit';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _kategoriController,
                  decoration: const InputDecoration(
                    labelText: 'Kategori (Opsional, ex: Keluarga/Teman/Kerja)',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _simpanKontak,
                  child: const Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Halaman Tentang Profil Diri
class TentangPage extends StatelessWidget {
  const TentangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange,
              backgroundImage: AssetImage('assets/salman.png'),
            ),
            SizedBox(height: 16),
            Text(
              'Salman Alfarizi Bashen',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('XII RPL B', style: TextStyle(fontSize: 16)),
            SizedBox(height: 4),
            Text('SMK Negeri 5 Surakarta', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}