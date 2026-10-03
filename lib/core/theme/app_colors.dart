import 'package:flutter/material.dart';

/// Tekstil firması için sıcak, ferah renk paleti.
abstract final class AppColors {
  // Zemin — keten / krem tonları
  static const Color background = Color(0xFFFAF6F0);
  static const Color backgroundAlt = Color(0xFFF3EDE4);
  static const Color surface = Color(0xFFFFFDF9);
  static const Color surfaceWarm = Color(0xFFF8F2EA);

  // Ana marka — derin lacivert (kumaş mürekkebi)
  static const Color primary = Color(0xFF1E2A3A);
  static const Color primaryLight = Color(0xFF2D3E52);

  // Vurgu — bakır / terracotta (iplik & dokuma)
  static const Color accent = Color(0xFFB8845A);
  static const Color accentLight = Color(0xFFD4A574);
  static const Color accentDark = Color(0xFF9A6B42);

  // İkincil — adaçayı yeşili
  static const Color sage = Color(0xFF6B8F71);
  static const Color sageLight = Color(0xFFE8F0E9);

  // Nötr tonlar
  static const Color slate100 = Color(0xFFF5F0E8);
  static const Color slate200 = Color(0xFFE8DFD3);
  static const Color slate300 = Color(0xFFD4C9BA);
  static const Color slate400 = Color(0xFFA89888);
  static const Color slate500 = Color(0xFF7A6E62);
  static const Color slate600 = Color(0xFF5C524A);
  static const Color slate700 = Color(0xFF443D37);
  static const Color slate800 = Color(0xFF2E2924);
  static const Color slate900 = primary;

  // Durum
  static const Color emerald100 = sageLight;
  static const Color emerald600 = sage;
  static const Color emerald500 = Color(0xFF5A9A62);
  static const Color rose100 = Color(0xFFFAE8E6);
  static const Color rose600 = Color(0xFFC45C52);

  // Eski isimlerle uyumluluk
  static const Color indigo500 = accentLight;
  static const Color indigo600 = accent;
  static const Color indigo700 = accentDark;

  // Sayım ekranı
  static const Color darkBar = primary;
  static const Color darkBarInput = primaryLight;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, Color(0xFF2A3848), Color(0xFF3D4F5F)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentDark, accent, accentLight],
  );

  static const LinearGradient warmBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundAlt],
  );
}
