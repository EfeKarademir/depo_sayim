import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/kullanici_model.dart';
import '../../data/models/personel_mesaji_model.dart';
import '../../data/repositories/sayim_repository.dart';

class ManagerMesajScreen extends StatefulWidget {
  const ManagerMesajScreen({super.key, required this.kullanici});

  final Kullanici kullanici;

  @override
  State<ManagerMesajScreen> createState() => _ManagerMesajScreenState();
}

class _ManagerMesajScreenState extends State<ManagerMesajScreen> {
  final _repository = SayimRepository.instance;
  final _baslikController = TextEditingController();
  final _icerikController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _baslikController.dispose();
    _icerikController.dispose();
    super.dispose();
  }

  Future<void> _mesajGonder() async {
    if (!_formKey.currentState!.validate()) return;

    await _repository.mesajEkle(
      PersonelMesaji(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        baslik: _baslikController.text.trim(),
        icerik: _icerikController.text.trim(),
        tarih: DateTime.now(),
        yoneticiAdi: widget.kullanici.adSoyad,
      ),
    );

    if (!mounted) return;

    _baslikController.clear();
    _icerikController.clear();
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Mesaj personellere iletildi'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _mesajSil(PersonelMesaji mesaj) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Duyuruyu sil'),
        content: Text('"${mesaj.baslik}" duyurusunu silmek istiyor musunuz?'),
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

    await _repository.mesajSil(mesaj.id);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duyuru silindi'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mesajlar = _repository.personelMesajlari;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Personel Mesajları'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('YENİ MESAJ GÖNDER', style: AppTextStyles.labelSmall),
          const SizedBox(height: 12),
          AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _baslikController,
                    decoration: const InputDecoration(
                      labelText: 'Başlık',
                      hintText: 'Örn: Haftalık sayım hatırlatması',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Başlık gerekli' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _icerikController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Mesaj',
                      hintText: 'Personellere iletilecek metin…',
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Mesaj gerekli' : null,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _mesajGonder,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('GÖNDER'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('GÖNDERİLEN MESAJLAR', style: AppTextStyles.labelSmall),
          const SizedBox(height: 12),
          if (mesajlar.isEmpty)
            AppCard(
              child: Text(
                'Henüz mesaj gönderilmedi.',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
            )
          else
            ...mesajlar.map(_buildMesajKarti),
        ],
      ),
    );
  }

  Widget _buildMesajKarti(PersonelMesaji mesaj) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(mesaj.baslik, style: AppTextStyles.bodyBold)),
                IconButton(
                  onPressed: () => _mesajSil(mesaj),
                  icon: const Icon(Icons.delete_outline, color: AppColors.rose600),
                  tooltip: 'Duyuruyu sil',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(mesaj.icerik, style: AppTextStyles.body),
            const SizedBox(height: 8),
            Text(
              '${mesaj.yoneticiAdi} · ${_formatTarih(mesaj.tarih)}',
              style: AppTextStyles.subtitle.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTarih(DateTime tarih) {
    return '${tarih.day.toString().padLeft(2, '0')}.'
        '${tarih.month.toString().padLeft(2, '0')}.'
        '${tarih.year} '
        '${tarih.hour.toString().padLeft(2, '0')}:'
        '${tarih.minute.toString().padLeft(2, '0')}';
  }
}
