import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import '_fixtures/test_paginated_notifier.dart';

void main() {
  group('PaginatedMixin — Happy Path', () {
    test('성공한 fetch는 items 누적 + page 증가 + hasMore 반영', () async {
      // Arrange
      final notifier = TestPaginatedNotifier(
        onFetch: (page) async => (items: [10, 20, 30], hasMore: true),
      );

      // Act
      await notifier.fetchNextPage();

      // Assert
      expect(notifier.value.items, [10, 20, 30]);
      expect(notifier.value.page, 1);
      expect(notifier.value.hasMore, isTrue);
      expect(notifier.value.isLoading, isFalse);
      expect(notifier.requestedPages, [0], reason: 'page 0으로 요청');
    });

    test('연속 fetch는 items를 순서대로 누적', () async {
      // Arrange
      final pagesData = {
        0: [1, 2, 3],
        1: [4, 5, 6],
        2: [7, 8, 9],
      };
      final notifier = TestPaginatedNotifier(
        onFetch: (page) async => (items: pagesData[page]!, hasMore: page < 2),
      );

      // Act
      await notifier.fetchNextPage();
      await notifier.fetchNextPage();
      await notifier.fetchNextPage();

      // Assert
      expect(notifier.value.items, [1, 2, 3, 4, 5, 6, 7, 8, 9]);
      expect(notifier.value.page, 3);
      expect(notifier.value.hasMore, isFalse, reason: '마지막 페이지 hasMore=false');
      expect(notifier.requestedPages, [0, 1, 2]);
    });
  });

  group('PaginatedMixin — Dedup (토큰 패턴)', () {
    test('동시 fetchNextPage 호출은 한 번만 fetch 실행', () async {
      // Arrange
      final notifier = TestPaginatedNotifier(
        onFetch: (page) async => (items: [1, 2, 3], hasMore: true),
      );

      // Act — 거의 동시에 두 번 호출
      await Future.wait([
        notifier.fetchNextPage(),
        notifier.fetchNextPage(),
      ]);

      // Assert — fetchPage는 단 한 번만
      expect(notifier.fetchCallCount, 1);
      expect(notifier.value.items, [1, 2, 3], reason: '한 번만 누적');
    });

    test('이전 fetch 완료 후 다음 fetchNextPage는 정상 동작', () async {
      // Arrange
      final notifier = TestPaginatedNotifier(
        onFetch: (page) async => (items: [page], hasMore: true),
      );

      // Act
      await notifier.fetchNextPage();
      await notifier.fetchNextPage();

      // Assert
      expect(notifier.fetchCallCount, 2);
      expect(notifier.value.items, [0, 1]);
    });
  });

  group('PaginatedMixin — Cancellation (refresh)', () {
    test('refresh 호출 시 진행 중인 fetch 응답은 폐기', () async {
      // Arrange — Completer로 fetch를 "진행 중" 상태로 묶어둠
      final completer = Completer<({List<int> items, bool hasMore})>();
      final notifier = TestPaginatedNotifier(
        onFetch: (_) => completer.future,
      );

      // Act
      // 1) fetch 시작 (await 안 함 → 진행 중 상태 유지)
      final fetchFuture = notifier.fetchNextPage();
      await pumpEventQueue();
      expect(notifier.value.isLoading, isTrue, reason: '진행 중이어야 함');

      // 2) 진행 중에 refresh
      notifier.refresh();

      // 3) 옛 응답이 뒤늦게 도착
      completer.complete((items: [1, 2, 3], hasMore: true));
      await fetchFuture;
      await pumpEventQueue();

      // Assert — 옛 응답이 reset된 state에 덧붙으면 안 됨
      expect(notifier.value.items, isNull, reason: 'reset 상태 유지');
      expect(notifier.value.page, 0);
    });

    test('refresh 후 새 fetch는 page 0부터 다시 시작', () async {
      // Arrange
      final notifier = TestPaginatedNotifier(
        onFetch: (page) async => (items: [page * 10], hasMore: true),
      );

      // Act
      await notifier.fetchNextPage(); // page 0
      await notifier.fetchNextPage(); // page 1
      expect(notifier.value.page, 2);

      notifier.refresh();
      await notifier.fetchNextPage(); // page 0 다시

      // Assert
      expect(notifier.value.page, 1);
      expect(notifier.value.items, [0], reason: '이전 누적 사라지고 새 결과만');
      expect(notifier.requestedPages, [0, 1, 0]);
    });
  });

  group('PaginatedMixin — Error Handling', () {
    test('Exception 발생 시 state.error에 저장 + isLoading 해제', () async {
      // Arrange
      final notifier = TestPaginatedNotifier(
        onFetch: (_) async => throw Exception('network down'),
      );

      // Act
      await notifier.fetchNextPage();

      // Assert
      expect(notifier.value.error, isA<Exception>());
      expect(notifier.value.isLoading, isFalse,
          reason: '에러 후 영구 잠금 방지');
    });

    test('에러 후 다시 fetchNextPage 호출 가능 (재시도)', () async {
      // Arrange
      var shouldFail = true;
      final notifier = TestPaginatedNotifier(
        onFetch: (page) async {
          if (shouldFail) throw Exception('first attempt');
          return (items: [1, 2], hasMore: true);
        },
      );

      // Act 1 — 실패
      await notifier.fetchNextPage();
      expect(notifier.value.error, isNotNull);

      // Act 2 — 성공 시나리오로 전환 후 재시도
      shouldFail = false;
      await notifier.fetchNextPage();

      // Assert
      expect(notifier.value.error, isNull, reason: '에러 클리어됨');
      expect(notifier.value.items, [1, 2]);
      expect(notifier.fetchCallCount, 2);
    });

    test('Exception이 아닌 Error는 rethrow', () async {
      // Arrange
      final notifier = TestPaginatedNotifier(
        onFetch: (_) async => throw StateError('bug in code'),
      );

      // Act & Assert
      await expectLater(
        notifier.fetchNextPage(),
        throwsA(isA<StateError>()),
      );
    });
  });
}
