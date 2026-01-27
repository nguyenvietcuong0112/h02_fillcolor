import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/utils/storage_utils.dart';
import '../../app.dart'; // For MainNavigator
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Creative Coloring',
      'desc': 'Unleash your creativity with hundreds of unique coloring pages.',
      'icon': 'mypainting', // Using built-in icons for demo
    },
    {
      'title': 'Relax & Unwind',
      'desc': 'Enjoy a peaceful coloring experience with soothing music.',
      'icon': 'flower', 
    },
    {
      'title': 'Easy to Use',
      'desc': 'Simple tap-to-fill features suitable for all ages.',
      'icon': 'brush',
    },
  ];

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() async {
    await StorageUtils.setIntroSeen(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onFinish,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            // Pagination Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: AppDimens.space4),
                  width: _currentPage == index ? 20.w : 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.black : Colors.grey[300],
                    borderRadius: BorderRadius.circular(AppDimens.radius4),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: AppDimens.space40),

            // Next/Get Started Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppDimens.space32),
              child: SizedBox(
                width: double.infinity,
                height: AppDimens.buttonHeight + 8.h,
                child: ElevatedButton(
                  onPressed: _onNext,
                  // Style is mainly from Theme, but we can override specifics if needed
                  child: Text(
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                  ),
                ),
              ),
            ),
            SizedBox(height: AppDimens.space32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(Map<String, String> data) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppDimens.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration Placeholder
          Container(
            width: 280.w,
            height: 280.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              data['icon'] == 'brush' ? Icons.brush : 
              data['icon'] == 'flower' ? Icons.filter_vintage : Icons.palette,
              size: 100.w,
              color: Colors.black,
            ),
          ),
          SizedBox(height: AppDimens.space40),
          Text(
            data['title']!,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(color: Colors.black),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDimens.space16),
          Text(
            data['desc']!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
