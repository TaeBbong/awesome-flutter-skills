import 'package:awesome_flutter_skills/features/infinite_scroll/view/infinite_scroll_view.dart';
import 'package:awesome_flutter_skills/features/search/view/search_view.dart';
import 'package:flutter/material.dart';

/// Landing page listing every skill/feature in this portfolio app.
///
/// To add a new skill, append one [_SkillEntry] to [_skills] — it shows up
/// on the home list and becomes navigable automatically.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const List<_SkillEntry> _skills = [
    _SkillEntry(
      title: 'Infinite Scroll',
      description: 'Paginated list with infinite scrolling',
      icon: Icons.list,
      builder: _buildInfiniteScroll,
    ),
    _SkillEntry(
      title: 'Search Optimization',
      description: 'Debounce & throttle search-as-you-type',
      icon: Icons.search,
      builder: _buildSearch,
    ),
  ];

  static Widget _buildInfiniteScroll(BuildContext context) =>
      const InfiniteScrollView();

  static Widget _buildSearch(BuildContext context) => const SearchView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Awesome Flutter Skills')),
      body: ListView.separated(
        itemCount: _skills.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final skill = _skills[index];
          return ListTile(
            leading: Icon(skill.icon),
            title: Text(skill.title),
            subtitle: Text(skill.description),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: skill.builder),
            ),
          );
        },
      ),
    );
  }
}

class _SkillEntry {
  const _SkillEntry({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String description;
  final IconData icon;
  final WidgetBuilder builder;
}
