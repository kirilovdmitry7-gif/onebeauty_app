import 'package:flutter/material.dart';
import '../../l10n/gen/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onFinish, super.key});
  final VoidCallback onFinish;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  void _next(int total) {
    if (_index < total - 1) {
      _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final pages = [
      _ObPage(icon: Icons.favorite, title: loc.obHealthTitle, text: loc.obHealthText),
      _ObPage(icon: Icons.spa,      title: loc.obStudioTitle, text: loc.obStudioText),
      _ObPage(icon: Icons.store,    title: loc.obStoreTitle,  text: loc.obStoreText),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: widget.onFinish,
                child: Text(loc.obSkip),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => pages[i],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: active ? 24 : 8,
                  decoration: BoxDecoration(
                    color: active ? Colors.purple : Colors.purple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _next(pages.length),
                  child: Text(_index == pages.length - 1 ? loc.obStart : loc.obNext),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObPage extends StatelessWidget {
  const _ObPage({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 96, color: Colors.purple),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
