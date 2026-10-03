class PersonelMesaji {
  const PersonelMesaji({
    required this.id,
    required this.baslik,
    required this.icerik,
    required this.tarih,
    required this.yoneticiAdi,
  });

  final String id;
  final String baslik;
  final String icerik;
  final DateTime tarih;
  final String yoneticiAdi;

  Map<String, dynamic> toJson() => {
        'id': id,
        'baslik': baslik,
        'icerik': icerik,
        'tarih': tarih.toIso8601String(),
        'yoneticiAdi': yoneticiAdi,
      };

  factory PersonelMesaji.fromJson(Map<String, dynamic> json) => PersonelMesaji(
        id: json['id'] as String,
        baslik: json['baslik'] as String,
        icerik: json['icerik'] as String,
        tarih: DateTime.parse(json['tarih'] as String),
        yoneticiAdi: json['yoneticiAdi'] as String,
      );
}
