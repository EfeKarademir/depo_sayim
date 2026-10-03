import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/models/kullanici_model.dart';
import '../../data/models/sayim_gorevi_model.dart';
import '../../data/models/sayim_raporu_model.dart';
import '../../data/repositories/sayim_repository.dart';

class CountingScreen extends StatefulWidget {
  const CountingScreen({
    super.key,
    required this.kullanici,
    required this.gorev,
    this.duzenlenecekRapor,
  });

  final Kullanici kullanici;
  final SayimGorevi gorev;
  final SayimRaporu? duzenlenecekRapor;

  bool get duzenlemeModu => duzenlenecekRapor != null;

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  final _barkodController = TextEditingController();
  final _urunAdiController = TextEditingController();
  final _quantityController = TextEditingController(text: '0');
  final _repository = SayimRepository.instance;

  int _sayilanMiktar = 0;
  bool _sayimModu = false;

  @override
  void initState() {
    super.initState();
    final rapor = widget.duzenlenecekRapor;
    if (rapor != null) {
      _urunAdiController.text = rapor.urunAdi;
      _barkodController.text = rapor.barkod;
      _sayilanMiktar = rapor.sayilanMiktar;
      _quantityController.text = rapor.sayilanMiktar.toString();
      _sayimModu = true;
    }
  }

  @override
  void dispose() {
    _barkodController.dispose();
    _urunAdiController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  String get _urunAdi => _urunAdiController.text.trim();
  bool get _urunHazir => _urunAdi.isNotEmpty;

  void _haptic() => HapticFeedback.lightImpact();

  void _artir() {
    _haptic();
    setState(() {
      _sayilanMiktar++;
      _quantityController.text = _sayilanMiktar.toString();
    });
  }

  void _azalt() {
    _haptic();
    if (_sayilanMiktar <= 0) return;
    setState(() {
      _sayilanMiktar--;
      _quantityController.text = _sayilanMiktar.toString();
    });
  }

  void _miktarGuncelle(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed >= 0) {
      setState(() => _sayilanMiktar = parsed);
    }
  }

  void _sayimaGec() {
    if (!_urunHazir) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Önce sayacağınız ürünün adını girin'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _sayimModu = true);
  }

  Future<void> _sayimiTamamla() async {
    if (!_urunHazir) return;

    if (widget.duzenlemeModu) {
      final guncel = widget.duzenlenecekRapor!.copyWith(
        urunAdi: _urunAdi,
        barkod: _barkodController.text.trim(),
        sayilanMiktar: _sayilanMiktar,
        sayimTarihi: DateTime.now(),
      );
      await _repository.raporGuncelle(guncel);
    } else {
      final rapor = SayimRaporu(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        gorevId: widget.gorev.id,
        gorevAdi: widget.gorev.baslik,
        urunId: 'manuel-${DateTime.now().millisecondsSinceEpoch}',
        urunAdi: _urunAdi,
        barkod: _barkodController.text.trim(),
        beklenenMiktar: 0,
        sayilanMiktar: _sayilanMiktar,
        sayimTarihi: DateTime.now(),
        kullaniciId: widget.kullanici.id,
        kullaniciAdi: widget.kullanici.adSoyad,
      );
      await _repository.raporEkle(rapor);
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.duzenlemeModu
              ? 'Sayım güncellendi: $_sayilanMiktar adet'
              : '${widget.gorev.baslik}: "$_urunAdi" kaydedildi',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          _buildDarkAppBar(context),
          if (!_sayimModu)
            Expanded(child: _buildUrunGirisAlani())
          else
            Expanded(child: _buildSayimAlani()),
        ],
      ),
    );
  }

  Widget _buildDarkAppBar(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.darkBar,
      padding: EdgeInsets.fromLTRB(8, topPadding + 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (_sayimModu && !widget.duzenlemeModu) {
                    setState(() => _sayimModu = false);
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 20),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.duzenlemeModu ? 'Sayımı Düzelt' : widget.gorev.baslik,
                      style: AppTextStyles.bodyBold.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.kullanici.adSoyad,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUrunGirisAlani() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('SAYILACAK ÜRÜN', style: AppTextStyles.labelSmall),
          const SizedBox(height: 8),
          Text(
            'Ürün adını yazın. İsteğe bağlı barkod da ekleyebilirsiniz.',
            style: AppTextStyles.subtitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _urunAdiController,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
            decoration: const InputDecoration(
              hintText: 'Örn: Pamuklu Kumaş Rulo #A-45',
              prefixIcon: Icon(Icons.inventory_2_outlined),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _barkodController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              hintText: 'Barkod (isteğe bağlı)',
              prefixIcon: Icon(Icons.qr_code_rounded),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _urunHazir ? _sayimaGec : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('SAYIMA GEÇ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSayimAlani() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: AppColors.slate100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SAYILAN ÜRÜN', style: AppTextStyles.labelSmall),
              const SizedBox(height: 4),
              Text(_urunAdi, style: AppTextStyles.bodyBold),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(child: _buildArtirButonu()),
                _buildMiktarAlani(),
                Expanded(child: _buildAzaltButonu()),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _sayimiTamamla,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.emerald500,
                foregroundColor: Colors.white,
              ),
              child: Text(
                  widget.duzenlemeModu ? 'DÜZELTMEYİ KAYDET' : 'SAYIMI TAMAMLA'),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _buildArtirButonu() {
    return Material(
      color: AppColors.accent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _artir,
        borderRadius: BorderRadius.circular(24),
        child: const Center(
          child: Text('+',
              style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  height: 1)),
        ),
      ),
    );
  }

  Widget _buildAzaltButonu() {
    return Material(
      color: AppColors.slate100,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _azalt,
        borderRadius: BorderRadius.circular(24),
        child: const Center(
          child: Text('−',
              style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: AppColors.primary,
                  height: 1)),
        ),
      ),
    );
  }

  Widget _buildMiktarAlani() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Text('ADET',
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.accent)),
          SizedBox(
            width: 180,
            child: TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: AppTextStyles.countInput,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _miktarGuncelle,
              decoration: const InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 4),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accent, width: 4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
