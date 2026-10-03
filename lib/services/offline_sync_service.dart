import '../data/models/sayim_raporu_model.dart';

/// Offline-first sync layer template.
///
/// Planned stack:
/// - Local: SQLite (drift) or Hive for SayimRaporu + Urun cache
/// - Remote: company REST API / Firebase / Supabase
/// - Strategy: write locally first, queue pending ops, sync when online
class OfflineSyncService {
  OfflineSyncService._();
  static final OfflineSyncService instance = OfflineSyncService._();

  // TODO: Inject local database + HTTP client
  // TODO: Listen to connectivity (connectivity_plus) and trigger sync

  /// Persists a report to local storage immediately (offline-first).
  Future<void> saveReportLocally(SayimRaporu rapor) async {
    // TODO: Insert into local DB with syncStatus = pending
    // await _db.sayimRaporlari.insert(rapor.toJson());
  }

  /// Returns all reports not yet pushed to the server.
  Future<List<SayimRaporu>> getPendingReports() async {
    // TODO: SELECT * FROM sayim_raporlari WHERE sync_status = 'pending'
    return [];
  }

  /// Pushes pending records to the server when connectivity is available.
  Future<void> syncWithServer() async {
    // TODO: Check network connectivity
    // TODO: For each pending report → POST /api/sayim
    // TODO: Mark as synced on success, retry with backoff on failure
  }

  /// Caches product catalog for offline barcode lookup.
  Future<void> cacheProducts(List<dynamic> products) async {
    // TODO: Upsert products into local cache table
  }

  /// Pulls latest catalog from server and refreshes local cache.
  Future<void> pullRemoteCatalog() async {
    // TODO: GET /api/urunler → cacheProducts()
  }
}
