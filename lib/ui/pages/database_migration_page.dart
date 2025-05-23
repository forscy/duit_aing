import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duit_aing/models/enums.dart';
import 'package:duit_aing/models/transaction.dart';
import 'package:duit_aing/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

/// Halaman untuk melakukan migrasi struktur database
class DatabaseMigrationPage extends ConsumerStatefulWidget {
  const DatabaseMigrationPage({super.key});

  @override
  ConsumerState<DatabaseMigrationPage> createState() => _DatabaseMigrationPageState();
}

class _DatabaseMigrationPageState extends ConsumerState<DatabaseMigrationPage> {
  bool _isMigrating = false;
  bool _migrationCompleted = false;
  String _status = 'Siap untuk migrasi';
  String _log = '';
  int _totalTransactions = 0;
  int _migratedTransactions = 0;
  int _transfersHandled = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _scrollController = ScrollController();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _appendLog(String message) {
    setState(() {
      _log = '$_log\n$message';
    });
    // Auto-scroll log to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  Future<void> _migrateTransactions() async {
    if (_isMigrating) return;

    setState(() {
      _isMigrating = true;
      _status = 'Memulai migrasi...';
      _log = '';
      _totalTransactions = 0;
      _migratedTransactions = 0;
      _transfersHandled = 0;
      _migrationCompleted = false;
    });

    try {
      // 1. Dapatkan semua transaksi
      _appendLog('Mengambil transaksi dari koleksi lama...');
      final transactionsSnapshot = await _firestore.collection('transactions').get();
      final transactions = transactionsSnapshot.docs
          .map((doc) => TransactionModel.fromMap({'id': doc.id, ...doc.data()}))
          .toList();

      setState(() {
        _totalTransactions = transactions.length;
        _status = 'Memindahkan ${transactions.length} transaksi...';
      });

      _appendLog('Total transaksi yang akan dimigrasikan: ${transactions.length}');
      
      // Kelompokkan transfer untuk memastikan integritas data
      final transferTransactions = transactions
          .where((t) => t.type == TransactionType.transfer && t.destinationWalletId != null)
          .toList();
      
      if (transferTransactions.isNotEmpty) {
        _appendLog('Ditemukan ${transferTransactions.length} transaksi transfer yang perlu penanganan khusus');
      }

      // 2. Buat batch untuk migrasi
      final int batchSize = 200; // Firestore memiliki batasan batch size
      int processedCount = 0;

      while (processedCount < transactions.length) {
        // Ambil batch transaksi berikutnya
        final int endIdx = (processedCount + batchSize) < transactions.length 
            ? (processedCount + batchSize) 
            : transactions.length;
        
        final batch = _firestore.batch();
        final currentBatch = transactions.sublist(processedCount, endIdx);
        
        _appendLog('Memproses batch ${processedCount + 1} - $endIdx dari ${transactions.length}...');

        // Pindahkan setiap transaksi ke subkoleksi wallet-nya
        for (var transaction in currentBatch) {
          final newTransactionRef = _firestore
              .collection('wallets')
              .doc(transaction.walletId)
              .collection('transactions')
              .doc(transaction.id);
          
          batch.set(newTransactionRef, transaction.toMap());
          
          // Untuk transfer, kita perlu mengupdate wallet tujuan juga
          if (transaction.type == TransactionType.transfer && 
              transaction.destinationWalletId != null) {
            // Buat transaksi pemasukan di dompet tujuan jika belum ada
            try {
              // Dapatkan info wallet sumber
              final sourceWalletSnapshot = await _firestore
                  .collection('wallets')
                  .doc(transaction.walletId)
                  .get();
              
              if (sourceWalletSnapshot.exists) {
                final sourceWallet = WalletModel.fromMap({
                  'id': sourceWalletSnapshot.id,
                  ...sourceWalletSnapshot.data()!
                });
                
                // Cek apakah transaksi di dompet tujuan sudah ada
                final destTransactionQuery = await _firestore
                    .collection('wallets')
                    .doc(transaction.destinationWalletId)
                    .collection('transactions')
                    .where('destinationWalletId', isEqualTo: transaction.walletId)
                    .where('timestamp', isEqualTo: transaction.timestamp)
                    .get();
                
                // Jika belum ada, buat transaksi income di dompet tujuan
                if (destTransactionQuery.docs.isEmpty) {
                  final destTransactionId = const Uuid().v4();
                  final destTransaction = TransactionModel(
                    id: destTransactionId,
                    walletId: transaction.destinationWalletId!,
                    amount: transaction.amount,
                    description: "Transfer dari ${sourceWallet.name}: ${transaction.description}",
                    type: TransactionType.income,
                    destinationWalletId: transaction.walletId,
                    timestamp: transaction.timestamp,
                  );
                  
                  final destTransactionRef = _firestore
                      .collection('wallets')
                      .doc(transaction.destinationWalletId)
                      .collection('transactions')
                      .doc(destTransactionId);
                  
                  batch.set(destTransactionRef, destTransaction.toMap());
                  _transfersHandled++;
                  _appendLog('✓ Membuat catatan transfer di wallet ${transaction.destinationWalletId}');
                } else {
                  _appendLog('✓ Transaksi transfer di wallet tujuan sudah ada'); 
                }
              }
            } catch (e) {
              _appendLog('⚠️ Error saat menangani transfer: ${e.toString()}');
            }
          }
        }

        // Commit batch
        await batch.commit();
        
        processedCount = endIdx;
        setState(() {
          _migratedTransactions = processedCount;
          _status = 'Memindahkan transaksi: $processedCount/${transactions.length}';
        });
        
        _appendLog('Batch $processedCount selesai!');
      }      // 3. Verifikasi migrasi
      _appendLog('Memverifikasi migrasi...');
      
      // Hitung jumlah transaksi yang telah dimigrasi di subkoleksi
      int migratedCount = 0;
      final walletSnapshot = await _firestore.collection('wallets').get();
      
      for (var walletDoc in walletSnapshot.docs) {
        final transactionCount = await _firestore
            .collection('wallets')
            .doc(walletDoc.id)
            .collection('transactions')
            .count()
            .get();
        
        migratedCount += transactionCount.count ?? 0;
      }
      
      _appendLog('Jumlah transaksi di struktur baru: $migratedCount');
      
      if (migratedCount >= _totalTransactions) {
        _appendLog('✅ Verifikasi berhasil: Semua transaksi berhasil dimigrasikan');
      } else {
        _appendLog('⚠️ Verifikasi: Ada ${_totalTransactions - migratedCount} transaksi yang belum dimigrasikan');
      }
      
      if (_transfersHandled > 0) {
        _appendLog('✅ $_transfersHandled transaksi transfer berhasil diproses');
      }
      
      // Setelah selesai, kita dapat menghapus koleksi lama
      // Tapi untuk saat ini kita biarkan untuk keamanan
      _appendLog('Migrasi selesai! Koleksi lama masih disimpan untuk backup.');
        setState(() {
        _status = 'Migrasi selesai! Transaksi berhasil dimigrasikan: $migratedCount';
        _isMigrating = false;
        _migrationCompleted = true;
      });
    } catch (error) {
      _appendLog('Error: ${error.toString()}');
      setState(() {
        _status = 'Error: ${error.toString()}';
        _isMigrating = false;
        _migrationCompleted = false;
      });
    }
  }

