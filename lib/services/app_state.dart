import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_strings.dart';
import 'ad_service.dart';
import 'subscription_service.dart';

class AppState extends ChangeNotifier {
  static const _kSelectedLanguage = 'selected_language';
  static const _kIsFirstLaunch = 'isFirstLaunch';
  static const _kIsPro = 'is_pro_unlocked';

  SharedPreferences? _prefs;
  String _languageCode = 'en';
  bool _hasSelectedLanguage = false;
  bool _isFirstLaunch = true;
  bool _isPro = false;
  bool _initialized = false;

  late final SubscriptionService subscription = SubscriptionService(
    appState: this,
  );

  String get languageCode => _languageCode;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isPro => _isPro;
  bool get initialized => _initialized;

  AppStrings get strings => AppStrings(_languageCode);

  String get languageDisplayName {
    switch (_languageCode) {
      case 'es':
        return strings.spanish;
      case 'pt':
        return strings.portuguese;
      default:
        return strings.english;
    }
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _hasSelectedLanguage = _prefs!.containsKey(_kSelectedLanguage);
    _languageCode = _prefs!.getString(_kSelectedLanguage) ?? 'en';
    _isFirstLaunch = _prefs!.getBool(_kIsFirstLaunch) ?? true;
    _isPro = _prefs!.getBool(_kIsPro) ?? false;
    _initialized = true;
    AdService.instance.setProChecker(() => _isPro);
    notifyListeners();
  }

  Future<void> initMonetization() async {
    await subscription.initialize();
    await AdService.instance.initialize();
  }

  Future<void> setLanguage(String code) async {
    _languageCode = code;
    _hasSelectedLanguage = true;
    await _prefs?.setString(_kSelectedLanguage, code);
    notifyListeners();
  }

  Future<void> setFirstLaunchCompleted() async {
    _isFirstLaunch = false;
    await _prefs?.setBool(_kIsFirstLaunch, false);
    notifyListeners();
  }

  Future<void> unlockPro() async {
    _isPro = true;
    await _prefs?.setBool(_kIsPro, true);
    notifyListeners();
  }
}
