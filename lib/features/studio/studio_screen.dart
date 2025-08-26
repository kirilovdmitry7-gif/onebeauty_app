import 'package:flutter/material.dart';
import '../../l10n/gen/app_localizations.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      color: Colors.blue.shade50, // 🛒 мягкий фон
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.store, size: 56, color: Colors.blue),
            const SizedBox(height: 12),
            Text(loc.storeMessage),
          ],
        ),
      ),
    );
  }
}
