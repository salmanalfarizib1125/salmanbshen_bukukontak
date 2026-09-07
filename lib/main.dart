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

// Model data untuk menyimpan informasi kontak dan status favoritnya
class Kontak {
  final String nama;
  final String email;
  final String noHp;
  bool isFavorit;

  Kontak({
    required this.nama,
    required this.email,
    required this.noHp,
    this.isFavorit = false,
  });
}

// Global list untuk menyimpan daftar kontak agar dapat diakses di berbagai halaman
List<Kontak> globalDaftarKontak = [];

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Menyaring daftar kontak yang berstatus favorit untuk ditampilkan di tab Favorit
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
                ).then((_) {
                  setState(() {}); // Memperbarui tampilan saat kembali dari halaman tambah
                });
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
          // Tab 1: Daftar Semua Kontak
          globalDaftarKontak.isEmpty
              ? const Center(child: Text('Belum ada kontak'))
              : ListView.builder(
                  itemCount: globalDaftarKontak.length,
                  itemBuilder: (context, index) {
                    final kontak = globalDaftarKontak[index];
                    
                    // TUGAS 3: Mengambil inisial huruf pertama nama (huruf kapital)
                    final String inisial = kontak.nama.isNotEmpty 
                        ? kontak.nama[0].toUpperCase() 
                        : '?';

                    return ListTile(
                      // TUGAS 3: Mengubah Icon menjadi CircleAvatar berinisial
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
                      subtitle: Text('${kontak.email}\n${kontak.noHp}'),
                      isThreeLine: true,
                      // Tombol bintang interaktif untuk mengubah status favorit
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
                ),
          
          // Tab 2: Daftar Kontak Favorit
          daftarFavorit.isEmpty
              ? const Center(child: Text('Belum ada kontak favorit'))
              : ListView.builder(
                  itemCount: daftarFavorit.length,
                  itemBuilder: (context, index) {
                    final kontak = daftarFavorit[index];

                    // TUGAS 3: Inisial untuk tab favorit
                    final String inisial = kontak.nama.isNotEmpty 
                        ? kontak.nama[0].toUpperCase() 
                        : '?';

                    return ListTile(
                      // TUGAS 3: CircleAvatar inisial untuk tab favorit
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
                      subtitle: Text('${kontak.email}\n${kontak.noHp}'),
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
          ).then((_) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add, color: Colors.black87),
      ),
    );
  }
}

// Halaman Form Tambah Kontak
class TambahKontakPage extends StatefulWidget {
  const TambahKontakPage({super.key});

  @override
  State<TambahKontakPage> createState() => _TambahKontakPageState();
}

class _TambahKontakPageState extends State<TambahKontakPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  void _simpanKontak() {
    if (_namaController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _noHpController.text.isNotEmpty) {
      setState(() {
        globalDaftarKontak.add(
          Kontak(
            nama: _namaController.text,
            email: _emailController.text,
            noHp: _noHpController.text,
          ),
        );
      });
      // Kembali ke halaman sebelumnya setelah berhasil menyimpan
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
        child: Column(
          children: <Widget>[
            TextField(
              controller: _namaController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noHpController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'No Handphone'),
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
    );
  }
}

// Halaman Tentang (Profil Diri dengan Foto)
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