import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// TextEditingController dialog içinde yaşar — dispose çakışması olmaz.
class BlokOlusturDialog extends StatefulWidget {
  const BlokOlusturDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const BlokOlusturDialog(),
    );
  }

  @override
  State<BlokOlusturDialog> createState() => _BlokOlusturDialogState();
}

class _BlokOlusturDialogState extends State<BlokOlusturDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _olustur() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Yeni Blok Oluştur'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Örn: A Raf — İplik Deposu',
            labelText: 'Blok adı',
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Blok adı gerekli';
            return null;
          },
          onFieldSubmitted: (_) => _olustur(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _olustur,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
          child: const Text('Oluştur'),
        ),
      ],
    );
  }
}
