import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_card.dart';
import '../../data/models/kullanici_model.dart';
import '../../data/repositories/hesap_repository.dart';

class ManagerHesapScreen extends StatefulWidget {
  const ManagerHesapScreen({super.key});

  @override
  State<ManagerHesapScreen> createState() => _ManagerHesapScreenState();
}

class _ManagerHesapScreenState extends State<ManagerHesapScreen> {
  final _repository = HesapRepository.instance;
  final _adController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sifreGoster = false;

  @override
  void dispose() {
    _adController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    super.dispose();
  }

  void _yenile() => setState(() {});

  Future<void> _hesapOlustur() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _repository.personelHesabiOlustur(
        adSoyad: _adController.text.trim(),
        email: _emailController.text.trim(),
        sifre: _sifreController.text,
      );

      _adController.clear();
      _emailController.clear();
      _sifreController.clear();
      _yenile();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Personel hesabı oluşturuldu'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on StateError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.rose600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _hesapSil(HesapKaydi hesap) async {
    final onay = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hesabı sil'),
        content: Text(
          '${hesap.adSoyad} (${hesap.email}) hesabını silmek istediğinize emin misiniz?',
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
    await _repository.personelHesabiSil(hesap.id);
    _yenile();
  }

  @override
  Widget build(BuildContext context) {
    final personeller = _repository.personelHesaplari;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Personel Hesapları')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.sageLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.sage.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline, color: AppColors.sage, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Personel kendi hesabını açamaz. Yalnızca siz bu cihazdan hesap oluşturabilirsiniz.',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('YENİ PERSONEL HESABI', style: AppTextStyles.labelSmall),
          const SizedBox(height: 12),
          AppCard(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _adController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Ad Soyad',
                      hintText: 'Örn: Ahmet Yılmaz',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Ad soyad gerekli' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'E-posta',
                      hintText: 'ahmet@sirket.com',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
                      if (!v.contains('@')) return 'Geçerli e-posta girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _sifreController,
                    obscureText: !_sifreGoster,
                    decoration: InputDecoration(
                      labelText: 'Şifre',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_sifreGoster
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined),
                        onPressed: () =>
                            setState(() => _sifreGoster = !_sifreGoster),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 4) {
                        return 'En az 4 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _hesapOlustur,
                      icon: const Icon(Icons.person_add_outlined, size: 18),
                      label: const Text('HESAP OLUŞTUR'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text('KAYITLI PERSONEL', style: AppTextStyles.labelSmall),
          const SizedBox(height: 12),
          if (personeller.isEmpty)
            AppCard(
              child: Text(
                'Henüz personel hesabı yok.',
                style: AppTextStyles.subtitle,
                textAlign: TextAlign.center,
              ),
            )
          else
            ...personeller.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                        child: Text(
                          h.adSoyad.isNotEmpty
                              ? h.adSoyad[0].toUpperCase()
                              : '?',
                          style: const TextStyle(color: AppColors.accentDark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(h.adSoyad, style: AppTextStyles.bodyBold),
                            Text(h.email,
                                style: AppTextStyles.subtitle
                                    .copyWith(fontSize: 12)),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _hesapSil(h),
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.rose600),
                        tooltip: 'Hesabı sil',
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
