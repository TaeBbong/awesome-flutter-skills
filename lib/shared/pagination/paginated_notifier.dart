import 'package:flutter/foundation.dart';

import 'package:awesome_flutter_skills/shared/pagination/infinite_scroll_state.dart';

/// A generic, domain-agnostic pagination primitive.
///
/// Subclasses implement [fetchPage] to provide the actual data source.
/// The base class handles dedup, cancellation, and state transitions.
mixin PaginatedMixin<T> on ValueNotifier<InfiniteScrollState<T>> {
  Object? _operation;

  @protected
  Future<({List<T> items, bool hasMore})> fetchPage(int page);

  Future<void> fetchNextPage() async {
    if (_operation != null) return;
    final operation = _operation = Object();
    value = value.copyWith(isLoading: true, error: null);
    try {
      final result = await fetchPage(value.page);
      if (operation != _operation) return;
      value = value.copyWith(
        items: [...?value.items, ...result.items],
        page: value.page + 1,
        hasMore: result.hasMore,
      );
    } catch (e) {
      if (operation != _operation) return;
      value = value.copyWith(error: e);
      if (e is! Exception) rethrow;
    } finally {
      if (operation == _operation) {
        value = value.copyWith(isLoading: false);
        _operation = null;
      }
    }
  }

  void refresh() {
    _operation = null;
    value = value.reset();
  }
}
