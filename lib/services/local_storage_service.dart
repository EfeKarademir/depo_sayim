import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/personel_mesaji_model.dart';
import '../data/models/sayim_gorevi_model.dart';
import '../data/models/sayim_raporu_model.dart';

class LocalStorageService {
  LocalStorageService._();
  static final LocalStorageService instance = LocalStorageService._();

  static const _keyAppData = 'app_data_v1';

  Future<StoredAppData?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAppData);
    if (raw == null) return null;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return StoredAppData.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(StoredAppData data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAppData, jsonEncode(data.toJson()));
  }
}

class StoredAppData {
  const StoredAppData({
    required this.gorevler,
    required this.raporlar,
    required this.mesajlar,
  });

  final List<SayimGorevi> gorevler;
  final List<SayimRaporu> raporlar;
  final List<PersonelMesaji> mesajlar;

  Map<String, dynamic> toJson() => {
        'gorevler': gorevler.map((g) => g.toJson()).toList(),
        'raporlar': raporlar.map((r) => r.toJson()).toList(),
        'mesajlar': mesajlar.map((m) => m.toJson()).toList(),
      };

  factory StoredAppData.fromJson(Map<String, dynamic> json) => StoredAppData(
        gorevler: (json['gorevler'] as List<dynamic>? ?? [])
            .map((e) => SayimGorevi.fromJson(e as Map<String, dynamic>))
            .toList(),
        raporlar: (json['raporlar'] as List<dynamic>? ?? [])
            .map((e) => SayimRaporu.fromJson(e as Map<String, dynamic>))
            .toList(),
        mesajlar: (json['mesajlar'] as List<dynamic>? ?? [])
            .map((e) => PersonelMesaji.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