  void _showDeleteOldDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Lama?'),
        content: const Text(
          'Ini akan menghapus PERMANEN semua transaksi dari koleksi lama. '
          'Pastikan Anda telah memverifikasi bahwa semua data telah berhasil dimigrasikan. '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              _deleteOldTransactions();
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteOldTransactions() async {
    setState(() {
      _isMigrating = true;
      _status = 'Menghapus data lama...';
    });
    
    try {
      _appendLog('Memulai penghapusan data lama...');
      
      // Mengambil semua transaksi lama
      final snapshot = await _firestore.collection('transactions').get();
      _appendLog('Ditemukan ${snapshot.docs.length} transaksi di koleksi lama');
      
      // Batch delete untuk efisiensi
      int count = 0;
      const batchSize = 500;
      List<WriteBatch> batches = [];
      WriteBatch currentBatch = _firestore.batch();
      int currentBatchSize = 0;
      
      for (var doc in snapshot.docs) {
        currentBatch.delete(doc.reference);
        currentBatchSize++;
        count++;
        
        // Jika batch penuh, tambahkan ke daftar dan buat batch baru
        if (currentBatchSize >= batchSize) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          currentBatchSize = 0;
          _appendLog('Batch hapus $count dokumen siap');
        }
      }
      
      // Tambahkan batch terakhir jika masih ada data
      if (currentBatchSize > 0) {
        batches.add(currentBatch);
        _appendLog('Batch hapus terakhir dengan $currentBatchSize dokumen siap');
      }
      
      // Menjalankan semua batch
      int batchCount = 0;
      for (var batch in batches) {
        await batch.commit();
        batchCount++;
        _appendLog('Batch $batchCount/${batches.length} berhasil dihapus');
      }
      
      _appendLog('✅ Berhasil menghapus $count transaksi dari koleksi lama');
      
      setState(() {
        _status = 'Data lama berhasil dihapus!';
        _isMigrating = false;
      });
    } catch (e) {
      _appendLog('⚠️ Error saat menghapus data lama: ${e.toString()}');
      setState(() {
        _status = 'Error saat menghapus data lama';
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migrasi Database'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_migrationCompleted) 
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Migrasi Berhasil',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('• Transaksi dimigrasikan: $_totalTransactions'),
                      if (_transfersHandled > 0)
                        Text('• Transfer berhasil ditangani: $_transfersHandled'),
                      const SizedBox(height: 8),
                      const Text(
                        'Semua transaksi sekarang tersimpan sebagai subkoleksi dalam wallet masing-masing. '
                        'Jika Anda yakin data telah berhasil dimigrasikan, Anda dapat menghapus data lama untuk menghemat ruang penyimpanan.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Migrasi Struktur Database',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Fitur ini akan memindahkan data transaksi dari koleksi terpisah menjadi subkoleksi di dalam wallet. '
                      'Migrasi ini penting untuk meningkatkan performa dan mempermudah indexing di Firestore.',
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: _totalTransactions > 0 
                          ? _migratedTransactions / _totalTransactions 
                          : 0,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Transaksi: $_migratedTransactions/$_totalTransactions',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (_transfersHandled > 0)
                  Text(
                    'Transfer diproses: $_transfersHandled',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _isMigrating ? null : () => context.pop(),
                  child: const Text('Kembali'),
                ),
                FilledButton(
                  onPressed: _isMigrating ? null : _migrateTransactions,
                  child: _isMigrating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Mulai Migrasi'),
                ),
              ],
            ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Log Migrasi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              height: 300,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Text(
                  _log.isEmpty ? 'Belum ada log...' : _log,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 16),
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isMigrating ? null : () => _showDeleteOldDataDialog(),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Hapus Data Lama'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
