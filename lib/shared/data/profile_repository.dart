import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/domain/models/profile.dart';

class ProfileRepository {
  Future<List<Profile>> fetchProfiles({required int page}) async {
    final String url = 'https://dummyjson.com/users?limit=20&skip=${page * 20}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> raw = json.decode(response.body)['users'];
      return raw.map((profile) => Profile.fromJson(profile)).toList();
    } else {
      throw Exception('Failed to load profiles from server');
    }
  }
}
