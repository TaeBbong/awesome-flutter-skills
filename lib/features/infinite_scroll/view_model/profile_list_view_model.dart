import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:awesome_flutter_skills/shared/pagination/infinite_scroll_state.dart';
import 'package:awesome_flutter_skills/shared/pagination/paginated_notifier.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileListViewModel extends ValueNotifier<InfiniteScrollState<Profile>>
    with PaginatedMixin<Profile> {
  ProfileListViewModel(this._repository)
    : super(InfiniteScrollState<Profile>());

  final ProfileRepository _repository;

  @override
  Future<({List<Profile> items, bool hasMore})> fetchPage(int page) async {
    final result = await _repository.fetchProfiles(page: page);
    final fetchedSoFar =
        page * ProfileRepository.pageSize + result.items.length;
    return (items: result.items, hasMore: fetchedSoFar < result.total);
  }
}
