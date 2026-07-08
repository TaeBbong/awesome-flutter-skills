import 'package:awesome_flutter_skills/core/di/service_locator.dart';
import 'package:awesome_flutter_skills/features/search/view_model/search_view_model.dart';
import 'package:awesome_flutter_skills/features/search/widgets/search_error_widget.dart';
import 'package:awesome_flutter_skills/features/search/widgets/search_result_widget.dart';
import 'package:awesome_flutter_skills/shared/async/debouncer.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:awesome_flutter_skills/shared/search/search_state.dart';
import 'package:flutter/material.dart';

class SearchView extends StatefulWidget {
  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  late final ProfileSearchViewModel _viewModel =
      getIt<ProfileSearchViewModel>();

  final _debouncer = Debouncer(delay: const Duration(milliseconds: 350));

  @override
  void dispose() {
    _debouncer.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search profiles',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                if (query.isEmpty) {
                  _debouncer.dispose();
                  _viewModel.clear();
                  return;
                }
                _debouncer(() => _viewModel.searchQuery(query));
              },
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<SearchState<Profile>>(
              valueListenable: _viewModel,
              builder: (context, state, _) => switch (state.status) {
                SearchStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
                SearchStatus.error => SearchErrorWidget(
                  error: state.error,
                  onRetry: () {},
                ),
                SearchStatus.idle => const Center(child: Text('검색어를 입력하세요')),
                SearchStatus.noItemsFound => const Center(
                  child: Text('No profiles found'),
                ),
                SearchStatus.completed => SearchResultWidget(
                  items: state.items ?? const [],
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
