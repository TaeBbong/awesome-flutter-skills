import 'package:flutter/material.dart';

@immutable
class InfiniteScrollState<T> {
  const InfiniteScrollState({
    this.items,
    this.page = 0,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  final List<T>? items;
  final int page;
  final bool isLoading;
  final bool hasMore;
  final Object? error;

  static const _sentinel = Object();

  InfiniteScrollState<T> copyWith({
    List<T>? items,
    int? page,
    bool? isLoading,
    bool? hasMore,
    Object? error = _sentinel,
  }) {
    return InfiniteScrollState<T>(
      items: items ?? this.items,
      page: page ?? this.page,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: identical(error, _sentinel) ? this.error : error,
    );
  }

  InfiniteScrollState<T> reset() => InfiniteScrollState<T>();
}

enum InfiniteScrollStatus {
  loadingFirstPage,
  firstPageError,
  noItemsFound,
  onGoing,
  subsequentPageError,
  completed,
}

extension InfiniteScrollStatusX<T> on InfiniteScrollState {
  InfiniteScrollStatus get status {
    final bool hasItems = items != null && items!.isNotEmpty;
    final bool hasError = error != null;

    if (items == null && !hasError)
      return InfiniteScrollStatus.loadingFirstPage;
    if (!hasItems && hasError) return InfiniteScrollStatus.firstPageError;
    if (items != null && items!.isEmpty)
      return InfiniteScrollStatus.noItemsFound;
    if (hasItems && hasMore && hasError)
      return InfiniteScrollStatus.subsequentPageError;
    if (hasItems && hasMore) return InfiniteScrollStatus.onGoing;
    if (hasItems && !hasMore) return InfiniteScrollStatus.completed;

    throw StateError('Unknown InfiniteScrollStatus case');
  }
}
