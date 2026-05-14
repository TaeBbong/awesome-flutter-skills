import 'package:flutter/material.dart';

import 'package:awesome_flutter_skills/features/infinite_scroll/controller/infinite_scroll_state.dart';

class InfiniteScrollController<T>
    extends ValueNotifier<InfiniteScrollState<T>> {
  InfiniteScrollController({required this.fetchPage})
    : super(InfiniteScrollState<T>());

  final Future<({List<T> items, bool hasMore})> Function(int page) fetchPage;
  Object? _operation;

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
