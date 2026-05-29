import 'package:awesome_flutter_skills/core/di/service_locator.dart';
import 'package:awesome_flutter_skills/features/infinite_scroll/view_model/profile_list_view_model.dart';
import 'package:awesome_flutter_skills/features/infinite_scroll/widgets/first_page_error.dart';
import 'package:awesome_flutter_skills/features/infinite_scroll/widgets/profile_list_widget.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:awesome_flutter_skills/shared/pagination/infinite_scroll_state.dart';
import 'package:flutter/material.dart';

class InfiniteScrollView extends StatefulWidget {
  const InfiniteScrollView({super.key});

  @override
  State<InfiniteScrollView> createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  late final ProfileListViewModel _viewModel = getIt<ProfileListViewModel>();

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
      appBar: AppBar(title: const Text('Infinite Scroll')),
      body: RefreshIndicator(
        onRefresh: () async => _viewModel.refresh(),
        child: ValueListenableBuilder<InfiniteScrollState<Profile>>(
          valueListenable: _viewModel,
          builder: (context, state, _) => switch (state.status) {
            InfiniteScrollStatus.loadingFirstPage => const Center(
              child: CircularProgressIndicator(),
            ),
            InfiniteScrollStatus.firstPageError => FirstPageError(
              error: state.error,
              onRetry: _viewModel.fetchNextPage,
            ),
            InfiniteScrollStatus.noItemsFound => const Center(
              child: Text('No profiles found'),
            ),
            InfiniteScrollStatus.onGoing ||
            InfiniteScrollStatus.subsequentPageError ||
            InfiniteScrollStatus.completed => ProfileListWidget(
              state: state,
              onRetry: _viewModel.fetchNextPage,
              onNext: _viewModel.fetchNextPage,
            ),
          },
        ),
      ),
    );
  }
}
