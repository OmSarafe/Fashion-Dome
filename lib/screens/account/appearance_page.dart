import 'package:ecommerence_project/providers/theme_provider.dart';
import 'package:ecommerence_project/utils/responsive_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedMode = context.watch<ThemeProvider>().themeMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Appearance')),
      body: ResponsiveContent(
        maxWidth: 760,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 28),
          children: [
            Text(
              'Choose theme',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'System follows the light or dark setting on your device.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  _ThemeOption(
                    icon: Icons.brightness_auto_outlined,
                    title: 'System default',
                    mode: ThemeMode.system,
                    groupValue: selectedMode,
                  ),
                  const Divider(),
                  _ThemeOption(
                    icon: Icons.light_mode_outlined,
                    title: 'Light',
                    mode: ThemeMode.light,
                    groupValue: selectedMode,
                  ),
                  const Divider(),
                  _ThemeOption(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark',
                    mode: ThemeMode.dark,
                    groupValue: selectedMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.mode,
    required this.groupValue,
  });

  final IconData icon;
  final String title;
  final ThemeMode mode;
  final ThemeMode groupValue;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<ThemeMode>(
      secondary: Icon(icon),
      title: Text(title),
      value: mode,
      groupValue: groupValue,
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: (value) {
        if (value != null) {
          context.read<ThemeProvider>().setThemeMode(value);
        }
      },
    );
  }
}
