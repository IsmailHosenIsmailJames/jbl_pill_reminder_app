import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> hasInternetConnection() async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

// This condition is for demo purposes only to explain every connection type.
// Use conditions which work for your requirements.
  if (connectivityResult.contains(ConnectivityResult.mobile)) {
    // Mobile network available.
    return true;
  } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
    // Wi-fi is available.
    // Note for Android:
    // When both mobile and Wi-Fi are turned on system will return Wi-Fi only as active network type
    return true;
  } else if (connectivityResult.contains(ConnectivityResult.ethernet)) {
    // Ethernet connection available.
    return true;
  } else if (connectivityResult.contains(ConnectivityResult.vpn)) {
    // Vpn connection active.
    // Note for iOS and macOS:
    // There is no separate network interface type for [vpn].
    // It returns [other] on any device (also simulator)
    return true;
  } else if (connectivityResult.contains(ConnectivityResult.bluetooth)) {
    return true;
    // Bluetooth connection available.
  } else if (connectivityResult.contains(ConnectivityResult.other)) {
    // Connected to a network which is not in the above mentioned networks.
    return true;
  } else if (connectivityResult.contains(ConnectivityResult.none)) {
    // No available network types
    return false;
  }
  return false;
}
