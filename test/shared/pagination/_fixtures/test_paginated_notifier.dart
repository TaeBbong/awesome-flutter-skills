import 'package:awesome_flutter_skills/shared/pagination/infinite_scroll_state.dart';
import 'package:awesome_flutter_skills/shared/pagination/paginated_notifier.dart';
import 'package:flutter/foundation.dart';

class TestPaginatedNotifier extends ValueNotifier<InfiniteScrollState<int>>
    with PaginatedMixin<int> {
  TestPaginatedNotifier({required this.onFetch})
    : super(InfiniteScrollState<int>());

  final Future<({List<int> items, bool hasMore})> Function(int page) onFetch;

  int fetchCallCount = 0;

  final List<int> requestedPages = [];

  @override
  Future<({List<int> items, bool hasMore})> fetchPage(int page) {
    fetchCallCount++;
    requestedPages.add(page);
    return onFetch(page);
  }
}
