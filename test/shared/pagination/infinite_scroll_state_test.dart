import 'package:awesome_flutter_skills/shared/pagination/infinite_scroll_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Each path makes proper InfiniteScrollState.status', () {
    test('[1] Initial state -> loadingFirstPage', () {
      final state = InfiniteScrollState<int>();
      expect(state.status, InfiniteScrollStatus.loadingFirstPage);
    });

    test('[2] Error without items -> firstPageError', () {
      final state = InfiniteScrollState<int>(error: Exception('SomeError'));
      expect(state.status, InfiniteScrollStatus.firstPageError);
    });

    test('[3] API returns empty list -> noItemsFound', () {
      final state = InfiniteScrollState<int>(items: [], hasMore: false);
      expect(state.status, InfiniteScrollStatus.noItemsFound);
    });

    test('[4] items exist and more data to fetch -> onGoing', () {
      final state = InfiniteScrollState<int>(items: [1, 2, 3], hasMore: true);
      expect(state.status, InfiniteScrollStatus.onGoing);
    });

    test('[5] items exist but error on next page -> subsequentPageError', () {
      final state = InfiniteScrollState<int>(
        items: [1, 2, 3],
        error: Exception('SomeError'),
      );
      expect(state.status, InfiniteScrollStatus.subsequentPageError);
    });

    test('[6] items exist and no more data to fetch -> completed', () {
      final state = InfiniteScrollState<int>(items: [1, 2, 3], hasMore: false);
      expect(state.status, InfiniteScrollStatus.completed);
    });
  });

  group('InfiniteScrollState.status - Edge cases', () {
    test('[1] empty items, error -> firstPageError goes first', () {
      final state = InfiniteScrollState<int>(
        items: [],
        error: Exception('SomeError'),
      );
      expect(state.status, InfiniteScrollStatus.firstPageError);
    });

    test('[2] error but completed -> completed goes first', () {
      final state = InfiniteScrollState<int>(
        items: [1, 2, 3],
        hasMore: false,
        error: Exception('SomeError'),
      );
      expect(state.status, InfiniteScrollStatus.completed);
    });

    test('[3] isLoading -> onGoing', () {
      final state = InfiniteScrollState<int>(
        items: [1, 2, 3],
        hasMore: true,
        isLoading: true,
      );
      expect(state.status, InfiniteScrollStatus.onGoing);
    });
  });

  group('InfiniteScrollState.isReadyToFetchMore', () {
    test('[1] onGoing and !isLoading -> isReadyToFetchMore', () {
      final state = InfiniteScrollState<int>(
        items: [1, 2, 3],
        hasMore: true,
        isLoading: false,
      );
      expect(state.isReadyToFetchMore, isTrue);
    });

    test('[2] already loading -> !isReadyToFetchMore', () {
      final state = InfiniteScrollState<int>(
        items: [1, 2, 3],
        hasMore: true,
        isLoading: true,
      );
      expect(state.isReadyToFetchMore, isFalse);
    });

    test('[3] error -> !isReadyToFetchMore', () {
      final state = InfiniteScrollState<int>(
        items: [1, 2, 3],
        hasMore: true,
        error: Exception('SomeError'),
      );
      expect(state.isReadyToFetchMore, isFalse);
    });

    test('[4] completed -> !isReadyToFetchMore', () {
      final state = InfiniteScrollState<int>(items: [1, 2, 3], hasMore: false);
      expect(state.isReadyToFetchMore, isFalse);
    });
  });
}
