import 'dart:async';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class InternetSpeedGetxController extends GetxController {
  var downloadSpeed = "0.0 Mbps".obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    startMonitoringSpeed();
  }

  void startMonitoringSpeed() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkInternetSpeed();
    });
  }

  Future<void> _checkInternetSpeed() async {
    final url = Uri.parse(
        "https://speed.hetzner.de/100MB.bin?${DateTime.now().millisecondsSinceEpoch}");
    final stopwatch = Stopwatch();

    try {
      final request = http.Request("GET", url);
      final response = await request.send();

      int receivedBytes = 0;
      stopwatch.start();

      await response.stream.listen((chunk) {
        receivedBytes += chunk.length;
      }).asFuture();

      stopwatch.stop();

      final seconds = stopwatch.elapsedMilliseconds / 1000.0;
      final speedMbps = (receivedBytes * 8 / seconds) / (1024 * 1024);

      downloadSpeed.value = "${speedMbps.toString()} Mbps";
    } catch (e) {
      downloadSpeed.value = "تعذر الاتصال";
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
