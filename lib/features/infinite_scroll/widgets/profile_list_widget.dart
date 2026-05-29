import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:awesome_flutter_skills/shared/pagination/infinite_scroll_state.dart';
import 'package:flutter/material.dart';

class ProfileListWidget extends StatefulWidget {
  const ProfileListWidget({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onNext,
  });

  final InfiniteScrollState<Profile> state;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  State<ProfileListWidget> createState() => _ProfileListWidgetState();
}

class _ProfileListWidgetState extends State<ProfileListWidget> {
  @override
  Widget build(BuildContext context) {
    final items = widget.state.items!;
    return ListView.builder(
      itemCount: items.length + 1,
      itemBuilder: (context, index) {
        if (index == items.length) {
          return switch (widget.state.status) {
            InfiniteScrollStatus.onGoing => const Padding(
              padding: EdgeInsets.all(14),
              child: Center(child: CircularProgressIndicator()),
            ),
            InfiniteScrollStatus.subsequentPageError => Padding(
              padding: const EdgeInsets.all(14),
              child: Center(
                child: TextButton(
                  onPressed: widget.onRetry,
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
        if (index >= items.length - 3 && widget.state.isReadyToFetchMore) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) widget.onNext();
          });
        }
        return ListTile(
          title: Text('${items[index].id} : ${items[index].username}'),
        );
      },
    );
  }
}
