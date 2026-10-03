import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_theme.dart';
import 'data/models/kullanici_model.dart';
import 'data/repositories/hesap_repository.dart';
import 'data/repositories/sayim_repository.dart';
import 'presentation/screens/dashboard_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await HesapRepository.instance.init();
  await SayimRepository.instance.init();

  runApp(const DepoSayimApp());
}

class DepoSayimApp extends StatelessWidget {
  const DepoSayimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Depo Sayım',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Kullanici? _kullanici;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _oturumuKontrolEt();
  }

  Future<void> _oturumuKontrolEt() async {
    final saved = await AuthService.instance.getSavedSession();
    if (!mounted) return;
    setState(() {
      _kullanici = saved;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_kullanici != null) {
      return DashboardScreen(kullanici: _kullanici!);
    }

    return const LoginScreen();
  }
}
