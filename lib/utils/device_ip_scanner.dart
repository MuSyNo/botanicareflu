import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';

/// Scans the local Wi-Fi network for an ESP32 device that responds to `/identify`
/// with a body containing "BotaniCare".
///
/// [onProgress] is an optional callback to report scanning progress (1–254).
Future<String?> scanForEsp32Device({void Function(int scanned)? onProgress}) async {
  final info = NetworkInfo();
  final localIP = await info.getWifiIP();
  if (localIP == null) return null;

  final subnet = localIP.substring(0, localIP.lastIndexOf('.')); // e.g., "192.168.1"
  const timeout = Duration(milliseconds: 800);

  for (int i = 1; i < 255; i++) {
    final ip = '$subnet.$i';
    onProgress?.call(i);

    try {
      final response = await http.get(Uri.parse('http://$ip/identify')).timeout(timeout);
      if (response.statusCode == 200 && response.body.contains("BotaniCare")) {
        return ip;
      }
    } catch (_) {
      // Ignored: timeout, socket, or connection errors
    }
  }

  return null; // No matching device found
}
