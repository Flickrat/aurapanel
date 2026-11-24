import 'package:flutter/material.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_widgets.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

class LangScreen extends StatefulWidget {
  final AppState appState;
  final bool changingLanguage;

  const LangScreen({
    super.key,
    required this.appState,
    this.changingLanguage = false,
  });

  @override
  State<LangScreen> createState() => _LangScreenState();
}

class _LangScreenState extends State<LangScreen> {
  static const _codes = ['en', 'es', 'pt'];
  static const _flags = [
    'assets/images/icon_eng.webp',
    'assets/images/icon_es.webp',
    'assets/images/icon_br.webp',
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final idx = _codes.indexOf(widget.appState.languageCode);
    _selectedIndex = idx >= 0 ? idx : 0;
  }

  Future<void> _onContinue() async {
    await widget.appState.setLanguage(_codes[_selectedIndex]);
    if (!mounted) return;
    if (widget.changingLanguage) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => HomeScreen(appState: widget.appState),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (_) => false,
      );
    } else {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => OnboardingScreen(appState: widget.appState),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState.strings;
    final names = [s.english, s.spanish, s.portuguese];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              AuraIconTile(
                size: 46,
                padding: 11,
                radius: 10,
                child: const Icon(
                  Icons.language_rounded,
                  color: AppColors.greenPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                s.language.toUpperCase(),
                style: AppTextStyles.display(
                  20,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.06,
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.builder(
                  itemCount: _codes.length,
                  itemBuilder: (_, index) {
                    final selected = index == _selectedIndex;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected
                                ? AppColors.greenLine
                                : AppColors.cardBorder,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              _flags[index],
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                names[index],
                                style: AppTextStyles.body(
                                  15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (selected)
                              Container(
                                width: 22,
                                height: 22,
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.greenPrimary,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Image.asset(
                                  'assets/images/icon_check.webp',
                                  color: AppColors.onGreen,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AuraGreenButton(
                  height: 46,
                  onTap: _onContinue,
                  child: Text(
                    s.next.toUpperCase(),
                    style: AppTextStyles.display(
                      13.5,
                      color: AppColors.onGreen,
                      letterSpacing: 0.06,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
