import 'package:awesome_flutter_skills/shared/async/debouncer.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Debouncer', () {
    test('[1] Runs only one call in durations', () {
      fakeAsync((async) {
        Debouncer d = Debouncer(delay: Duration(milliseconds: 200));
        var count = 0;

        d.call(() => count++);
        d.call(() => count++);
        d.call(() => count++);
        async.elapse(Duration(milliseconds: 200));

        expect(count, 1);
      });
    });
  });
}
