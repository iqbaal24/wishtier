# PRD WishTier

Aplikasi Wishlist Bertingkat Berbasis Flutter

## 1. Ringkasan Produk

WishTier adalah aplikasi mobile untuk mencatat daftar keinginan (wishlist) yang dikelompokkan ke dalam tier, mulai dari yang paling penting sampai yang kurang penting. Berbeda dari wishlist biasa yang hanya berupa daftar panjang, WishTier membantu pengguna melihat dengan jelas mana yang harus dibeli lebih dulu dan mana yang bisa menunggu. Aplikasi dibuat menggunakan Flutter agar bisa berjalan di Android dan iOS dengan satu kode program.

## 2. Latar Belakang dan Masalah

Banyak orang punya banyak keinginan, tetapi dana terbatas. Wishlist di catatan biasa atau marketplace tidak memberi prioritas, sehingga pengguna sering membeli barang yang kurang penting lebih dulu atau lupa pada barang yang sebenarnya paling dibutuhkan. WishTier menyelesaikan masalah ini dengan sistem tier yang sederhana dan mudah dilihat sekilas.

## 3. Tujuan Produk

Tujuan utamanya adalah membuat pengguna bisa menambah keinginan dalam waktu kurang dari setengah menit, langsung menentukan tingkat pentingnya, dan melihat daftar yang sudah tersusun rapi per tier. Tujuan tambahannya adalah membantu pengguna mengambil keputusan belanja yang lebih bijak dengan melihat total biaya tiap tier.

## 4. Target Pengguna

Pengguna utama adalah mahasiswa dan pekerja muda yang punya banyak keinginan tetapi anggaran terbatas dan ingin lebih teratur dalam mengatur prioritas belanja. Mereka terbiasa memakai smartphone dan menginginkan aplikasi yang cepat, ringan, dan tidak rumit.

## 5. Konsep Tier

WishTier memakai empat tier. Tier S untuk keinginan yang sangat penting dan mendesak, Tier A untuk yang penting, Tier B untuk yang cukup penting, dan Tier C untuk yang boleh ditunda atau hanya nice to have. Pengguna dapat memindahkan item antar tier kapan saja, misalnya lewat drag and drop, karena prioritas bisa berubah seiring waktu.

## 6. Fitur Utama (MVP)

Fitur pertama adalah manajemen item wishlist, yaitu menambah, mengubah, dan menghapus item dengan data nama, harga perkiraan, tier, catatan, tautan produk, dan foto opsional. Fitur kedua adalah tampilan berbasis tier, yaitu daftar item dikelompokkan per tier dengan warna berbeda dan bisa dipindah antar tier dengan drag and drop. Fitur ketiga adalah penanda sudah terbeli, sehingga item yang sudah dibeli berpindah ke riwayat dan tidak mengganggu daftar aktif. Fitur keempat adalah ringkasan biaya, yaitu total harga per tier dan total keseluruhan. Fitur kelima adalah pencarian dan filter berdasarkan nama, tier, atau status. Semua data pada versi awal disimpan secara lokal di perangkat sehingga bisa dipakai tanpa internet.

## 7. Fitur Pengembangan Berikutnya

Setelah MVP selesai, aplikasi dapat ditambah login dan sinkronisasi cloud, target tanggal beli, pengingat notifikasi, berbagi wishlist dengan teman atau keluarga, pelacakan penurunan harga dari tautan produk, serta mode gelap.

## 8. Alur Pengguna Utama

Pengguna membuka aplikasi dan langsung melihat daftar wishlist per tier. Saat menekan tombol tambah, pengguna mengisi nama dan harga, memilih tier, lalu menyimpan. Item muncul di tier yang dipilih. Jika prioritas berubah, pengguna menekan lama dan menggeser item ke tier lain. Setelah barang dibeli, pengguna menandainya sebagai terbeli dan item masuk ke riwayat.

## 9. Kebutuhan Non-Fungsional

Aplikasi harus terbuka dalam waktu kurang dari tiga detik, berjalan lancar di perangkat Android menengah, bisa dipakai offline, dan memiliki tampilan yang bersih dengan teks mudah dibaca. Data pengguna hanya tersimpan di perangkat pada versi awal sehingga tidak ada data pribadi yang dikirim ke server.

## 10. Rekomendasi Teknologi

Aplikasi dibangun dengan Flutter dan bahasa Dart. Untuk pengelolaan state disarankan Riverpod atau Provider, untuk penyimpanan lokal disarankan Hive atau sqflite (Drift), dan untuk fitur drag and drop bisa memakai widget ReorderableListView atau paket pendukungnya. Jika nanti butuh sinkronisasi cloud, Firebase atau Supabase bisa dipakai.

## 11. Ukuran Keberhasilan

Produk dianggap berhasil jika pengguna bisa menambah item dalam waktu kurang dari 30 detik, mayoritas item sudah memiliki tier, dan pengguna kembali membuka aplikasi secara rutin untuk memperbarui wishlist mereka.

## 12. Rencana Rilis

Tahap pertama adalah desain UI dan prototipe, tahap kedua adalah pengembangan fitur inti (CRUD dan tampilan tier), tahap ketiga adalah ringkasan biaya, pencarian, dan riwayat, lalu tahap terakhir adalah pengujian dengan beberapa pengguna dan perbaikan sebelum rilis.
