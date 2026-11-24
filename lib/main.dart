import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/launch_screen.dart';
import 'services/app_state.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppColors.bgPrimary,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgPrimary,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final appState = AppState();
  await appState.init();
  // Start AdMob + IAP initialization in background while splash animates
  appState.initMonetization();

  runApp(RabbitAuraApp(appState: appState));
}

class RabbitAuraApp extends StatelessWidget {
  final AppState appState;

  const RabbitAuraApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'RabbitX - Dark Sensi Panel',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.bgPrimary,
            colorScheme: const ColorScheme.dark(
              primary: AppColors.greenPrimary,
              onPrimary: AppColors.onGreen,
              surface: AppColors.cardBg,
              onSurface: AppColors.textPrimary,
            ),
            fontFamily: AppTextStyles.fontBody,
            useMaterial3: true,
          ),
          home: LaunchScreen(appState: appState),
        );
      },
    );
  }
}
