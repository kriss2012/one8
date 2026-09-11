import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../image_compression/application/image_compression_dependencies.dart';
import '../../../image_compression/presentation/controllers/image_compression_controller.dart';
import '../../../image_compression/presentation/pages/history_page.dart';
import '../../../image_compression/presentation/pages/home_page.dart';
import '../../../image_compression/presentation/pages/image_compression_page.dart';
import '../../../image_compression/presentation/pages/settings_page.dart';

class MainNavigationPage extends StatefulWidget {
  final ImageCompressionDependencies dependencies;

  const MainNavigationPage({required this.dependencies, super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  late final ImageCompressionController _controller;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _controller = ImageCompressionController(
      pickImagesUseCase: widget.dependencies.pickImages,
      pickExportDirectoryUseCase: widget.dependencies.pickExportDirectory,
      getDefaultExportDirectoryUseCase: widget.dependencies.getDefaultExportDirectory,
      compressImagesUseCase: widget.dependencies.compressImages,
      saveCompressedImagesUseCase: widget.dependencies.saveCompressedImages,
      shareCompressedImagesUseCase: widget.dependencies.shareCompressedImages,
      historyRepository: widget.dependencies.historyRepository,
    );


    _pages = [
      HomePage(
        controller: _controller,
        onOpenCompress: _navigateToCompress,
        onOpenHistory: () => setState(() => _currentIndex = 1),
      ),
      HistoryPage(controller: _controller),
      const SettingsPage(),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToCompress() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageCompressionPage(controller: _controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: _FloatingNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final String title;
  final List<List<dynamic>> icon;

  const _NavItemData({
    required this.title,
    required this.icon,
  });
}

class _FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItemData> _navItems = [
    _NavItemData(
      title: 'Home',
      icon: HugeIcons.strokeRoundedHome01,
    ),
    _NavItemData(
      title: 'History',
      icon: HugeIcons.strokeRoundedTime02,
    ),
    _NavItemData(
      title: 'Settings',
      icon: HugeIcons.strokeRoundedSettings02,
    ),
  ];

  const _FloatingNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final primaryColor = theme.colorScheme.primary;

    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 32,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias, // Ensures indicator never bleeds outside rounded bar
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / _navItems.length;
          return Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.fastOutSlowIn, // Fast, ultra-responsive acceleration & smooth arrival
                left: currentIndex * itemWidth + 2,
                top: 0,
                bottom: 0,
                width: itemWidth - 4,
                child: Center(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: List.generate(
                  _navItems.length,
                  (index) {
                    final item = _navItems[index];
                    return _NavItem(
                      title: item.title,
                      icon: item.icon,
                      isSelected: currentIndex == index,
                      onTap: () => onTap(index),
                      width: itemWidth,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final List<List<dynamic>> icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double width;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurface.withValues(alpha: 0.75);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: AnimatedScale(
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                child: HugeIcon(
                  icon: icon,
                  size: 24,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
              child: Text(title),
            ),
          ],
        ),
      ),
    );
  }
}

