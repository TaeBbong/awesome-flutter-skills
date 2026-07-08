import 'package:flutter/foundation.dart';

@immutable
class SearchState<T> {
  const SearchState({this.items, this.isLoading = false, this.error});

  final List<T>? items;
  final bool isLoading;
  final Object? error;

  static const _sentinel = Object();

  SearchState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    Object? error = _sentinel,
  }) {
    return SearchState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _sentinel) ? this.error : error,
    );
  }

  SearchState<T> reset() => SearchState<T>();
}

enum SearchStatus { loading, error, noItemsFound, completed, idle }

extension SearchStatusX on SearchState {
  SearchStatus get status {
    if (isLoading) return SearchStatus.loading;
    if (error != null) return SearchStatus.error;
    if (items == null) return SearchStatus.idle;
    if (items!.isEmpty) return SearchStatus.noItemsFound;
    return SearchStatus.completed;
  }
}
