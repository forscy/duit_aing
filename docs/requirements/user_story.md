
## 1. User Story & User Acceptance Criteria (*Duit Aing*)

### US-01 Membuat Dompet

Sebagai pengguna, saya ingin membuat beberapa dompet dengan nama, saldo awal, dan opsi Private/Shared sehingga saya bisa mengelola saldo yang berbeda.
**Acceptance:** pengguna mengisi form nama + saldo + tipe, dompet tampil di daftar, dompet shared menghasilkan link/QR.

### US-02 Mencatat Transaksi di Dompet

Sebagai pengguna, saya ingin mencatat pemasukan dan pengeluaran di setiap dompet sehingga saya bisa memantau perubahan saldo.
**Acceptance:** bisa tambah transaksi dengan nominal, deskripsi, tanggal; riwayat tampil terbaru di atas; saldo ter-update otomatis.

### US-03 Membagikan Akses Dompet

Sebagai pemilik dompet, saya ingin membagikan akses via link, QR, atau email sehingga orang lain bisa ikut memakai dompet.
**Acceptance:** dompet shared memiliki link, QR atau email, user lain bisa join, bisa lihat dan mencatat transaksi.

### US-04 Mencatat Hutang/Piutang

Sebagai pengguna, saya ingin mencatat siapa ber-utang atau piutang sehingga catatan transparan dengan memilih dompet sumber pencatatan tersebut.
**Acceptance:** Isi detail hutang/piutang (termasuk tipe hutang/piutang), data muncul di daftar, bisa difilter status. Misal jika yang dicatat adalah hutang dan dipilih di dompet mana yang melakukan transaksi maka akan dikurangi atau ditambah sesuai dengan jenis transaksinya terhadap dompet yang dipilih.

### US-05 Menandai Hutang/Piutang Lunas

Sebagai pengguna, saya ingin menandai hutang lunas dengan memilih dompet sumber pelunasan sehingga saldo ter-update otomatis.
**Acceptance:** tombol “Lunas” meminta dompet, saldo dompet disesuaikan, status berubah menjadi Lunas.

### US-06 Melihat Ringkasan Keuangan

Sebagai pengguna, saya ingin melihat total saldo dan total hutang/piutang sehingga mengetahui posisi finansial.
**Acceptance:** halaman Summary menampilkan total saldo seluruh dompet dan total hutang/piutang (pie chart).

### US-07 Transfer Antar Dompet

Sebagai pengguna, saya ingin memindahkan dana dari satu dompet ke dompet lain sehingga lebih fleksibel.
**Acceptance:** form pilih dompet asal & tujuan, masukkan nominal + catatan, saldo dua dompet ter-update, riwayat pada kedua dompet mencatat transfer.

---

## 6. Checklist Fitur yang Sudah Jadi (Kode)

* Auth Email/Password + Logout.

---

Happy coding & keep experimenting 🔥
