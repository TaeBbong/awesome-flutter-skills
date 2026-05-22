import 'package:awesome_flutter_skills/features/infinite_scroll/view_model/profile_list_view_model.dart';
import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:awesome_flutter_skills/shared/pagination/infinite_scroll_state.dart';
import 'package:flutter/material.dart';

class InfiniteScrollView extends StatefulWidget {
  @override
  _InfiniteScrollViewState createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  late final ProfileListViewModel _viewModel = ProfileListViewModel(
    ProfileRepository(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.fetchNextPage();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Infinite Scroll')),
      body: RefreshIndicator(
        onRefresh: () async => _viewModel.refresh(),
        child: ValueListenableBuilder<InfiniteScrollState<Profile>>(
          valueListenable: _viewModel,
          builder: (context, state, _) => switch (state.status) {
            InfiniteScrollStatus.loadingFirstPage => const Center(
              child: CircularProgressIndicator(),
            ),
            InfiniteScrollStatus.firstPageError => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Something went wrong...'),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: _viewModel.fetchNextPage,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            InfiniteScrollStatus.noItemsFound => const Center(
              child: Text('No profiles found'),
            ),
            InfiniteScrollStatus.onGoing ||
            InfiniteScrollStatus.subsequentPageError ||
            InfiniteScrollStatus.completed => _buildList(state),
          },
        ),
      ),
    );
  }

  Widget _buildList(InfiniteScrollState<Profile> state) {
    final items = state.items!;
    return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return switch (state.status) {
            InfiniteScrollStatus.onGoing => const Padding(
              padding: EdgeInsets.all(14),
              child: Center(child: CircularProgressIndicator()),
            ),
            InfiniteScrollStatus.subsequentPageError => Padding(
              padding: const EdgeInsets.all(14),
              child: Center(
                child: TextButton(
                  onPressed: _viewModel.fetchNextPage,
                  child: const Text('Tap to retry'),
                ),
              ),
            ),
            InfiniteScrollStatus.completed => const Padding(
              padding: EdgeInsets.all(14),
              child: Center(child: Text('No more data to load')),
            ),
            _ => throw StateError('Unreachable InfiniteScrollStatus'),
          };
        }
        if (index >= items.length - 3 && state.isReadyToFetchMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _viewModel.fetchNextPage();
          });
        }
        return ListTile(
          title: Text('${items[index].id} : ${items[index].username}'),
        );
      },
    );
  }
}
