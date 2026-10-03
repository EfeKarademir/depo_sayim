import 'package:flutter/material.dart';

class HedefMiktarDialog extends StatefulWidget {
  const HedefMiktarDialog({
    super.key,
    required this.urunAdi,
    required this.baslangicDegeri,
  });

  final String urunAdi;
  final int baslangicDegeri;

  static Future<int?> show(
    BuildContext context, {
    required String urunAdi,
    required int baslangicDegeri,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => HedefMiktarDialog(
        urunAdi: urunAdi,
        baslangicDegeri: baslangicDegeri,
      ),
    );
  }

  @override
  State<HedefMiktarDialog> createState() => _HedefMiktarDialogState();
}

class _HedefMiktarDialogState extends State<HedefMiktarDialog> {
  late final TextEditingController _controller;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.baslangicDegeri > 0 ? widget.baslangicDegeri.toString() : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(int.parse(_controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.urunAdi} - Hedef Miktar'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Olması gereken miktar',
            hintText: 'Örn: 500',
          ),
          validator: (value) {
            final parsed = int.tryParse((value ?? '').trim());
            if (parsed == null || parsed < 0) {
              return 'Geçerli bir sayı girin';
            }
            return null;
          },
          onFieldSubmitted: (_) => _onSave(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
