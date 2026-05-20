import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/domain/models/profile.dart';

class ProfileFetchResult {
  final List<Profile> items;
  final int total;

  ProfileFetchResult({required this.items, required this.total});
}

class ProfileRepository {
  static const int pageSize = 20;

  Future<ProfileFetchResult> fetchProfiles({required int page}) async {
    final String url =
        'https://dummyjson.com/users?limit=$pageSize&skip=${page * pageSize}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> raw = json.decode(response.body)['users'];
      int total = json.decode(response.body)['total'];
      return ProfileFetchResult(
        items: raw.map((profile) => Profile.fromJson(profile)).toList(),
        total: total,
      );
    } else {
      throw Exception('Failed to load profiles from server');
    }
  }
}
