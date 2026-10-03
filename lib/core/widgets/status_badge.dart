import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum SayimDurumu { tamamlandi, hata }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.durum,
    this.farkMiktari,
  });

  final SayimDurumu durum;
  final int? farkMiktari;

  @override
  Widget build(BuildContext context) {
    final isHata = durum == SayimDurumu.hata;
    final label = isHata ? _hataLabel() : 'TAMAMLANDI';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isHata ? AppColors.rose100 : AppColors.sageLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHata
              ? AppColors.rose600.withValues(alpha: 0.2)
              : AppColors.sage.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: isHata ? AppColors.rose600 : AppColors.sage,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  String _hataLabel() {
    if (farkMiktari == null) return 'HATA';
    if (farkMiktari == 0) return 'TAMAMLANDI';
    if (farkMiktari! < 0) return 'EKSİK: ${farkMiktari!.abs()} ADET';
    return 'FAZLA: ${farkMiktari!} ADET';
  }
}
