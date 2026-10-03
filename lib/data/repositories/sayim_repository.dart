import '../models/personel_mesaji_model.dart';
import '../models/sayim_gorevi_model.dart';
import '../models/sayim_raporu_model.dart';
import '../../services/local_storage_service.dart';

class SayimRepository {
  SayimRepository._();
  static final SayimRepository instance = SayimRepository._();

  final _storage = LocalStorageService.instance;

  final List<SayimGorevi> _gorevler = [];
  final List<SayimRaporu> _raporlar = [];
  final List<PersonelMesaji> _mesajlar = [];

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final stored = await _storage.load();
    if (stored != null) {
      _gorevler
        ..clear()
        ..addAll(stored.gorevler);
      _raporlar
        ..clear()
        ..addAll(stored.raporlar);
      _mesajlar
        ..clear()
        ..addAll(stored.mesajlar);
    }

    _initialized = true;
  }

  Future<void> _persist() async {
    await _storage.save(
      StoredAppData(
        gorevler: List.from(_gorevler),
        raporlar: List.from(_raporlar),
        mesajlar: List.from(_mesajlar),
      ),
    );
  }

  List<SayimRaporu> get tamamlananRaporlar => List.unmodifiable(_raporlar);

  List<PersonelMesaji> get personelMesajlari => List.unmodifiable(_mesajlar);

  List<SayimGorevi> get aktifGorevler => List.unmodifiable(_gorevler);

  SayimGorevi? gorevBul(String id) {
    for (final g in _gorevler) {
      if (g.id == id) return g;
    }
    return null;
  }

  List<SayimRaporu> gorevRaporlari(String gorevId) =>
      _raporlar.where((r) => r.gorevId == gorevId).toList();

  SayimRaporu? raporBul(String id) {
    for (final r in _raporlar) {
      if (r.id == id) return r;
    }
    return null;
  }

  int gorevSayimAdedi(String gorevId) => gorevRaporlari(gorevId).length;

  Future<SayimGorevi> gorevOlustur({
    required String baslik,
    required String olusturanId,
    required String olusturanAdi,
  }) async {
    final gorev = SayimGorevi(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      baslik: baslik.trim(),
      olusturanId: olusturanId,
      olusturanAdi: olusturanAdi,
      olusturmaTarihi: DateTime.now(),
    );
    _gorevler.insert(0, gorev);
    await _persist();
    return gorev;
  }

  Future<void> raporEkle(SayimRaporu rapor) async {
    _raporlar.insert(0, rapor);
    await _persist();
  }

  Future<void> raporGuncelle(SayimRaporu rapor) async {
    final index = _raporlar.indexWhere((r) => r.id == rapor.id);
    if (index == -1) return;
    _raporlar[index] = rapor;
    await _persist();
  }

  Future<void> raporSil(String id) async {
    _raporlar.removeWhere((r) => r.id == id);
    await _persist();
  }

  Future<void> gorevSil(String gorevId) async {
    _gorevler.removeWhere((g) => g.id == gorevId);
    _raporlar.removeWhere((r) => r.gorevId == gorevId);
    await _persist();
  }

  Future<void> mesajEkle(PersonelMesaji mesaj) async {
    _mesajlar.insert(0, mesaj);
    await _persist();
  }

  Future<void> mesajSil(String mesajId) async {
    _mesajlar.removeWhere((m) => m.id == mesajId);
    await _persist();
  }
}
