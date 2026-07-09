import 'dart:async';

class Throttler {
  Timer? _timer;
  final Duration interval;

  Throttler({required this.interval});

  void call(void Function() action) {
    if (_timer?.isActive ?? false) return;

    action();
    _timer = Timer(interval, () {});
  }

  void dispose() {
    _timer?.cancel();
  }
}
