import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_minds/features/personalization/controllers/theme_provider.dart';

class ChangeThemeScreen extends StatefulWidget {
  const ChangeThemeScreen({super.key});

  @override
  State<ChangeThemeScreen> createState() => _ChangeThemeScreenState();
}

class _ChangeThemeScreenState extends State<ChangeThemeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme; // ✅ Get text theme

    return Scaffold(
      appBar: AppBar(title: Text('Change Theme', style: theme.titleLarge)),
      body: SafeArea(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Column(

              children: [
                SwitchListTile(
                  title: Text('Enable Dark Theme', style: theme.bodyLarge),
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleTheme(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
