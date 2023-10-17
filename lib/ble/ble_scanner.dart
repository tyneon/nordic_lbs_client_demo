import 'dart:async';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:nordic_lbs_client_demo/ble/reactive_state.dart';

class BleScanner implements ReactiveState<BleScannerState> {
  BleScanner(FlutterReactiveBle ble) : _ble = ble;

  final FlutterReactiveBle _ble;
  final _devices = <DiscoveredDevice>[];
  StreamSubscription<DiscoveredDevice>? _subscription;
  final StreamController<BleScannerState> _stateStreamController =
      StreamController();

  @override
  Stream<BleScannerState> get state => _stateStreamController.stream;

  void startScan(List<Uuid> serviceIds) {
    _devices.clear();
    _subscription =
        _ble.scanForDevices(withServices: serviceIds).listen((device) {
      final index = _devices.indexWhere((item) => item.id == device.id);
      if (index < 0) {
        _devices.add(device);
      } else {
        _devices[index] = device;
      }
      _pushState();
    }, onError: (error) {
      // ???
    });
    _pushState();
  }

  Future<void> stopScan() async {
    await _subscription?.cancel();
    _subscription = null;
    _pushState();
  }

  void _pushState() {
    _stateStreamController.add(
      BleScannerState(
          discoveredDevices: _devices, scanning: _subscription != null),
    );
  }
}

class BleScannerState {
  final List<DiscoveredDevice> discoveredDevices;
  final bool scanning;

  const BleScannerState({
    required this.discoveredDevices,
    required this.scanning,
  });
}
