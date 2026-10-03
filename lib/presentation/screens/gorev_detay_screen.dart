import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/kullanici_model.dart';
import '../../data/models/sayim_gorevi_model.dart';
import '../../data/models/sayim_raporu_model.dart';
import '../../data/repositories/sayim_repository.dart';
import 'counting_screen.dart';

class GorevDetayScreen extends StatefulWidget {
  const GorevDetayScreen({
    super.key,
    required this.gorevId,
    required this.kullanici,
  });

  final String gorevId;
  final Kullanici kullanici;

  @override
  State<GorevDetayScreen> createState() => _GorevDetayScreenState();
}

class _GorevDetayScreenState extends State<GorevDetayScreen> {
  final _repository = SayimRepository.instance;

  void _yenile() => setState(() {});

  SayimGorevi? get _gorev {
    final g = _repository.gorevBul(widget.gorevId);
    return g;
  }

  Future<void> _sayimBaslat() async {
    final gorev = _gorev;
    if (gorev == null) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CountingScreen(
          kullanici: widget.kullanici,
          gorev: gorev,
        ),
      ),
    );
    _yenile();
  }

  Future<void> _sayimiDuzenle(SayimRaporu rapor) async {
    final gorev = _gorev;
    if (gorev == null) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CountingScreen(
          kullanici: widget.kullanici,
          gorev: gorev,
          duzenlenecekRapor: rapor,
        ),
      ),
    );
    _yenile();
  }

  Future<void> _sayimiSil(SayimRaporu rapor) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sayımı sil'),
        content: Text(
          '"${rapor.urunAdi}" sayımını silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.rose600),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (onay != true) return;
    await _repository.raporSil(rapor.id);
    _yenile();
  }

  @override
  Widget build(BuildContext context) {
    final gorev = _gorev;
    if (gorev == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Blok bulunamadı')),
        body: const Center(child: Text('Bu blok artık mevcut değil.')),
      );
    }

    final raporlar = _repository.gorevRaporlari(gorev.id);
    final yonetici = widget.kullanici.yoneticiMi;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(gorev.baslik, style: AppTextStyles.bodyBold),
      ),
      floatingActionButton: yonetici
          ? null
          : FloatingActionButton.extended(
              onPressed: _sayimBaslat,
              icon: const Icon(Icons.add_rounded),
              label: const Text('SAYIM EKLE'),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('BLOK BİLGİSİ', style: AppTextStyles.labelSmall),
                const SizedBox(height: 8),
                Text('Oluşturan: ${gorev.olusturanAdi}',
                    style: AppTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(
                  '${raporlar.length} ürün sayıldı',
                  style: AppTextStyles.subtitle,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('SAYILAN ÜRÜNLER', style: AppTextStyles.labelSmall),
          const SizedBox(height: 12),
          if (raporlar.isEmpty)
            AppCard(
              child: Column(
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 48, color: AppColors.slate300),
                  const SizedBox(height: 12),
                  Text(
                    yonetici
                        ? 'Bu blokta henüz sayım yok.'
                        : 'Henüz sayım yok.\n"SAYIM EKLE" ile başlayın.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            )
          else
            ...raporlar.map(
              (r) => _buildSayimKarti(r, yonetici),
            ),
        ],
      ),
    );
  }

  Widget _buildSayimKarti(SayimRaporu rapor, bool yonetici) {
    final saat =
        '${rapor.sayimTarihi.day.toString().padLeft(2, '0')}.'
        '${rapor.sayimTarihi.month.toString().padLeft(2, '0')} '
        '${rapor.sayimTarihi.hour.toString().padLeft(2, '0')}:'
        '${rapor.sayimTarihi.minute.toString().padLeft(2, '0')}';

    final kendiSayimi = rapor.kullaniciId == widget.kullanici.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(rapor.urunAdi, style: AppTextStyles.bodyBold),
                ),
                Text(saat,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              rapor.kullaniciAdi ?? rapor.kullaniciId,
              style: AppTextStyles.subtitle.copyWith(fontSize: 12),
            ),
            if (rapor.barkod.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Barkod: ${rapor.barkod}',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 11)),
            ],
            const SizedBox(height: 8),
            Text('${rapor.sayilanMiktar} adet', style: AppTextStyles.monoBold),
            if (!yonetici && kendiSayimi) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _sayimiDuzenle(rapor),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('DÜZELT'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: const BorderSide(color: AppColors.accent),
                  ),
                ),
              ),
            ],
            if (yonetici) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _sayimiSil(rapor),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('SAYIMI SİL'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.rose600,
                    side: const BorderSide(color: AppColors.rose600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
