import 'dart:async';

class Debouncer {
  Timer? _timer;
  final Duration delay;

  Debouncer({required this.delay});

  void call(void Function() action) {
    _timer?.cancel();

    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
