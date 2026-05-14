import 'package:awesome_flutter_skills/features/infinite_scroll/controller/infinite_scroll_controller.dart';
import 'package:awesome_flutter_skills/features/infinite_scroll/controller/infinite_scroll_state.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:flutter/material.dart';

import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';

class InfiniteScrollView extends StatefulWidget {
  @override
  _InfiniteScrollViewState createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ScrollController _scrollController = ScrollController();

  late final InfiniteScrollController<Profile> _controller =
      InfiniteScrollController(
        fetchPage: (page) async {
          final result = await _profileRepository.fetchProfiles(page: page);
          final fetchedSoFar = page * 20 + result.items.length;
          return (items: result.items, hasMore: fetchedSoFar < result.total);
        },
      );

  @override
  void initState() {
    super.initState();
    _controller.fetchNextPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + 200 >
          _scrollController.position.maxScrollExtent) {
        _controller.fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Infinite Scroll')),
      body: ValueListenableBuilder<InfiniteScrollState<Profile>>(
        valueListenable: _controller,
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
                  onPressed: _controller.fetchNextPage,
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
    final items = _controller.value.items!;
    return ListView.builder(
      controller: _scrollController,
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return switch (_controller.value.status) {
            InfiniteScrollStatus.onGoing => const Padding(
              padding: EdgeInsets.all(14),
              child: Center(child: CircularProgressIndicator()),
            ),
            InfiniteScrollStatus.subsequentPageError => Padding(
              padding: const EdgeInsets.all(14),
              child: Center(
                child: TextButton(
                  onPressed: _controller.fetchNextPage,
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
