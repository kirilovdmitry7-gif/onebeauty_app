import 'package:flutter/material.dart';
import '../../l10n/gen/app_localizations.dart';

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Container(
      color: Colors.green.shade50, // 🌿 мягкий фон
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.spa, size: 56, color: Colors.green),
            const SizedBox(height: 12),
            Text(loc.studioMessage),
          ],
        ),
      ),
    );
  }
}
