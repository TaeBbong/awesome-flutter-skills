import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:flutter/material.dart';

class SearchResultWidget extends StatelessWidget {
  const SearchResultWidget({super.key, required this.items});

  final List<Profile> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final profile = items[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(profile.image),
          ),
          title: Text(profile.username),
          subtitle: Text(profile.email),
        );
      },
    );
  }
}
