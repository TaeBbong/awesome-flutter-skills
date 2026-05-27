import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/domain/models/profile.dart';

class ProfileFetchResult {
  final List<Profile> items;
  final int total;

  const ProfileFetchResult({required this.items, required this.total});
}

class ProfileRepository {
  static const int pageSize = 20;

  Future<ProfileFetchResult> fetchProfiles({required int page}) async {
    final String url =
        'https://dummyjson.com/users?limit=$pageSize&skip=${page * pageSize}';

    final http.Response response;
    try {
      response = await http.get(Uri.parse(url));
    } catch (_) {
      throw ProfileNetworkException();
    }

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = json.decode(response.body);
      final List<dynamic> raw = body['users'];
      final int total = body['total'];
      return ProfileFetchResult(
        items: raw.map((profile) => Profile.fromJson(profile)).toList(),
        total: total,
      );
    } else {
      throw ProfileServerException(response.statusCode);
    }
  }
}

sealed class ProfileRepositoryException implements Exception {}

final class ProfileNetworkException extends ProfileRepositoryException {}

final class ProfileServerException extends ProfileRepositoryException {
  ProfileServerException(this.statusCode);
  final int statusCode;
}
