class SayimRaporu {
  const SayimRaporu({
    required this.id,
    required this.gorevId,
    required this.urunId,
    required this.urunAdi,
    required this.barkod,
    required this.beklenenMiktar,
    required this.sayilanMiktar,
    required this.sayimTarihi,
    required this.kullaniciId,
    this.kullaniciAdi,
    this.gorevAdi,
  });

  final String id;
  final String gorevId;
  final String urunId;
  final String urunAdi;
  final String barkod;
  final int beklenenMiktar;
  final int sayilanMiktar;
  final DateTime sayimTarihi;
  final String kullaniciId;
  final String? kullaniciAdi;
  final String? gorevAdi;

  int get fark => sayilanMiktar - beklenenMiktar;

  bool get stokTamam => beklenenMiktar == 0 || beklenenMiktar == sayilanMiktar;

  bool get manuelSayim => beklenenMiktar == 0;

  SayimRaporu copyWith({
    String? id,
    String? gorevId,
    String? urunId,
    String? urunAdi,
    String? barkod,
    int? beklenenMiktar,
    int? sayilanMiktar,
    DateTime? sayimTarihi,
    String? kullaniciId,
    String? kullaniciAdi,
    String? gorevAdi,
  }) {
    return SayimRaporu(
      id: id ?? this.id,
      gorevId: gorevId ?? this.gorevId,
      urunId: urunId ?? this.urunId,
      urunAdi: urunAdi ?? this.urunAdi,
      barkod: barkod ?? this.barkod,
      beklenenMiktar: beklenenMiktar ?? this.beklenenMiktar,
      sayilanMiktar: sayilanMiktar ?? this.sayilanMiktar,
      sayimTarihi: sayimTarihi ?? this.sayimTarihi,
      kullaniciId: kullaniciId ?? this.kullaniciId,
      kullaniciAdi: kullaniciAdi ?? this.kullaniciAdi,
      gorevAdi: gorevAdi ?? this.gorevAdi,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'gorevId': gorevId,
        'urunId': urunId,
        'urunAdi': urunAdi,
        'barkod': barkod,
        'beklenenMiktar': beklenenMiktar,
        'sayilanMiktar': sayilanMiktar,
        'sayimTarihi': sayimTarihi.toIso8601String(),
        'kullaniciId': kullaniciId,
        'kullaniciAdi': kullaniciAdi,
        'gorevAdi': gorevAdi,
      };

  factory SayimRaporu.fromJson(Map<String, dynamic> json) => SayimRaporu(
        id: json['id'] as String,
        gorevId: json['gorevId'] as String,
        urunId: json['urunId'] as String,
        urunAdi: json['urunAdi'] as String,
        barkod: json['barkod'] as String,
        beklenenMiktar: json['beklenenMiktar'] as int,
        sayilanMiktar: json['sayilanMiktar'] as int,
        sayimTarihi: DateTime.parse(json['sayimTarihi'] as String),
        kullaniciId: json['kullaniciId'] as String,
        kullaniciAdi: json['kullaniciAdi'] as String?,
        gorevAdi: json['gorevAdi'] as String?,
      );
}
