import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/textile_background.dart';
import '../../data/repositories/hesap_repository.dart';
import '../../services/auth_service.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _hatirla = false;
  bool _isLoading = false;
  String? _hataMesaji;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _girisYap() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hataMesaji = null;
    });

    final email = _emailController.text.trim();
    final sifre = _passwordController.text;

    final kullanici = HesapRepository.instance.girisYap(email, sifre);

    if (kullanici == null) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hataMesaji =
            'E-posta veya şifre hatalı.\nYalnızca yönetici tarafından oluşturulan hesaplar giriş yapabilir.';
      });
      return;
    }

    await AuthService.instance.saveSession(kullanici, hatirla: _hatirla);

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DashboardScreen(kullanici: kullanici),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextileBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.06),
                        _buildHero(),
                        const SizedBox(height: 28),
                        Text(
                          'Yalnızca yetkili şirket personeli erişebilir.',
                          style: AppTextStyles.subtitle.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_hataMesaji != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.rose100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _hataMesaji!,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.rose600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Text('E-POSTA', style: AppTextStyles.labelSmall),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'E-posta gerekli';
                            }
                            return null;
                          },
                          decoration: const InputDecoration(
                            hintText: 'personel@sirket.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded,
                                color: AppColors.slate400),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('ŞİFRE', style: AppTextStyles.labelSmall),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _girisYap(),
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Şifre gerekli' : null,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: AppColors.slate400),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: AppColors.slate400,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        CheckboxListTile(
                          value: _hatirla,
                          onChanged: (v) =>
                              setState(() => _hatirla = v ?? false),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text('Beni hatırla',
                              style: AppTextStyles.bodyBold.copyWith(
                                fontSize: 14,
                              )),
                          subtitle: Text(
                            'Çıkış yapana kadar oturum açık kalır',
                            style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                          ),
                          activeColor: AppColors.accent,
                        ),
                        const SizedBox(height: 16),
                        _buildGirisButonu(),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '© ${DateTime.now().year} Efe Yusuf Karademir · Depo Sayım',
                  style: AppTextStyles.labelSmall.copyWith(
                    letterSpacing: 1.5,
                    color: AppColors.slate400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: AppColors.headerGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.texture_rounded,
                size: 32, color: AppColors.accentLight),
          ),
          const SizedBox(height: 20),
          Text(
            'Depo Sayım',
            style: AppTextStyles.headline.copyWith(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGirisButonu() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.accentGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        height: 54,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _girisYap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('GİRİŞ YAP'),
        ),
      ),
    );
  }
}
