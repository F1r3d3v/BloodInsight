import 'package:bloodinsight/core/styles/colors.dart';
import 'package:bloodinsight/core/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class GetStartedPage extends StatefulWidget {
  const GetStartedPage({super.key});

  @override
  State<GetStartedPage> createState() => _GetStartedPageState();
}

class _GetStartedPageState extends State<GetStartedPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late final List<AnimationController> _animationControllers;
  late final List<double> _frameDurations;
  bool isLastPage = false;
  int _currentPageIndex = 0;
  int _currentLoopSegmentIndex = 0;

  final List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Track Your Health Journey',
      description:
          'Monitor your blood work results over time and understand your health trends with intuitive visualizations.',
      animationAsset: 'assets/animations/health_tracking.json',
      initialSegment: [0, 55],
      loopSegments: [
        [55, 110],
        [110, 55],
      ],
    ),
    OnboardingPage(
      title: 'Smart Analysis',
      description:
          'Get personalized insights and explanations for your blood work results, making complex medical data easy to understand.',
      animationAsset: 'assets/animations/analysis.json',
    ),
    OnboardingPage(
      title: 'Stay Informed',
      description:
          'Receive timely notifications and recommendations based on your blood work trends to maintain optimal health.',
      animationAsset: 'assets/animations/notifications.json',
      initialSegment: [0, 173],
      loopSegments: [
        [173, 242],
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationControllers = List.generate(
      pages.length,
      (index) => AnimationController(
        vsync: this,
        duration: Duration.zero,
      ),
    );
    _frameDurations = List.filled(pages.length, 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);

    if (mounted) {
      context.go('/login');
    }
  }

  void _resetCurrentAnimation(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _animationControllers.length) {
      final page = pages[pageIndex];
      final controller = _animationControllers[pageIndex];
      if (controller.duration!.inSeconds <= 0) {
        return;
      }

      _currentLoopSegmentIndex = 0;

      if (page.initialSegment != null) {
        final startFrame = page.initialSegment![0] / _frameDurations[pageIndex];
        final endFrame = page.initialSegment![1] / _frameDurations[pageIndex];

        controller
          ..reset()
          ..value = startFrame
          ..animateTo(
            endFrame,
            duration: Duration(
              milliseconds: ((endFrame - startFrame).abs() *
                      controller.duration!.inMilliseconds)
                  .round(),
            ),
          ).then((_) {
            if (page.loopSegments != null && page.loopSegments!.isNotEmpty) {
              _playLoopSegment(page, pageIndex);
            }
          });
      } else if (page.repeatAnimation) {
        controller
          ..reset()
          ..repeat();
      }
    }
  }

  void _resetAnimationToInitial(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _animationControllers.length) {
      final page = pages[pageIndex];
      final controller = _animationControllers[pageIndex]..stop();

      if (page.initialSegment != null) {
        final startFrame = page.initialSegment![0] / _frameDurations[pageIndex];
        controller.value = startFrame;
      } else {
        controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.icterine700,
              AppColors.icterine600,
              AppColors.icterine500,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Main content
              Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        _resetAnimationToInitial(_currentPageIndex);

                        setState(() {
                          isLastPage = index == pages.length - 1;
                          _currentPageIndex = index;
                        });

                        _resetCurrentAnimation(index);
                      },
                      itemCount: pages.length,
                      itemBuilder: (context, index) {
                        return _buildPage(pages[index]);
                      },
                    ),
                  ),
                  Container(
                    padding: Sizes.kPadd20,
                    child: Column(
                      children: [
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: pages.length,
                          effect: ExpandingDotsEffect(
                            activeDotColor: Theme.of(context).primaryColor,
                            dotColor: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.2),
                            dotHeight: 8,
                            dotWidth: 8,
                          ),
                        ),
                        Sizes.kGap30,
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: Sizes.kRadius16,
                              ),
                            ),
                            onPressed: () {
                              if (isLastPage) {
                                _completeOnboarding();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            child: Text(
                              isLastPage ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Skip button
              if (!isLastPage)
                Positioned(
                  top: 10,
                  right: 10,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    final pageIndex = pages.indexOf(page);

    return Padding(
      padding: Sizes.kPadd20,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 300,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return OverflowBox(
                  minHeight: constraints.maxHeight * page.animationScale,
                  maxHeight: constraints.maxHeight * page.animationScale,
                  child: Lottie.asset(
                    page.animationAsset,
                    controller: _animationControllers[pageIndex],
                    fit: BoxFit.fitHeight,
                    onLoaded: (composition) {
                      _animationControllers[pageIndex].duration =
                          composition.duration;
                      _frameDurations[pageIndex] = composition.durationFrames;
                      if (_pageController.page?.round() == pageIndex) {
                        _resetCurrentAnimation(pageIndex);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          Sizes.kGap40,
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Sizes.kGap20,
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _playLoopSegment(OnboardingPage page, int pageIndex) {
    if (page.loopSegments == null || page.loopSegments!.isEmpty) {
      return;
    }

    final segment = page.loopSegments![_currentLoopSegmentIndex];
    final startFrame = segment[0] / _frameDurations[pageIndex];
    final endFrame = segment[1] / _frameDurations[pageIndex];
    final controller = _animationControllers[pageIndex];

    controller
      ..reset()
      ..value = startFrame
      ..animateTo(
        endFrame,
        duration: Duration(
          milliseconds: ((endFrame - startFrame).abs() *
                  controller.duration!.inMilliseconds)
              .round(),
        ),
      ).then((_) {
        _currentLoopSegmentIndex =
            (_currentLoopSegmentIndex + 1) % page.loopSegments!.length;
        _playLoopSegment(page, pageIndex);
      });
  }
}

class OnboardingPage {
  OnboardingPage({
    required this.title,
    required this.description,
    required this.animationAsset,
    this.animationScale = 1.0,
    this.initialSegment,
    this.loopSegments,
    this.repeatAnimation = true,
  });
  final String title;
  final String description;
  final String animationAsset;
  final double animationScale;
  final List<int>? initialSegment;
  final List<List<int>>? loopSegments;
  final bool repeatAnimation;
}
