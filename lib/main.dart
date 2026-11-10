import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/main_shell.dart';
import 'services/diagnostics_logger_service.dart';
import 'services/hardware_telemetry_service.dart';
import 'services/memory_service.dart';
import 'services/settings_service.dart';
import 'services/voice_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge to edge system navigation and status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surfaceElevated,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Core Services
  await DiagnosticsLoggerService.instance.init();
  await SettingsService.instance.init();
  await MemoryService.instance.init();
  await VoiceService.instance.init();
  HardwareTelemetryService.instance.init();

  FlutterError.onError = (details) {
    DiagnosticsLoggerService.instance.logError(
      'FLUTTER',
      details.exceptionAsString(),
      details.stack?.toString(),
    );
  };

  runApp(const MaxAiApp());
}

class MaxAiApp extends StatelessWidget {
  const MaxAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Max AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainShell(),
    );
  }
}
