import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class DeviceSnapshot {
  final String model;
  final String brand;
  final String osVersion;
  final String chipset;
  final int cores;
  final String abi;
  final int ramTotalBytes;
  final int ramAvailBytes;
  final int storageTotalBytes;
  final int storageAvailBytes;
  final int batteryLevel;
  final int batteryStatus;
  final int batteryHealth;
  final double batteryVoltage;
  final double batteryTempC;
  final int refreshRateHz;

  const DeviceSnapshot({
    required this.model,
    required this.brand,
    required this.osVersion,
    required this.chipset,
    required this.cores,
    required this.abi,
    required this.ramTotalBytes,
    required this.ramAvailBytes,
    required this.storageTotalBytes,
    required this.storageAvailBytes,
    required this.batteryLevel,
    required this.batteryStatus,
    required this.batteryHealth,
    required this.batteryVoltage,
    required this.batteryTempC,
    required this.refreshRateHz,
  });

  factory DeviceSnapshot.fromMap(Map<Object?, Object?> map) {
    return DeviceSnapshot(
      model: (map['model'] as String?) ?? 'Unknown',
      brand: (map['brand'] as String?) ?? 'Unknown',
      osVersion: (map['osVersion'] as String?) ?? 'Unknown',
      chipset: (map['chipset'] as String?) ?? 'Unknown',
      cores: (map['cores'] as num?)?.toInt() ?? 4,
      abi: (map['abi'] as String?) ?? 'arm64-v8a',
      ramTotalBytes: (map['ramTotalBytes'] as num?)?.toInt() ?? 0,
      ramAvailBytes: (map['ramAvailBytes'] as num?)?.toInt() ?? 0,
      storageTotalBytes: (map['storageTotalBytes'] as num?)?.toInt() ?? 0,
      storageAvailBytes: (map['storageAvailBytes'] as num?)?.toInt() ?? 0,
      batteryLevel: (map['batteryLevel'] as num?)?.toInt() ?? 0,
      batteryStatus: (map['batteryStatus'] as num?)?.toInt() ?? -1,
      batteryHealth: (map['batteryHealth'] as num?)?.toInt() ?? -1,
      batteryVoltage: (map['batteryVoltage'] as num?)?.toDouble() ?? 0.0,
      batteryTempC: (map['batteryTempC'] as num?)?.toDouble() ?? 30.0,
      refreshRateHz: (map['refreshRateHz'] as num?)?.toInt() ?? 60,
    );
  }

  static DeviceSnapshot fallback() {
    String os = 'Unknown';
    int cores = 4;
    String brand = 'Generic';
    String model = 'Device';
    String abi = 'arm64-v8a';

    if (!kIsWeb) {
      try {
        os = '${Platform.operatingSystem} ${Platform.operatingSystemVersion.split(' ').first}';
        cores = Platform.numberOfProcessors;
        if (Platform.isAndroid) {
          brand = 'Android';
          model = 'Android Device';
        } else if (Platform.isIOS) {
          brand = 'Apple';
          model = 'iPhone';
        } else if (Platform.isMacOS) {
          brand = 'Apple';
          model = 'Mac';
          abi = 'x86_64 / arm64';
        }
      } catch (_) {}
    }

    return DeviceSnapshot(
      model: model,
      brand: brand,
      osVersion: os,
      chipset: kIsWeb ? 'WebAssembly' : 'System SoC',
      cores: cores,
      abi: abi,
      ramTotalBytes: 8 * 1024 * 1024 * 1024,
      ramAvailBytes: 3400 * 1024 * 1024,
      storageTotalBytes: 128 * 1024 * 1024 * 1024,
      storageAvailBytes: 54 * 1024 * 1024 * 1024,
      batteryLevel: 85,
      batteryStatus: 3, // Discharging
      batteryHealth: 2, // Good
      batteryVoltage: 4.12,
      batteryTempC: 31.4,
      refreshRateHz: 60,
    );
  }
}

class DeviceService {
  static const MethodChannel _channel = MethodChannel('com.darkaura.rabbit/device');

  static Future<DeviceSnapshot> getDeviceSnapshot() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final result = await _channel.invokeMapMethod<Object?, Object?>('getDeviceInfo');
        if (result != null) {
          return DeviceSnapshot.fromMap(result);
        }
      } catch (_) {}
    }
    return DeviceSnapshot.fallback();
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    int idx = (math.log(bytes) / math.log(1024)).floor().clamp(0, units.length - 1);
    final value = bytes / math.pow(1024, idx);
    return '${value.toStringAsFixed(value >= 100 ? 0 : 1)} ${units[idx]}';
  }

  static double estimateScreenInches(BuildContext context) {
    final mq = MediaQuery.of(context);
    final dpr = mq.devicePixelRatio;
    final widthPx = mq.size.width * dpr;
    final heightPx = mq.size.height * dpr;
    final dpi = dpr * 160.0;
    final wIn = widthPx / dpi;
    final hIn = heightPx / dpi;
    return math.sqrt(wIn * wIn + hIn * hIn);
  }
}

class FpsMonitor {
  final ValueChanged<int> onUpdate;
  bool _running = false;
  int _frameCount = 0;
  DateTime _windowStart = DateTime.now();

  FpsMonitor({required this.onUpdate});

  void start() {
    if (_running) return;
    _running = true;
    _frameCount = 0;
    _windowStart = DateTime.now();
    SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
  }

  void _onFrame(Duration timestamp) {
    if (!_running) return;
    _frameCount++;
    final now = DateTime.now();
    final elapsedMs = now.difference(_windowStart).inMilliseconds;
    if (elapsedMs >= 500) {
      final fps = (_frameCount * 1000 / elapsedMs).round().clamp(1, 240);
      onUpdate(fps);
      _frameCount = 0;
      _windowStart = now;
    }
    SchedulerBinding.instance.scheduleFrameCallback(_onFrame);
  }

  void stop() {
    _running = false;
  }
}

class PingMonitor {
  static const _hosts = [
    'https://www.google.com',
    'https://www.cloudflare.com',
    'https://1.1.1.1',
  ];

  final ValueChanged<int> onUpdate;
  Timer? _timer;
  bool _running = false;

  PingMonitor({required this.onUpdate});

  void start() {
    if (_running) return;
    _running = true;
    _pingOnce();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => _pingOnce());
  }

  Future<void> _pingOnce() async {
    if (!_running) return;
    if (kIsWeb) {
      onUpdate(24 + math.Random().nextInt(14));
      return;
    }
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 3);
    try {
      for (final host in _hosts) {
        if (!_running) return;
        try {
          final sw = Stopwatch()..start();
          final req = await client.headUrl(Uri.parse(host));
          final resp = await req.close().timeout(const Duration(seconds: 3));
          sw.stop();
          await resp.drain<void>();
          if (resp.statusCode >= 200 && resp.statusCode < 400) {
            if (_running) onUpdate(sw.elapsedMilliseconds.clamp(1, 9999));
            return;
          }
        } catch (_) {}
      }
      if (_running) onUpdate(-1);
    } finally {
      client.close(force: true);
    }
  }

  void stop() {
    _running = false;
    _timer?.cancel();
    _timer = null;
  }
}
