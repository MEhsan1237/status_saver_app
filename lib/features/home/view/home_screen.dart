import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../images/view/image_view.dart';
import '../../videos/view/video_view.dart';
import '../../download/view/download_view.dart';
import '../widgets/home_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const StatusTabs(),
    const DownloadView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         centerTitle: true,
        title: Text(_selectedIndex == 0 ? AppStrings.appName : 'Downloaded'),
      ),
      drawer: const HomeDrawer(),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Theme.of(context).cardColor,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_motion_outlined),
              activeIcon: Icon(Icons.auto_awesome_motion),
              label: 'Recent Status',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud_download_outlined),
              activeIcon: Icon(Icons.cloud_download),
              label: 'Downloaded',
            ),
          ],
        ),
      ),
    );
  }
}

class StatusTabs extends StatelessWidget {
  const StatusTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: const TabBar(
              indicatorColor: AppColors.white,
              indicatorWeight: 3,
              tabs: [
                Tab(text: AppStrings.images),
                Tab(text: AppStrings.videos),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                ImageView(),
                VideoView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
