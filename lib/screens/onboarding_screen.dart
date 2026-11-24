import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import '../dialogs/reward_prompt_dialog.dart';
import '../services/ad_service.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_widgets.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final AppState appState;

  const OnboardingScreen({super.key, required this.appState});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  NativeAd? _nativeAd;
  bool _nativeLoaded = false;

  @override
  void initState() {
    super.initState();
    _nativeAd = AdService.instance.createNativeAd(
      onLoaded: () {
        if (mounted) setState(() => _nativeLoaded = true);
      },
      onFailed: () {
        if (mounted) setState(() => _nativeLoaded = false);
      },
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await widget.appState.setFirstLaunchCompleted();
    if (!mounted) return;
    AdService.instance.showInterstitialThen(() {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, _, _) => HomeScreen(appState: widget.appState),
          transitionsBuilder: (_, anim, _, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 260),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState.strings;
    final slides = [
      ('assets/images/icon_settings.webp', s.title1, s.description1),
      ('assets/images/icon_stats.webp', s.title3, s.description3),
    ];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, index) {
                  final slide = slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.greenSoft,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.greenLine,
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            slide.$1,
                            color: AppColors.greenPrimary,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 26),
                        Text(
                          slide.$2,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.display(
                            19,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.$3,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(
                            13.5,
                            color: AppColors.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: active ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.greenPrimary : AppColors.switchOff,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 22),
            // Navigation row
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Row(
                children: [
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: _currentPage == 0,
                      child: AuraIconButton(
                        size: 42,
                        padding: 10,
                        onTap: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                          );
                        },
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.textPrimary,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 118),
                    child: AuraGreenButton(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      onTap: () {
                        if (_currentPage < slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      child: Text(
                        (_currentPage == slides.length - 1 ? s.finish : s.next)
                            .toUpperCase(),
                        style: AppTextStyles.display(
                          12.5,
                          color: AppColors.onGreen,
                          letterSpacing: 0.06,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Native Ad on slide 2 (matches OnboardingScreen.java)
            if (_currentPage == 1 && !widget.appState.isPro)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
                child: AuraNativeAdCard(
                  loaded: _nativeLoaded,
                  adWidget:
                      _nativeAd != null ? AdWidget(ad: _nativeAd!) : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
