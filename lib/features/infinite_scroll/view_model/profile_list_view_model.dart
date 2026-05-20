import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:awesome_flutter_skills/shared/pagination/paginated_notifier.dart';

class ProfileListViewModel extends PaginatedNotifier<Profile> {
  ProfileListViewModel(this._repository);

  final ProfileRepository _repository;

  @override
  Future<({List<Profile> items, bool hasMore})> fetchPage(int page) async {
    final result = await _repository.fetchProfiles(page: page);
    final fetchedSoFar = page * ProfileRepository.pageSize + result.items.length;
    return (items: result.items, hasMore: fetchedSoFar < result.total);
  }
}