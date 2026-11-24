import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import '../services/app_state.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'lang_screen.dart';
import 'onboarding_screen.dart';

class LaunchScreen extends StatefulWidget {
  final AppState appState;

  const LaunchScreen({super.key, required this.appState});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoIntroCtrl;
  late final AnimationController _logoIdleCtrl;
  late final AnimationController _textIntroCtrl;
  late final AnimationController _barPulseCtrl;
  bool _showBar = false;
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    _logoIntroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoIdleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _textIntroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _barPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
      lowerBound: 0.4,
      upperBound: 1.0,
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    _logoIntroCtrl.forward().then((_) {
      if (mounted) _logoIdleCtrl.repeat(reverse: true);
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textIntroCtrl.forward();
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _showBar = true);
        _barPulseCtrl.repeat(reverse: true);
      }
    });

    _navTimer = Timer(const Duration(milliseconds: 2200), () {
      AdService.instance.showAppOpenThen(_navigateNext);
    });
  }

  void _navigateNext() {
    if (!mounted) return;
    final state = widget.appState;
    Widget target;
    if (state.isFirstLaunch) {
      if (!state.hasSelectedLanguage) {
        target = LangScreen(appState: state, changingLanguage: false);
      } else {
        target = OnboardingScreen(appState: state);
      }
    } else {
      target = HomeScreen(appState: state);
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => target,
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _logoIntroCtrl.dispose();
    _logoIdleCtrl.dispose();
    _textIntroCtrl.dispose();
    _barPulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.appState.strings;
    final logoScale = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _logoIntroCtrl, curve: Curves.decelerate),
    );
    final textSlide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textIntroCtrl, curve: Curves.decelerate),
    );

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Outer neon ring (`bg_logo_ring.xml`)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(42),
                  border: Border.all(color: AppColors.greenLine, width: 1),
                ),
                child: AnimatedBuilder(
                  animation: Listenable.merge([_logoIntroCtrl, _logoIdleCtrl]),
                  builder: (_, child) {
                    final idle = 1.0 + (0.02 * _logoIdleCtrl.value);
                    return Opacity(
                      opacity: _logoIntroCtrl.value,
                      child: Transform.scale(
                        scale: logoScale.value * idle,
                        child: child,
                      ),
                    );
                  },
                  child: Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      color: AppColors.cardBgElevated,
                      borderRadius: BorderRadius.circular(34),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FadeTransition(
                opacity: _textIntroCtrl,
                child: SlideTransition(
                  position: textSlide,
                  child: Column(
                    children: [
                      Text(
                        s.brandSub.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display(
                          22,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.1,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        s.brandTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.display(
                          11.5,
                          color: AppColors.greenPrimary,
                          letterSpacing: 0.42,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              AnimatedOpacity(
                opacity: _showBar ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: FadeTransition(
                  opacity: _barPulseCtrl,
                  child: Container(
                    width: 68,
                    height: 3.5,
                    decoration: BoxDecoration(
                      color: AppColors.greenPrimary,
                      borderRadius: BorderRadius.circular(2),
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
