import 'dart:async';

import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';

class FakeProfileRepository extends ProfileRepository {
  final completers = <Completer<ProfileSearchResult>>[];

  @override
  Future<ProfileSearchResult> searchProfiles({required String query}) {
    final c = Completer<ProfileSearchResult>();
    completers.add(c);
    return c.future;
  }
}
