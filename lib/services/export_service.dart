import 'dart:typed_data';
import 'dart:ui';

import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';

import '../data/models/sayim_raporu_model.dart';
import 'export_result.dart';

class ExportService {
  ExportService._();
  static final ExportService instance = ExportService._();

  Future<ExportResult> exportToExcel(
    List<SayimRaporu> raporlar, {
    Rect? sharePositionOrigin,
  }) async {
    if (raporlar.isEmpty) {
      return const ExportResult(
        success: false,
        message: 'Dışa aktarılacak sayım raporu bulunamadı.',
      );
    }

    try {
      final excel = Excel.createExcel();
      final defaultName = excel.getDefaultSheet()!;
      excel.rename(defaultName, 'Sayim Raporlari');
      final sheet = excel['Sayim Raporlari'];

      sheet.appendRow([
        TextCellValue('Blok'),
        TextCellValue('Ürün Adı'),
        TextCellValue('Barkod'),
        TextCellValue('Beklenen'),
        TextCellValue('Sayılan'),
        TextCellValue('Fark'),
        TextCellValue('Durum'),
        TextCellValue('Personel'),
        TextCellValue('Tarih'),
      ]);

      for (final rapor in raporlar) {
        final durum = rapor.manuelSayim
            ? 'Manuel'
            : (rapor.stokTamam ? 'Tamam' : 'Fark Var');

        sheet.appendRow([
          TextCellValue(rapor.gorevAdi ?? '-'),
          TextCellValue(rapor.urunAdi),
          TextCellValue(rapor.barkod.isEmpty ? '-' : rapor.barkod),
          IntCellValue(rapor.beklenenMiktar),
          IntCellValue(rapor.sayilanMiktar),
          IntCellValue(rapor.fark),
          TextCellValue(durum),
          TextCellValue(rapor.kullaniciAdi ?? rapor.kullaniciId),
          TextCellValue(_formatTarih(rapor.sayimTarihi)),
        ]);
      }

      final bytes = excel.save();
      if (bytes == null || bytes.isEmpty) {
        return const ExportResult(
          success: false,
          message: 'Excel dosyası oluşturulamadı.',
        );
      }

      final tarih = DateTime.now();
      final dosyaAdi =
          'depo_sayim_${tarih.year}${tarih.month.toString().padLeft(2, '0')}${tarih.day.toString().padLeft(2, '0')}_'
          '${tarih.hour.toString().padLeft(2, '0')}${tarih.minute.toString().padLeft(2, '0')}.xlsx';

      // Dosyayı diske yazmak yerine bellekten paylaş — macOS/iOS sandbox
      // geçici klasör hatalarını önler (PathNotFoundException).
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(bytes),
            name: dosyaAdi,
            mimeType:
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          ),
        ],
        subject: 'Depo Sayım Raporu',
        text: '${raporlar.length} kayıt — Excel dosyası',
        sharePositionOrigin: sharePositionOrigin,
      );

      return ExportResult(
        success: true,
        message: '${raporlar.length} kayıt Excel olarak hazırlandı.',
        filePath: dosyaAdi,
        recordCount: raporlar.length,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Dışa aktarma hatası: $e',
      );
    }
  }

  String _formatTarih(DateTime tarih) {
    return '${tarih.day.toString().padLeft(2, '0')}.'
        '${tarih.month.toString().padLeft(2, '0')}.'
        '${tarih.year} '
        '${tarih.hour.toString().padLeft(2, '0')}:'
        '${tarih.minute.toString().padLeft(2, '0')}';
  }
}
