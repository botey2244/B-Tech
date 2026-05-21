import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  static const Color primaryBlue = Color(0xFF1607B8);
  static const Color softBlue = Color(0xFFDCEBF8);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handlePrimaryAction() {
    if (_currentPage == _pages.length - 1) {
      Navigator.pushNamed(context, '/login');
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  static const List<_OnboardingData> _pages = [
    _OnboardingData(
      titleTop: 'Your Trusted',
      titleBottom: 'Tech Store',
      description:
          'Find the best laptops, monitors,\nheadphones, and accessories\nall in one place',
      imagePath: 'assets/images/onboard.png',
      buttonLabel: 'Get Started',
      imageHeight: 188,
      imageBottom: 25,
      imageLeft: -6,
      imageRight: -10,
    ),
    _OnboardingData(
      titleTop: 'Top Quality',
      titleBottom: 'Products',
      description:
          'Carefully selected tech products\nfrom top brands to ensure\nthe best performance.',
      imagePath: 'assets/images/onboard1.png',
      buttonLabel: 'Next',
      imageHeight: 205,
      imageBottom: 14,
      imageLeft: -25,
      imageRight: -22,
    ),
    _OnboardingData(
      titleTop: 'Fast & Secure',
      titleBottom: 'Shopping',
      description:
          'Enjoy a smooth shipping experience\nwith secure payments and fast\ndelivery to your doorstep.',
      imagePath: 'assets/images/onboard2.png',
      buttonLabel: 'Get Started',
      imageHeight: 188,
      imageBottom: 24,
      imageLeft: 18,
      imageRight: 18,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (page) {
                      setState(() => _currentPage = page);
                    },
                    itemBuilder: (context, index) {
                      return _OnboardingPage(
                        data: _pages[index],
                        maxHeight: constraints.maxHeight,
                      );
                    },
                  ),
                ),
                _OnboardingActions(
                  buttonLabel: _pages[_currentPage].buttonLabel,
                  currentPage: _currentPage,
                  pageCount: _pages.length,
                  onPrimaryAction: _handlePrimaryAction,
                ),
                SizedBox(height: constraints.maxHeight * 0.035),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.titleTop,
    required this.titleBottom,
    required this.description,
    required this.imagePath,
    required this.buttonLabel,
    required this.imageHeight,
    required this.imageBottom,
    required this.imageLeft,
    required this.imageRight,
  });

  final String titleTop;
  final String titleBottom;
  final String description;
  final String imagePath;
  final String buttonLabel;
  final double imageHeight;
  final double imageBottom;
  final double imageLeft;
  final double imageRight;
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.data,
    required this.maxHeight,
  });

  final _OnboardingData data;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: maxHeight * 0.72),
        child: Column(
          children: [
            SizedBox(height: maxHeight * 0.08),
            Image.asset(
              'assets/images/logo.png',
              width: 118,
              height: 118,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 28,
                  height: 1.18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                  color: Colors.black,
                ),
                children: [
                  TextSpan(text: '${data.titleTop}\n'),
                  TextSpan(
                    text: data.titleBottom,
                    style: const TextStyle(
                      color: OnboardingScreen.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: 250,
              child: Text(
                data.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.18,
                  letterSpacing: 0,
                  color: Color(0xFF505050),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _ProductArt(data: data),
          ],
        ),
      ),
    );
  }
}

class _ProductArt extends StatelessWidget {
  const _ProductArt({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 282,
      height: 232,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: 2,
            child: Container(
              width: 214,
              height: 214,
              decoration: BoxDecoration(
                color: OnboardingScreen.softBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 3,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: data.imageLeft,
            right: data.imageRight,
            bottom: data.imageBottom,
            child: Image.asset(
              data.imagePath,
              height: data.imageHeight,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingActions extends StatelessWidget {
  const _OnboardingActions({
    required this.buttonLabel,
    required this.currentPage,
    required this.pageCount,
    required this.onPrimaryAction,
  });

  final String buttonLabel;
  final int currentPage;
  final int pageCount;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 245,
          height: 54,
          child: ElevatedButton(
            onPressed: onPrimaryAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: OnboardingScreen.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              buttonLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/login'),
          style: TextButton.styleFrom(
            foregroundColor: OnboardingScreen.primaryBlue,
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 0,
                color: Color(0xFF555555),
              ),
              children: [
                TextSpan(text: 'Already have an account? '),
                TextSpan(
                  text: 'Login',
                  style: TextStyle(
                    color: OnboardingScreen.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 22),
        _PageIndicator(currentPage: currentPage, pageCount: pageCount),
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.currentPage,
    required this.pageCount,
  });

  final int currentPage;
  final int pageCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < pageCount; i++) ...[
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: i == currentPage ? 31 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: i == currentPage
                  ? OnboardingScreen.primaryBlue
                  : const Color(0xFFD2D2D2),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          if (i != pageCount - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}
