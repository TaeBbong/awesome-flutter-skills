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

  final List<Profile> _profiles = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  void _fetchNextPage() async {
    if (_isLoading || !_hasMore) return;
    setState(() {
      _isLoading = true;
    });
    try {
      ProfileFetchResult response = await _profileRepository.fetchProfiles(
        page: _currentPage,
      );
      if (!mounted) return;
      setState(() {
        _profiles.addAll(response.items);
        _isLoading = false;
        if (_profiles.length >= response.total) _hasMore = false;
        _currentPage += 1;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
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
        itemCount: _profiles.length + (_isLoading || !_hasMore ? 1 : 0),
        itemBuilder: (context, idx) {
          return idx >= _profiles.length
              ? _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : const Padding(
                        padding: EdgeInsets.all(14),
                        child: Center(child: Text('No more data to fetch')),
                      )
              : ListTile(
                  title: Text(
                    '${_profiles[idx].id} : ${_profiles[idx].username}',
                  ),
                );
        },
      ),
    );
  }
}
