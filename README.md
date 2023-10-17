# nordic_lbs_client_demo

A client application for nRF Connect SDK peripheral_lbs sample.

Created as an exercise in Flutter BLE and Riverpod.

Sources:

* [Nordic LED Button Service documentation](https://developer.nordicsemi.com/nRF_Connect_SDK/doc/latest/nrf/libraries/bluetooth_services/services/lbs.html)
* [Flutter reactive BLE example using StreamProvider](https://github.com/ubiqueIoT/flutter-reactive-ble-example/tree/master)

## What does it do

App scans for Bluetooth devices and allows connecting to them if they have Nordic LBS service
running.

When connected, app displays Nordic LBS Button status (pressed, released) and allows toggling Nordic
LBS LED on and off.

## Before building

Project uses Riverpod with code generation.
Riverpod provider code should be generated before building.

```shell
flutter pub get
dart run build_runner watch -d 
```
