import 'package:awesome_flutter_skills/shared/domain/models/profile.dart';
import 'package:flutter/material.dart';

import 'package:awesome_flutter_skills/shared/data/profile_repository.dart';

class InfiniteScrollView extends StatefulWidget {
  @override
  _InfiniteScrollViewState createState() => _InfiniteScrollViewState();
}

class _InfiniteScrollViewState extends State<InfiniteScrollView> {
  final ProfileRepository _profileRepository = ProfileRepository();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  bool _isLoading = false;
  List<Profile> _profiles = [];

  void _fetchNextPage() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });
    List<Profile> response = await _profileRepository.fetchProfiles(
      page: _currentPage,
    );
    setState(() {
      _profiles.addAll(response);
      _isLoading = false;
      _currentPage += 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchNextPage();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels + 200 >
          _scrollController.position.maxScrollExtent) {
        _fetchNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Infinite Scroll')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _profiles.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, idx) {
          if (idx >= _profiles.length) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListTile(
            title: Text('${_profiles[idx].id} : ${_profiles[idx].username}'),
          );
        },
      ),
    );
  }
}
