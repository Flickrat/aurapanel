import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import '../dialogs/premium_dialog.dart';
import '../dialogs/reward_prompt_dialog.dart';
import '../l10n/app_strings.dart';
import '../services/ad_service.dart';
import '../services/app_state.dart';
import '../services/device_service.dart';
import '../services/review_service.dart';
import '../theme/app_colors.dart';
import '../widgets/aura_widgets.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _mobileBrands = [
    'Asus (ROG Republic Gamers)',
    'Nubia (RedMagic)',
    'Samsung',
    'iQOO (Vivo)',
    'POCO (Xiaomi)',
    'Infinix',
    'Oppo',
    'Vivo',
    'Xiaomi',
    'Realme',
    'OnePlus',
    'Motorola',
    'Honor',
    'Huawei',
    'Tecno',
    'Sony (Xperia)',
  ];

  static const List<String> _emulators = [
    'SMARTGAGA',
    'BLUESTACKS',
    'MSI PLAYER',
    'GAMELOOP',
    'MEMU PLAYER',
    'LD PLAYER',
  ];

  static const List<String> _youtubers = [
    'WHITE444',
    'WHITEFF',
    'RUOKFF',
    'RAISTAR',
    'Chirasak',
    'Piyapon',
    'TiagoFF',
  ];

  final math.Random _random = math.Random();

  // Panel master lock state (matches HomeScreen.java default: false -> PANEL OFF)
  bool _isUnlocked = false;

  // Sensi selector state
  int _deviceTypeIndex = 0; // 0: Phone, 1: Emulator, 2: YouTubers
  int _mobileBrandIndex = 0;
  int _emulatorIndex = 0;
  int _youtuberIndex = 0;

  // Generated sensitivity values
  int? _generalVal;
  int? _redDotVal;
  int? _x2Val;
  int? _x4Val;
  int? _awmVal;
  int? _dpiVal;
  int? _fireBtnVal;

  // Card switch states
  bool _swSensi = true;
  bool _swDpi = false;
  bool _swFps = false;
  bool _swHz = false;
  bool _swPing = false;
  bool _swBtemp = false;
  bool _swDevice = false;
  bool _swCpu = false;
  bool _swRam = false;
  bool _swStorage = false;
  bool _swDisplay = false;
  bool _swBattery = false;

  // Live monitors
  FpsMonitor? _fpsMonitor;
  PingMonitor? _pingMonitor;
  Timer? _infoTimer;

  int _liveFps = 60;
  int _livePing = 20;
  DeviceSnapshot _snapshot = DeviceSnapshot.fallback();

  NativeAd? _nativeAd;
  bool _nativeLoaded = false;

  @override
  void initState() {
    super.initState();
    _fpsMonitor = FpsMonitor(
      onUpdate: (fps) {
        if (mounted) setState(() => _liveFps = fps);
      },
    );
    _pingMonitor = PingMonitor(
      onUpdate: (ping) {
        if (mounted) setState(() => _livePing = ping);
      },
    );
    _refreshDeviceInfo();
    _infoTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshDeviceInfo(),
    );
    _nativeAd = AdService.instance.createNativeAd(
      onLoaded: () {
        if (mounted) setState(() => _nativeLoaded = true);
      },
      onFailed: () {
        if (mounted) setState(() => _nativeLoaded = false);
      },
    );
    ReviewService.instance.trackLaunchAndMaybeRequestReview();
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    _infoTimer?.cancel();
    _fpsMonitor?.stop();
    _pingMonitor?.stop();
    super.dispose();
  }

  Future<void> _refreshDeviceInfo() async {
    final snap = await DeviceService.getDeviceSnapshot();
    if (mounted) {
      setState(() => _snapshot = snap);
    }
  }

  int _randRange(int min, int max) => _random.nextInt(max - min + 1) + min;

  void _generateSensi() {
    if (!AdService.instance.adsEnabled) {
      _applyRandomSensi();
      return;
    }
    _runRewardGated(_applyRandomSensi);
  }

  void _applyRandomSensi() {
    setState(() {
      _generalVal = _randRange(50, 200);
      _redDotVal = _randRange(50, 200);
      _x2Val = _randRange(50, 200);
      _x4Val = _randRange(50, 200);
      _awmVal = _randRange(50, 200);
      _dpiVal = _randRange(350, 1200);
      _fireBtnVal = _randRange(30, 60);
    });
  }

  Future<void> _runRewardGated(VoidCallback onUnlocked) async {
    final s = widget.appState.strings;
    final confirmed = await RewardPromptDialog.show(context, s);
    if (!confirmed || !mounted) return;

    await AdService.instance.showRewarded(
      onRewarded: () {
        if (!mounted) return;
        onUnlocked();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.featureUnlocked,
              style: AppTextStyles.body(12, color: AppColors.onGreen),
            ),
            backgroundColor: AppColors.greenPrimary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onFailed: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              s.noAdsAvailable,
              style: AppTextStyles.body(12, color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.cardBgElevated,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _togglePanelCard(
    bool newValue, {
    required bool rewardGated,
    required ValueChanged<bool> setter,
  }) {
    if (!newValue) {
      setState(() => setter(false));
      return;
    }
    if (!AdService.instance.adsEnabled) {
      setState(() => setter(true));
      return;
    }
    if (rewardGated) {
      _runRewardGated(() => setState(() => setter(true)));
    } else {
      AdService.instance.showInterstitialThen(() {
        if (mounted) setState(() => setter(true));
      });
    }
  }

  List<String> get _currentList {
    switch (_deviceTypeIndex) {
      case 1:
        return _emulators;
      case 2:
        return _youtubers;
      default:
        return _mobileBrands;
    }
  }

  int get _currentItemIndex {
    switch (_deviceTypeIndex) {
      case 1:
        return _emulatorIndex;
      case 2:
        return _youtuberIndex;
      default:
        return _mobileBrandIndex;
    }
  }

  void _swapLeft() {
    setState(() {
      if (_deviceTypeIndex == 0) {
        _mobileBrandIndex =
            (_mobileBrandIndex - 1 + _mobileBrands.length) % _mobileBrands.length;
      } else if (_deviceTypeIndex == 1) {
        _emulatorIndex =
            (_emulatorIndex - 1 + _emulators.length) % _emulators.length;
      } else {
        _youtuberIndex =
            (_youtuberIndex - 1 + _youtubers.length) % _youtubers.length;
      }
    });
  }

  void _swapRight() {
    setState(() {
      if (_deviceTypeIndex == 0) {
        _mobileBrandIndex = (_mobileBrandIndex + 1) % _mobileBrands.length;
      } else if (_deviceTypeIndex == 1) {
        _emulatorIndex = (_emulatorIndex + 1) % _emulators.length;
      } else {
        _youtuberIndex = (_youtuberIndex + 1) % _youtubers.length;
      }
    });
  }

  Future<void> _toggleProStat(
    bool newValue,
    VoidCallback applyOn,
    VoidCallback applyOff,
  ) async {
    if (newValue && !widget.appState.isPro) {
      final unlocked = await PremiumDialog.show(context, widget.appState);
      if (unlocked == true && mounted) {
        setState(applyOn);
      }
      return;
    }
    setState(newValue ? applyOn : applyOff);
  }

  String _batteryStatusLabel(AppStrings s, int status) {
    switch (status) {
      case 2:
        return s.batteryCharging;
      case 3:
        return s.batteryDischarging;
      case 4:
        return s.batteryNotCharging;
      case 5:
        return s.batteryFull;
      default:
        return s.infoUnknown;
    }
  }

  String _batteryHealthLabel(AppStrings s, int health) {
    switch (health) {
      case 2:
        return s.batteryGood;
      case 3:
        return s.batteryOverheat;
      case 4:
        return s.batteryDead;
      case 7:
        return s.batteryCold;
      default:
        return s.infoUnknown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final s = widget.appState.strings;
        final mq = MediaQuery.of(context);
        final resW = (mq.size.width * mq.devicePixelRatio).round();
        final resH = (mq.size.height * mq.devicePixelRatio).round();
        final dpi = (mq.devicePixelRatio * 160).round();
        final inches = DeviceService.estimateScreenInches(context);

        final ramUsed =
            math.max(0, _snapshot.ramTotalBytes - _snapshot.ramAvailBytes);
        final ramRatio = _snapshot.ramTotalBytes > 0
            ? ramUsed / _snapshot.ramTotalBytes
            : 0.0;

        final storageUsed = math.max(
          0,
          _snapshot.storageTotalBytes - _snapshot.storageAvailBytes,
        );
        final storageRatio = _snapshot.storageTotalBytes > 0
            ? storageUsed / _snapshot.storageTotalBytes
            : 0.0;

        final lockAlpha = _isUnlocked ? 1.0 : 0.3;

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: Column(
              children: [
                // Top Header Bar
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.cardBgElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.brandTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.display(
                                13.5,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.08,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              s.brandSub,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.body(
                                10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // PANEL OFF / ON Pill Toggle
                      GestureDetector(
                        onTap: () => setState(() => _isUnlocked = !_isUnlocked),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 36,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _isUnlocked
                                ? AppColors.greenSoft
                                : AppColors.cardBgElevated,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _isUnlocked
                                  ? AppColors.greenLine
                                  : AppColors.cardBorder,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/icon_power.webp',
                                width: 14,
                                height: 14,
                                color: _isUnlocked
                                    ? AppColors.greenPrimary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _isUnlocked ? s.panelOn : s.panelOff,
                                style: AppTextStyles.display(
                                  10,
                                  color: _isUnlocked
                                      ? AppColors.greenPrimary
                                      : AppColors.textSecondary,
                                  letterSpacing: 0.06,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AuraIconButton(
                        size: 36,
                        padding: 9,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  SettingsScreen(appState: widget.appState),
                            ),
                          );
                        },
                        child: Image.asset(
                          'assets/images/icon_settings.webp',
                          color: AppColors.greenPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.divider, height: 1),
                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        // 1. SENSI TOOLS SECTION
                        AnimatedOpacity(
                          opacity: lockAlpha,
                          duration: const Duration(milliseconds: 220),
                          child: AbsorbPointer(
                            absorbing: !_isUnlocked,
                            child: Column(
                              children: [
                                AuraSectionHeader(
                                  icon: Icons.tune_rounded,
                                  title: s.sectionSensi,
                                ),
                                // Sensitivity Generator Card
                                AuraFeatureCard(
                                  title: s.sensitivityGenerator,
                                  description: s.featSensiDesc,
                                  expanded: _swSensi,
                                  onToggle: (v) => setState(() => _swSensi = v),
                                  body: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.selectDevice.toUpperCase(),
                                        style: AppTextStyles.display(
                                          9.5,
                                          color: AppColors.textSecondary,
                                          letterSpacing: 0.08,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Segmented Device Type Picker
                                      Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: AppColors.cardBgElevated,
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                        child: Row(
                                          children: [
                                            _SegmentChip(
                                              label: s.mobile,
                                              selected: _deviceTypeIndex == 0,
                                              onTap: () => setState(() {
                                                _deviceTypeIndex = 0;
                                                _mobileBrandIndex = 0;
                                              }),
                                            ),
                                            const SizedBox(width: 3),
                                            _SegmentChip(
                                              label: s.emulator,
                                              selected: _deviceTypeIndex == 1,
                                              onTap: () => setState(() {
                                                _deviceTypeIndex = 1;
                                                _emulatorIndex = 0;
                                              }),
                                            ),
                                            const SizedBox(width: 3),
                                            _SegmentChip(
                                              label: s.youtubers,
                                              selected: _deviceTypeIndex == 2,
                                              onTap: () => setState(() {
                                                _deviceTypeIndex = 2;
                                                _youtuberIndex = 0;
                                              }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      // Left / Current Device / Right Carousel
                                      Row(
                                        children: [
                                          AuraIconButton(
                                            size: 36,
                                            padding: 8,
                                            onTap: _swapLeft,
                                            child: const Icon(
                                              Icons.chevron_left_rounded,
                                              color: AppColors.greenPrimary,
                                              size: 20,
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 8,
                                              ),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    _currentList[
                                                        _currentItemIndex],
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        AppTextStyles.display(
                                                      13,
                                                      color:
                                                          AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    s.itemOf(
                                                      _currentItemIndex + 1,
                                                      _currentList.length,
                                                    ),
                                                    style: AppTextStyles.body(
                                                      10,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          AuraIconButton(
                                            size: 36,
                                            padding: 8,
                                            onTap: _swapRight,
                                            child: const Icon(
                                              Icons.chevron_right_rounded,
                                              color: AppColors.greenPrimary,
                                              size: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!widget.appState.isPro)
                                        AuraNativeAdCard(
                                          loaded: _nativeLoaded,
                                          adWidget: _nativeAd != null
                                              ? AdWidget(ad: _nativeAd!)
                                              : null,
                                        ),
                                      const SizedBox(height: 12),
                                      // Generate Sensi Button
                                      AuraGreenButton(
                                        height: 44,
                                        onTap: _generateSensi,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.bolt_rounded,
                                              color: AppColors.onGreen,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              s.generateSensi,
                                              style: AppTextStyles.display(
                                                12.5,
                                                color: AppColors.onGreen,
                                                letterSpacing: 0.06,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Divider(
                                          color: AppColors.divider,
                                          height: 1,
                                        ),
                                      ),
                                      // Sensi Result Header
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.sensiResult,
                                              style: AppTextStyles.display(
                                                9.5,
                                                color: AppColors.textSecondary,
                                                letterSpacing: 0.08,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            s.scaleHint,
                                            style: AppTextStyles.body(
                                              10,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      AuraMeterRow(
                                        label: s.general,
                                        value: _generalVal,
                                      ),
                                      AuraMeterRow(
                                        label: s.redDot,
                                        value: _redDotVal,
                                      ),
                                      AuraMeterRow(
                                        label: '2X',
                                        value: _x2Val,
                                      ),
                                      AuraMeterRow(
                                        label: '4X',
                                        value: _x4Val,
                                      ),
                                      AuraMeterRow(
                                        label: s.awm,
                                        value: _awmVal,
                                      ),
                                    ],
                                  ),
                                ),
                                // DPI & Fire Button Card
                                AuraFeatureCard(
                                  title: s.featDpi,
                                  description: s.featDpiDesc,
                                  expanded: _swDpi,
                                  onToggle: (v) => _togglePanelCard(
                                    v,
                                    rewardGated: false,
                                    setter: (val) => _swDpi = val,
                                  ),
                                  body: Column(
                                    children: [
                                      AuraInfoRow(
                                        label: s.dpi,
                                        value:
                                            _dpiVal == null ? '--' : '$_dpiVal',
                                        valueColor: AppColors.greenPrimary,
                                        valueSize: 15,
                                      ),
                                      AuraInfoRow(
                                        label: s.buttonFire,
                                        value: _fireBtnVal == null
                                            ? '--'
                                            : '$_fireBtnVal',
                                        valueColor: AppColors.greenPrimary,
                                        valueSize: 15,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        // 2. LIVE STATS SECTION (PRO)
                        AnimatedOpacity(
                          opacity: lockAlpha,
                          duration: const Duration(milliseconds: 220),
                          child: AbsorbPointer(
                            absorbing: !_isUnlocked,
                            child: Column(
                              children: [
                                AuraSectionHeader(
                                  icon: Icons.show_chart_rounded,
                                  title: s.realTimeStats,
                                  trailing: Container(
                                    height: 22,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(11),
                                      border: Border.all(
                                        color: AppColors.goldLine,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/images/icon_crown.webp',
                                          width: 11,
                                          height: 11,
                                          color: AppColors.gold,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          s.proTag,
                                          style: AppTextStyles.display(
                                            9,
                                            color: AppColors.gold,
                                            letterSpacing: 0.12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featFps,
                                  description: s.featFpsDesc,
                                  expanded: _swFps,
                                  onToggle: (v) => _toggleProStat(
                                    v,
                                    () {
                                      _swFps = true;
                                      _fpsMonitor?.start();
                                    },
                                    () {
                                      _swFps = false;
                                      _fpsMonitor?.stop();
                                    },
                                  ),
                                  body: Text(
                                    '$_liveFps FPS',
                                    style: AppTextStyles.display(
                                      19,
                                      color: AppColors.greenPrimary,
                                    ),
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featHz,
                                  description: s.featHzDesc,
                                  expanded: _swHz,
                                  onToggle: (v) => _toggleProStat(
                                    v,
                                    () => _swHz = true,
                                    () => _swHz = false,
                                  ),
                                  body: Text(
                                    '${_snapshot.refreshRateHz} Hz',
                                    style: AppTextStyles.display(
                                      19,
                                      color: AppColors.greenPrimary,
                                    ),
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featPing,
                                  description: s.featPingDesc,
                                  expanded: _swPing,
                                  onToggle: (v) => _toggleProStat(
                                    v,
                                    () {
                                      _swPing = true;
                                      _pingMonitor?.start();
                                    },
                                    () {
                                      _swPing = false;
                                      _pingMonitor?.stop();
                                    },
                                  ),
                                  body: Text(
                                    _livePing <= 0 ? 'N/A' : '$_livePing MS',
                                    style: AppTextStyles.display(
                                      19,
                                      color: AppColors.greenPrimary,
                                    ),
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featBtemp,
                                  description: s.featBtempDesc,
                                  expanded: _swBtemp,
                                  onToggle: (v) => _toggleProStat(
                                    v,
                                    () => _swBtemp = true,
                                    () => _swBtemp = false,
                                  ),
                                  body: Text(
                                    '${_snapshot.batteryTempC.toStringAsFixed(1)}°C',
                                    style: AppTextStyles.display(
                                      19,
                                      color: AppColors.greenPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // 3. PRO BANNER (always interactive even when panel is OFF)
                        if (!widget.appState.isPro) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.greenLine,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    AuraIconTile(
                                      size: 36,
                                      padding: 8,
                                      backgroundColor: AppColors.goldSoft,
                                      child: Image.asset(
                                        'assets/images/icon_crown.webp',
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.unlockProFeatures,
                                            style: AppTextStyles.display(
                                              12.5,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            s.proPerks,
                                            style: AppTextStyles.body(
                                              10.5,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                AuraGreenButton(
                                  height: 40,
                                  onTap: () => PremiumDialog.show(
                                    context,
                                    widget.appState,
                                  ),
                                  child: Text(
                                    s.tryForFree.toUpperCase(),
                                    style: AppTextStyles.display(
                                      12,
                                      color: AppColors.onGreen,
                                      letterSpacing: 0.06,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        // 4. DEVICE INFO SECTION
                        AnimatedOpacity(
                          opacity: lockAlpha,
                          duration: const Duration(milliseconds: 220),
                          child: AbsorbPointer(
                            absorbing: !_isUnlocked,
                            child: Column(
                              children: [
                                AuraSectionHeader(
                                  icon: Icons.smartphone_rounded,
                                  title: s.sectionDevice,
                                ),
                                AuraFeatureCard(
                                  title: s.featDevice,
                                  description: s.featDeviceDesc,
                                  expanded: _swDevice,
                                  onToggle: (v) => _togglePanelCard(
                                    v,
                                    rewardGated: true,
                                    setter: (val) => _swDevice = val,
                                  ),
                                  body: Column(
                                    children: [
                                      AuraInfoRow(
                                        label: s.infoModel,
                                        value: _snapshot.model,
                                      ),
                                      AuraInfoRow(
                                        label: s.infoBrand,
                                        value: _snapshot.brand,
                                      ),
                                      AuraInfoRow(
                                        label: s.infoAndroid,
                                        value: _snapshot.osVersion,
                                      ),
                                    ],
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featCpu,
                                  description: s.featCpuDesc,
                                  expanded: _swCpu,
                                  onToggle: (v) => _togglePanelCard(
                                    v,
                                    rewardGated: false,
                                    setter: (val) => _swCpu = val,
                                  ),
                                  body: Column(
                                    children: [
                                      AuraInfoRow(
                                        label: s.infoChipset,
                                        value: _snapshot.chipset,
                                      ),
                                      AuraInfoRow(
                                        label: s.infoCores,
                                        value: '${_snapshot.cores}',
                                      ),
                                      AuraInfoRow(
                                        label: s.infoAbi,
                                        value: _snapshot.abi,
                                      ),
                                    ],
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featRam,
                                  description: s.featRamDesc,
                                  expanded: _swRam,
                                  onToggle: (v) => _togglePanelCard(
                                    v,
                                    rewardGated: true,
                                    setter: (val) => _swRam = val,
                                  ),
                                  body: Column(
                                    children: [
                                      AuraProgressBar(progress: ramRatio),
                                      const SizedBox(height: 8),
                                      AuraInfoRow(
                                        label: s.infoUsed,
                                        value:
                                            '${DeviceService.formatBytes(ramUsed)} / ${DeviceService.formatBytes(_snapshot.ramTotalBytes)}',
                                      ),
                                      AuraInfoRow(
                                        label: s.infoFree,
                                        value: DeviceService.formatBytes(
                                          _snapshot.ramAvailBytes,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featStorage,
                                  description: s.featStorageDesc,
                                  expanded: _swStorage,
                                  onToggle: (v) => _togglePanelCard(
                                    v,
                                    rewardGated: false,
                                    setter: (val) => _swStorage = val,
                                  ),
                                  body: Column(
                                    children: [
                                      AuraProgressBar(progress: storageRatio),
                                      const SizedBox(height: 8),
                                      AuraInfoRow(
                                        label: s.infoUsed,
                                        value:
                                            '${DeviceService.formatBytes(storageUsed)} / ${DeviceService.formatBytes(_snapshot.storageTotalBytes)}',
                                      ),
                                      AuraInfoRow(
                                        label: s.infoFree,
                                        value: DeviceService.formatBytes(
                                          _snapshot.storageAvailBytes,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featDisplay,
                                  description: s.featDisplayDesc,
                                  expanded: _swDisplay,
                                  onToggle: (v) => _togglePanelCard(
                                    v,
                                    rewardGated: true,
                                    setter: (val) => _swDisplay = val,
                                  ),
                                  body: Column(
                                    children: [
                                      AuraInfoRow(
                                        label: s.infoResolution,
                                        value: '$resW x $resH',
                                      ),
                                      AuraInfoRow(
                                        label: s.infoDensity,
                                        value: '$dpi dpi',
                                      ),
                                      AuraInfoRow(
                                        label: s.infoScreenSize,
                                        value: '${inches.toStringAsFixed(1)}"',
                                      ),
                                    ],
                                  ),
                                ),
                                AuraFeatureCard(
                                  title: s.featBattery,
                                  description: s.featBatteryDesc,
                                  expanded: _swBattery,
                                  onToggle: (v) => _togglePanelCard(
                                    v,
                                    rewardGated: false,
                                    setter: (val) => _swBattery = val,
                                  ),
                                  body: Column(
                                    children: [
                                      AuraProgressBar(
                                        progress: _snapshot.batteryLevel / 100,
                                      ),
                                      const SizedBox(height: 8),
                                      AuraInfoRow(
                                        label: s.infoLevel,
                                        value: '${_snapshot.batteryLevel}%',
                                      ),
                                      AuraInfoRow(
                                        label: s.infoStatus,
                                        value: _batteryStatusLabel(
                                          s,
                                          _snapshot.batteryStatus,
                                        ),
                                      ),
                                      AuraInfoRow(
                                        label: s.infoHealth,
                                        value: _batteryHealthLabel(
                                          s,
                                          _snapshot.batteryHealth,
                                        ),
                                      ),
                                      AuraInfoRow(
                                        label: s.infoVoltage,
                                        value:
                                            '${_snapshot.batteryVoltage.toStringAsFixed(2)} V',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SegmentChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 36,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.greenPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: selected
                ? AppTextStyles.display(
                    11,
                    color: AppColors.onGreen,
                    letterSpacing: 0.02,
                  )
                : AppTextStyles.body(11.5, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}
