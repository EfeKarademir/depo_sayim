class Urun {
  const Urun({
    required this.id,
    required this.barkod,
    required this.urunAdi,
    required this.beklenenMiktar,
    this.gorevId,
  });

  final String id;
  final String barkod;
  final String urunAdi;
  final int beklenenMiktar;
  final String? gorevId;

  Urun copyWith({
    String? id,
    String? barkod,
    String? urunAdi,
    int? beklenenMiktar,
    String? gorevId,
  }) {
    return Urun(
      id: id ?? this.id,
      barkod: barkod ?? this.barkod,
      urunAdi: urunAdi ?? this.urunAdi,
      beklenenMiktar: beklenenMiktar ?? this.beklenenMiktar,
      gorevId: gorevId ?? this.gorevId,
    );
  }
}
