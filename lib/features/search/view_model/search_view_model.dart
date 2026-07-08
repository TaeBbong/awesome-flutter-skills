import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:awesome_flutter_skills/shared/search/search_state.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileSearchViewModel extends ValueNotifier<SearchState<Profile>> {
  ProfileSearchViewModel(this._repository) : super(SearchState<Profile>());

  final ProfileRepository _repository;

  Future<void> searchQuery(String query) async {
    value = value.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.searchProfiles(query: query);
      value = value.copyWith(items: result.items);
    } catch (e) {
      value = value.copyWith(error: e);
      if (e is! Exception) rethrow;
    } finally {
      value = value.copyWith(isLoading: false);
    }
  }

  void clear() {
    value = value.reset();
  }
}
