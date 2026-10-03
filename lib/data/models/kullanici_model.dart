import 'dart:convert';

enum KullaniciRolu { employee, manager }

class HesapKaydi {
  const HesapKaydi({
    required this.id,
    required this.email,
    required this.sifre,
    required this.adSoyad,
    required this.rol,
  });

  final String id;
  final String email;
  final String sifre;
  final String adSoyad;
  final KullaniciRolu rol;

  Kullanici toKullanici() => Kullanici(
        id: id,
        email: email,
        rol: rol,
        adSoyad: adSoyad,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'sifre': sifre,
        'adSoyad': adSoyad,
        'rol': rol.name,
      };

  factory HesapKaydi.fromJson(Map<String, dynamic> json) => HesapKaydi(
        id: json['id'] as String,
        email: json['email'] as String,
        sifre: json['sifre'] as String,
        adSoyad: json['adSoyad'] as String,
        rol: KullaniciRolu.values.byName(json['rol'] as String),
      );
}

class Kullanici {
  const Kullanici({
    required this.id,
    required this.email,
    required this.rol,
    required this.adSoyad,
  });

  final String id;
  final String email;
  final KullaniciRolu rol;
  final String adSoyad;

  bool get yoneticiMi => rol == KullaniciRolu.manager;

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'rol': rol.name,
        'adSoyad': adSoyad,
      };

  factory Kullanici.fromJson(Map<String, dynamic> json) => Kullanici(
        id: json['id'] as String,
        email: json['email'] as String,
        rol: KullaniciRolu.values.byName(json['rol'] as String),
        adSoyad: json['adSoyad'] as String,
      );

  String toJsonString() => jsonEncode(toJson());

  factory Kullanici.fromJsonString(String raw) =>
      Kullanici.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
