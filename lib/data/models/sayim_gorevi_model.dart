class SayimGorevi {
  const SayimGorevi({
    required this.id,
    required this.baslik,
    required this.olusturanId,
    required this.olusturanAdi,
    required this.olusturmaTarihi,
  });

  final String id;
  final String baslik;
  final String olusturanId;
  final String olusturanAdi;
  final DateTime olusturmaTarihi;

  Map<String, dynamic> toJson() => {
        'id': id,
        'baslik': baslik,
        'olusturanId': olusturanId,
        'olusturanAdi': olusturanAdi,
        'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
      };

  factory SayimGorevi.fromJson(Map<String, dynamic> json) => SayimGorevi(
        id: json['id'] as String,
        baslik: json['baslik'] as String,
        olusturanId: json['olusturanId'] as String,
        olusturanAdi: json['olusturanAdi'] as String,
        olusturmaTarihi: DateTime.parse(json['olusturmaTarihi'] as String),
      );
}
