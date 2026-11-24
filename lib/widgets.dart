import 'package:flutter/material.dart';

import 'theme.dart';

/// Kartu putih berbingkai tipis, gaya dashboard Claude.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: C.card,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: C.border),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, this.color = C.muted, this.bg = C.surface});

  final String text;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

IconData iconFor(String kategori) {
  switch (kategori) {
    case 'Alat Tulis':
      return Icons.edit_outlined;
    case 'Kertas & Cetak':
      return Icons.description_outlined;
    case 'Elektronik':
      return Icons.devices_other_outlined;
    case 'Furnitur':
      return Icons.chair_alt_outlined;
    case 'Kebersihan':
      return Icons.cleaning_services_outlined;
    case 'Konsumsi':
      return Icons.local_cafe_outlined;
    default:
      return Icons.inventory_2_outlined;
  }
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String yes = 'Hapus',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: C.card,
      surfaceTintColor: Colors.transparent,
      title: Text(title, style: serif(20)),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(
            backgroundColor: C.danger,
            minimumSize: const Size(0, 40),
          ),
          child: Text(yes),
        ),
      ],
    ),
  );
  return r ?? false;
}
