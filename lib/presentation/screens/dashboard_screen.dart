import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/textile_background.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/models/kullanici_model.dart';
import '../../data/models/personel_mesaji_model.dart';
import '../../data/models/sayim_gorevi_model.dart';
import '../../data/models/sayim_raporu_model.dart';
import '../../data/repositories/sayim_repository.dart';
import '../../services/auth_service.dart';
import '../../services/export_service.dart';
import 'counting_screen.dart';
import 'gorev_detay_screen.dart';
import 'login_screen.dart';
import 'manager_hesap_screen.dart';
import 'manager_mesaj_screen.dart';
import '../widgets/blok_olustur_dialog.dart';
import '../widgets/hedef_miktar_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.kullanici});

  final Kullanici kullanici;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repository = SayimRepository.instance;
  final _exportService = ExportService.instance;
  final GlobalKey _exportButtonKey = GlobalKey();
  bool _exporting = false;
  bool _blokYonetimiAcik = false;

  void _yenile() => setState(() {});

  Future<void> _cikisYap() async {
    await AuthService.instance.clearSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _profilAc(bool yonetici) {
    if (yonetici) {
      Navigator.of(context)
          .push<void>(
            MaterialPageRoute(
              builder: (_) => ManagerMesajScreen(kullanici: widget.kullanici),
            ),
          )
          .then((_) => _yenile());
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Profil', style: AppTextStyles.title),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: AppColors.slate200,
                child: Icon(Icons.person_outline, color: AppColors.slate600),
              ),
              title: Text(widget.kullanici.adSoyad),
              subtitle: Text(widget.kullanici.email),
            ),
            const Divider(),
            Text('YÖNETİCİ MESAJLARI', style: AppTextStyles.labelSmall),
            const SizedBox(height: 8),
            if (_repository.personelMesajlari.isEmpty)
              Text('Henüz mesaj yok.', style: AppTextStyles.subtitle)
            else
              ..._repository.personelMesajlari.take(3).map(
                    (m) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '• ${m.baslik}',
                        style: AppTextStyles.body,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _excelCiktisiAl() async {
    final raporlar = _repository.tamamlananRaporlar;

    if (raporlar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Dışa aktarılacak sayım raporu bulunamadı.'),
          backgroundColor: AppColors.rose600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
      return;
    }

    setState(() => _exporting = true);
    try {
      final result = await _exportService.exportToExcel(
        raporlar,
        sharePositionOrigin: _calculateShareOrigin(),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor:
              result.success ? AppColors.sage : AppColors.rose600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          action: result.success
              ? null
              : SnackBarAction(
                  label: 'Tamam',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
        ),
      );
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Rect _calculateShareOrigin() {
    final exportContext = _exportButtonKey.currentContext;
    final box = exportContext?.findRenderObject() as RenderBox?;

    if (box != null && box.hasSize && box.size.width > 0 && box.size.height > 0) {
      return box.localToGlobal(Offset.zero) & box.size;
    }

    final size = MediaQuery.of(context).size;
    final center = Offset(size.width / 2, size.height / 2);
    return Rect.fromCenter(center: center, width: 1, height: 1);
  }

  Future<void> _hedefMiktarBelirle(SayimRaporu rapor) async {
    final result = await HedefMiktarDialog.show(
      context,
      urunAdi: rapor.urunAdi,
      baslangicDegeri: rapor.beklenenMiktar,
    );

    if (result == null) return;

    await _repository.raporGuncelle(
      rapor.copyWith(
        beklenenMiktar: result,
        sayimTarihi: DateTime.now(),
      ),
    );
    _yenile();
  }

  Future<SayimGorevi?> _blokOlustur() async {
    final baslik = await BlokOlusturDialog.show(context);
    if (baslik == null || !mounted) return null;

    final gorev = await _repository.gorevOlustur(
      baslik: baslik,
      olusturanId: widget.kullanici.id,
      olusturanAdi: widget.kullanici.adSoyad,
    );
    _yenile();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$baslik" bloğu oluşturuldu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return gorev;
  }

  Future<void> _blokSecVeSayimBaslat() async {
    final gorevler = _repository.aktifGorevler;
    if (gorevler.isEmpty) {
      final yeni = await _blokOlustur();
      if (yeni == null || !mounted) return;
      await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => CountingScreen(
            kullanici: widget.kullanici,
            gorev: yeni,
          ),
        ),
      );
      _yenile();
      return;
    }

    final secilen = await showModalBottomSheet<SayimGorevi>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Hangi blokta sayım yapacaksınız?',
                style: AppTextStyles.title.copyWith(fontSize: 18)),
            const SizedBox(height: 20),
            ...gorevler.map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, g),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.accent),
                    foregroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(g.baslik, style: AppTextStyles.bodyBold),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _blokOlustur();
                });
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Yeni blok oluştur'),
            ),
          ],
        ),
      ),
    );

    if (secilen == null || !mounted) return;

    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CountingScreen(
          kullanici: widget.kullanici,
          gorev: secilen,
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
          '${rapor.kullaniciAdi ?? rapor.kullaniciId} — "${rapor.urunAdi}" silinsin mi?',
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

  Future<void> _blokSil(SayimGorevi gorev) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bloğu sil'),
        content: Text(
          '"${gorev.baslik}" bloğu ve bağlı tüm sayımlar silinsin mi?',
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

    await _repository.gorevSil(gorev.id);
    _yenile();
  }

  void _gorevDetayAc(SayimGorevi gorev) {
    Navigator.of(context)
        .push<void>(
          MaterialPageRoute(
            builder: (_) => GorevDetayScreen(
              gorevId: gorev.id,
              kullanici: widget.kullanici,
            ),
          ),
        )
        .then((_) => _yenile());
  }

  @override
  Widget build(BuildContext context) {
    final yonetici = widget.kullanici.yoneticiMi;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: TextileBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(yonetici),
              Expanded(
                child: yonetici ? _buildYoneticiView() : _buildCalisanView(),
              ),
              if (yonetici) _buildExportBar(),
            ],
          ),
        ),
      ),
      floatingActionButton: yonetici
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.45),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: FloatingActionButton.extended(
                  onPressed: _blokSecVeSayimBaslat,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('YENİ SAYIM BAŞLAT'),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(bool yonetici) {
    return Column(
      children: [
        TextileHeader(
          title: yonetici ? 'Yönetici Paneli' : 'Sayım Görevleri',
          subtitle: widget.kullanici.adSoyad,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeaderIconButton(
                icon: yonetici
                    ? Icons.campaign_outlined
                    : Icons.person_outline_rounded,
                tooltip: yonetici ? 'Personel Mesajları' : 'Profil & Mesajlar',
                onTap: () => _profilAc(yonetici),
              ),
              const SizedBox(width: 4),
              _HeaderIconButton(
                icon: Icons.logout_rounded,
                tooltip: 'Çıkış',
                onTap: _cikisYap,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalisanView() {
    final gorevler = _repository.aktifGorevler;
    final mesajlar = _repository.personelMesajlari;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
      children: [
        if (mesajlar.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withValues(alpha: 0.14),
                  AppColors.accentLight.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: AppColors.accentDark, size: 18),
                const SizedBox(width: 8),
                Text(
                  'YÖNETİCİDEN DUYURU MESAJLARI',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.accentDark,
                    letterSpacing: 0.9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...mesajlar.take(2).map(_buildMesajKarti),
          const SizedBox(height: 24),
        ],
        Text('BLOKLARIM', style: AppTextStyles.labelSmall),
        const SizedBox(height: 12),
        ...gorevler.map(_buildGorevKarti),
        if (gorevler.isEmpty)
          _buildEmptyState(
            icon: Icons.folder_open_outlined,
            mesaj: 'Henüz blok oluşturmadınız.\nİlk bloğunuzu oluşturun.',
          ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _blokOlustur,
          icon: const Icon(Icons.create_new_folder_outlined),
          label: const Text('YENİ BLOK OLUŞTUR'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: AppColors.accent,
            side: const BorderSide(color: AppColors.accent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMesajKarti(PersonelMesaji mesaj) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        accentBorder: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.notifications_active_outlined,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(mesaj.baslik, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 4),
                  Text(
                    mesaj.icerik,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    mesaj.yoneticiAdi,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accentDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGorevKarti(SayimGorevi gorev) {
    final sonSayimlar = _repository.gorevRaporlari(gorev.id);
    final sayimAdedi = sonSayimlar.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => _gorevDetayAc(gorev),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 0.15),
                        AppColors.accentLight.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.folder_special_outlined,
                    color: AppColors.accentDark,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(gorev.baslik, style: AppTextStyles.bodyBold),
                      Text(
                        'Oluşturan: ${gorev.olusturanAdi}',
                        style: AppTextStyles.subtitle.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.slate400),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.sageLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      size: 16, color: AppColors.sage),
                  const SizedBox(width: 8),
                  Text(
                    '$sayimAdedi ürün sayıldı',
                    style: AppTextStyles.bodyBold.copyWith(
                      fontSize: 13,
                      color: AppColors.sage,
                    ),
                  ),
                ],
              ),
            ),
            if (sonSayimlar.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              Text('Son sayılanlar', style: AppTextStyles.labelSmall),
              const SizedBox(height: 6),
              ...sonSayimlar.take(2).map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 14, color: AppColors.emerald600),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${r.urunAdi} — ${r.sayilanMiktar} adet',
                              style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              if (sonSayimlar.length > 2)
                Text(
                  '+${sonSayimlar.length - 2} ürün daha…',
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 11,
                    color: AppColors.accent,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildYoneticiView() {
    final raporlar = _repository.tamamlananRaporlar;
    final gorevler = _repository.aktifGorevler;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      children: [
        AppCard(
          accentBorder: true,
          onTap: () => Navigator.of(context).push<void>(
            MaterialPageRoute(builder: (_) => const ManagerHesapScreen()),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.manage_accounts_outlined,
                    color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Personel Hesapları',
                        style: AppTextStyles.bodyBold),
                    Text(
                      'Personel hesabı oluştur ve yönet',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.slate400),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          accentBorder: true,
          onTap: () => _profilAc(true),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.campaign_outlined, color: Colors.white),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Duyuru Mesajları',
                        style: AppTextStyles.bodyBold),
                    Text(
                      'Personellere duyuru ve talimat gönderin',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.slate400),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('BLOK YÖNETİMİ', style: AppTextStyles.labelSmall),
        const SizedBox(height: 12),
        AppCard(
          onTap: () => setState(() => _blokYonetimiAcik = !_blokYonetimiAcik),
          child: Row(
            children: [
              const Icon(Icons.settings_suggest_outlined, color: AppColors.accent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _blokYonetimiAcik
                      ? 'Blok yönetimini gizle'
                      : 'Blok yönetimini aç',
                  style: AppTextStyles.bodyBold,
                ),
              ),
              Icon(
                _blokYonetimiAcik
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: AppColors.slate500,
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Column(
              children: [
                if (gorevler.isEmpty)
                  _buildEmptyState(
                    icon: Icons.folder_open_outlined,
                    mesaj: 'Silinecek blok bulunamadı.',
                  )
                else
                  ...gorevler.map(_buildYoneticiBlokKarti),
              ],
            ),
          ),
          crossFadeState: _blokYonetimiAcik
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
        const SizedBox(height: 24),
        Text('SON TAMAMLANAN SAYIMLAR', style: AppTextStyles.labelSmall),
        const SizedBox(height: 12),
        if (raporlar.isEmpty)
          _buildEmptyState(
            icon: Icons.bar_chart_outlined,
            mesaj: 'Henüz tamamlanmış sayım raporu yok.',
          )
        else
          ...raporlar.map(_buildRaporKarti),
      ],
    );
  }

  Widget _buildRaporKarti(SayimRaporu rapor) {
    final saat =
        '${rapor.sayimTarihi.hour.toString().padLeft(2, '0')}:'
        '${rapor.sayimTarihi.minute.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => _hedefMiktarBelirle(rapor),
        padding: const EdgeInsets.all(16),
        borderRadius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  rapor.kullaniciAdi ?? rapor.kullaniciId,
                  style: AppTextStyles.bodyBold.copyWith(fontSize: 13),
                ),
                Text(
                  saat,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            if (rapor.gorevAdi != null) ...[
              const SizedBox(height: 4),
              Text(
                rapor.gorevAdi!,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 11,
                  color: AppColors.accent,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(rapor.urunAdi, style: AppTextStyles.body),
            const SizedBox(height: 4),
            Text(
              rapor.beklenenMiktar > 0
                  ? 'Hedef: ${rapor.beklenenMiktar} adet'
                  : 'Hedef henüz girilmedi (dokunarak belirleyin)',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 12,
                color: rapor.beklenenMiktar > 0 ? AppColors.slate600 : AppColors.rose600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (rapor.beklenenMiktar <= 0 || rapor.fark == 0)
                  StatusBadge(
                    durum: SayimDurumu.tamamlandi,
                  )
                else
                  const SizedBox.shrink(),
                Text(
                  '${rapor.sayilanMiktar} adet',
                  style: AppTextStyles.monoBold,
                ),
              ],
            ),
            if (rapor.beklenenMiktar > 0 && rapor.fark != 0) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.rose100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.rose600.withValues(alpha: 0.35)),
                ),
                child: Text(
                  rapor.fark < 0
                      ? 'EKSİK: ${rapor.fark.abs()} adet'
                      : 'FAZLA: ${rapor.fark} adet',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.rose600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
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
        ),
      ),
    );
  }

  Widget _buildYoneticiBlokKarti(SayimGorevi gorev) {
    final sayimAdedi = _repository.gorevSayimAdedi(gorev.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(gorev.baslik, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(
                    '$sayimAdedi sayım kaydı',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => _blokSil(gorev),
              icon: const Icon(Icons.delete_outline, size: 16),
              label: const Text('Sil'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.rose600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required IconData icon, required String mesaj}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(icon, size: 64, color: AppColors.slate300),
          const SizedBox(height: 16),
          Text(
            mesaj,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildExportBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.slate200)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SizedBox(
            height: 54,
            width: double.infinity,
            child: ElevatedButton.icon(
            key: _exportButtonKey,
              onPressed: _exporting ? null : _excelCiktisiAl,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                disabledBackgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.table_chart_rounded, size: 22),
              label: Text(_exporting ? 'HAZIRLANIYOR…' : 'EXCEL ÇIKTISI AL'),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}
