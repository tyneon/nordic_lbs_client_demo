import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';

import 'package:nordic_lbs_client_demo/ui/home_screen.dart';
import 'package:nordic_lbs_client_demo/ui/lbs_screen.dart';
import 'package:nordic_lbs_client_demo/ui/scan_screen.dart';
import 'package:nordic_lbs_client_demo/ble/ble_scanner.dart';
import 'package:nordic_lbs_client_demo/ble/ble_status_monitor.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ble = FlutterReactiveBle();
    final scanner = BleScanner(ble);
    final monitor = BleStatusMonitor(ble);

    return MultiProvider(
      providers: [
        Provider.value(value: scanner),
        Provider.value(value: monitor),
        StreamProvider<BleScannerState?>(
          create: (_) => scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanning: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => monitor.state,
          initialData: BleStatus.unknown,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
        ),
        title: 'Nordic LBS Client Demo',
        home: const HomeScreen(),
        routes: {
          "lbs": (context) => const LBSPage(),
          "scan": (context) => const ScanPage(),
        },
      ),
    );
  }
}
