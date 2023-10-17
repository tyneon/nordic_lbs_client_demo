import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ble.g.dart';

@Riverpod(keepAlive: true)
FlutterReactiveBle ble(BleRef ref) => FlutterReactiveBle();

@Riverpod(keepAlive: true)
Stream<BleStatus?> status(StatusRef ref) => ref.watch(bleProvider).statusStream;

@riverpod
class Scanner extends _$Scanner {
  @override
  BleScannerState build() {
    ref.onDispose(() => state._subscription?.cancel());
    return const BleScannerState(
      devices: [],
      subscription: null,
    );
  }

  void start(List<Uuid> serviceIds) {
    if (state.scanning) {
      return;
    }
    state = BleScannerState(
      devices: [],
      subscription: ref
          .watch(bleProvider)
          .scanForDevices(withServices: serviceIds)
          .listen(onScanData),
    );
  }

  void onScanData(DiscoveredDevice device) {
    final index = state.devices.indexWhere((item) => item.id == device.id);
    if (index < 0) {
      state = BleScannerState(
        devices: [device, ...state.devices]..sort(_compareDevicesByRssi),
        subscription: state._subscription,
      );
    } else {
      final devices = state.devices;
      devices[index] = device;
      devices.sort(_compareDevicesByRssi);
      state = BleScannerState(
        devices: devices,
        subscription: state._subscription,
      );
    }
  }

  Future<void> stop() async {
    if (!state.scanning) {
      return;
    }
    state._subscription!.cancel();
    state = BleScannerState(
      devices: state.devices,
      subscription: null,
    );
  }

  int _compareDevicesByRssi(DiscoveredDevice first, DiscoveredDevice second) =>
      first.rssi.compareTo(second.rssi);
}

class BleScannerState {
  final List<DiscoveredDevice> devices;
  final StreamSubscription<DiscoveredDevice>? _subscription;

  const BleScannerState({
    required this.devices,
    required StreamSubscription<DiscoveredDevice>? subscription,
  }) : _subscription = subscription;

  bool get scanning => _subscription != null;
}

@riverpod
Stream<ConnectionStateUpdate> deviceConnection(
  DeviceConnectionRef ref, {
  required DiscoveredDevice device,
  Map<Uuid, List<Uuid>>? servicesWithCharacteristicsToDiscover,
}) =>
    ref.watch(bleProvider).connectToDevice(
          id: device.id,
          servicesWithCharacteristicsToDiscover:
              servicesWithCharacteristicsToDiscover,
        );

@Riverpod(keepAlive: true)
class ConnectedDevice extends _$ConnectedDevice {
  @override
  DiscoveredDevice? build() => null;

  void update(DiscoveredDevice device) {
    state = device;
  }

  void clear() {
    state = null;
  }
}

@riverpod
Future<List<Service>> discoverServices(
  DiscoverServicesRef ref,
  String deviceId,
) async {
  final ble = ref.watch(bleProvider);
  try {
    await ble.discoverAllServices(deviceId);
    return await ble.getDiscoveredServices(deviceId);
  } on Exception catch (_) {
    rethrow;
  }
}

@riverpod
Future<List<int>> readCharacteristic(
  ReadCharacteristicRef ref,
  QualifiedCharacteristic characteristic,
) async {
  try {
    return await ref.watch(bleProvider).readCharacteristic(characteristic);
  } on Exception catch (_) {
    rethrow;
  }
}

@riverpod
Future<void> writeToCharacteristic(
  WriteToCharacteristicRef ref, {
  required QualifiedCharacteristic characteristic,
  required List<int> value,
  bool withResponse = false,
}) async {
  try {
    if (withResponse) {
      await ref.watch(bleProvider).writeCharacteristicWithResponse(
            characteristic,
            value: value,
          );
    } else {
      await ref.watch(bleProvider).writeCharacteristicWithoutResponse(
            characteristic,
            value: value,
          );
    }
  } on Exception catch (_) {
    rethrow;
  }
}

@riverpod
Stream<List<int>> subscribeToCharacteristic(
  SubscribeToCharacteristicRef ref,
  QualifiedCharacteristic characteristic,
) {
  return ref.watch(bleProvider).subscribeToCharacteristic(characteristic);
}
