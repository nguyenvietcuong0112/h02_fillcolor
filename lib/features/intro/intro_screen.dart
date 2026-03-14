import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/utils/storage_utils.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNext() {
    if (_currentPage < 2) {
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
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const MainNavigator()));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> pages = [
      {
        'title': ref.tr('intro_1_title'),
        'desc': ref.tr('intro_1_desc'),
        'image': 'assets/images/intro_1.png',
      },
      {
        'title': ref.tr('intro_2_title'),
        'desc': ref.tr('intro_2_desc'),
        'image': 'assets/images/intro_2.png',
      },
      {
        'title': ref.tr('intro_3_title'),
        'desc': ref.tr('intro_3_desc'),
        'image': 'assets/images/intro_3.png',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // Top Part: Image with dynamic transition
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemCount: pages.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      pages[index]['image']!,
                      fit: BoxFit.fill,
                    );
                  },
                ),
                // Skip Button (Positioned over images)
                // SafeArea(
                //   child: Align(
                //     alignment: Alignment.topRight,
                //     child: Padding(
                //       padding: EdgeInsets.all(16.w),
                //       child: TextButton(
                //         onPressed: _onFinish,
                //         style: TextButton.styleFrom(
                //           backgroundColor: Colors.black.withValues(alpha: 0.3),
                //           shape: RoundedRectangleBorder(
                //             borderRadius: BorderRadius.circular(20),
                //           ),
                //         ),
                //         child: Text(
                //           ref.tr('skip'),
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontWeight: FontWeight.bold,
                //             fontSize: 13.sp,
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                // Bottom Gradient Shade to blend with content area
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Part: Content and Controls
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: const BoxDecoration(color: Colors.black),
              child: Column(
                children: [
                  SizedBox(height: 20.h),
                  // Pagination
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        width: _currentPage == index ? 24.w : 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Text Content
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      key: ValueKey<int>(_currentPage),
                      children: [
                        Text(
                          pages[_currentPage]['title']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          pages[_currentPage]['desc']!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 15.sp,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == pages.length - 1
                                ? ref.tr('get_started')
                                : ref.tr('next'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
