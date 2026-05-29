import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';
import 'package:flutter/material.dart';

class FirstPageError extends StatelessWidget {
  const FirstPageError({super.key, required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final e = error;
    if (e is ProfileRepositoryException) {
      return switch (e) {
        ProfileNetworkException() => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 48),
              const Text('Check your internet connection'),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
        ProfileServerException(:final statusCode) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Server Exception : $statusCode'),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      };
    }
    return Center(child: Text('Unknown error : $e'));
  }
}
