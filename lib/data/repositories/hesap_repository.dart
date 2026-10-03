import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/kullanici_model.dart';

/// Yalnızca yöneticinin oluşturduğu hesaplar — kayıt ekranı yok.
class HesapRepository {
  HesapRepository._();
  static final HesapRepository instance = HesapRepository._();

  static const _keyHesaplar = 'hesaplar_v1';
  static const varsayilanYoneticiEmail = 'yonetici@sirket.com';
  static const varsayilanYoneticiSifre = 'Yonetici#2026';
  static const _eskiZayifSifre = 'admin123';

  final List<HesapKaydi> _hesaplar = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyHesaplar);

    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _hesaplar
        ..clear()
        ..addAll(
          list.map((e) => HesapKaydi.fromJson(e as Map<String, dynamic>)),
        );
      await _zayifYoneticiSifresiniGuncelle();
    } else {
      _hesaplar.add(
        const HesapKaydi(
          id: 'admin-1',
          email: varsayilanYoneticiEmail,
          sifre: varsayilanYoneticiSifre,
          adSoyad: 'Depo Yöneticisi',
          rol: KullaniciRolu.manager,
        ),
      );
      await _persist();
    }

    _initialized = true;
  }

  Future<void> _zayifYoneticiSifresiniGuncelle() async {
    final index = _hesaplar.indexWhere(
      (h) =>
          h.email.toLowerCase() == varsayilanYoneticiEmail &&
          h.sifre == _eskiZayifSifre,
    );
    if (index == -1) return;

    final mevcut = _hesaplar[index];
    _hesaplar[index] = HesapKaydi(
      id: mevcut.id,
      email: mevcut.email,
      sifre: varsayilanYoneticiSifre,
      adSoyad: mevcut.adSoyad,
      rol: mevcut.rol,
    );
    await _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyHesaplar,
      jsonEncode(_hesaplar.map((h) => h.toJson()).toList()),
    );
  }

  List<HesapKaydi> get personelHesaplari => _hesaplar
      .where((h) => h.rol == KullaniciRolu.employee)
      .toList();

  Kullanici? girisYap(String email, String sifre) {
    final normalized = email.trim().toLowerCase();
    for (final hesap in _hesaplar) {
      if (hesap.email.toLowerCase() == normalized && hesap.sifre == sifre) {
        return hesap.toKullanici();
      }
    }
    return null;
  }

  bool emailKayitliMi(String email) {
    final normalized = email.trim().toLowerCase();
    return _hesaplar.any((h) => h.email.toLowerCase() == normalized);
  }

  Future<HesapKaydi> personelHesabiOlustur({
    required String adSoyad,
    required String email,
    required String sifre,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (emailKayitliMi(normalized)) {
      throw StateError('Bu e-posta zaten kayıtlı.');
    }

    final hesap = HesapKaydi(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: normalized,
      sifre: sifre,
      adSoyad: adSoyad.trim(),
      rol: KullaniciRolu.employee,
    );
    _hesaplar.add(hesap);
    await _persist();
    return hesap;
  }

  Future<void> personelHesabiSil(String id) async {
    _hesaplar.removeWhere((h) => h.id == id && h.rol == KullaniciRolu.employee);
    await _persist();
  }
}
