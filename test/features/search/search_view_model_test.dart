import 'package:awesome_flutter_skills/features/search/view_model/search_view_model.dart';
import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';
import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '_fixtures/fake_profile_repository.dart';

void main() {
  group('SearchViewModel', () {
    test('[1] Stale response does not overwrite newest query', () async {
      final repo = FakeProfileRepository();
      final vm = ProfileSearchViewModel(repo);
      final aResult = ProfileSearchResult(
        items: [
          Profile(id: 1, username: 'Alice', image: 'image', email: 'email'),
        ],
        total: 1,
      );
      final bResult = ProfileSearchResult(
        items: [
          Profile(id: 2, username: 'Bob', image: 'image', email: 'email'),
        ],
        total: 1,
      );

      vm.searchQuery('Alice');
      vm.searchQuery('Bob');
      repo.completers[1].complete(bResult);
      repo.completers[0].complete(aResult);
      await pumpEventQueue();

      expect(vm.value.items, bResult.items);
    });
  });
}
