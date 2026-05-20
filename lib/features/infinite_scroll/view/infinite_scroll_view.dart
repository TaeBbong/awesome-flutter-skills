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
  final ScrollController _scrollController = ScrollController();

  late final ProfileListViewModel _viewModel = ProfileListViewModel(
    ProfileRepository(),
  );

  @override
  void initState() {
    super.initState();
    _viewModel.fetchNextPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + 200 >
          _scrollController.position.maxScrollExtent) {
        _viewModel.fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Infinite Scroll')),
      body: ValueListenableBuilder<InfiniteScrollState<Profile>>(
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
          InfiniteScrollStatus.completed => _buildList(),
        },
      ),
    );
  }

  Widget _buildList() {
    final items = _viewModel.value.items!;
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return switch (_viewModel.value.status) {
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
        return ListTile(
          title: Text('${items[index].id} : ${items[index].username}'),
        );
      },
    );
  }
}
