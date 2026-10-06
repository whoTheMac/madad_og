import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../authentication/login_page.dart';



class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/images/onboarding1.png',
      title: 'Capture & Listen',
      description:
      'Turn speech to text, translate instantly, and generate podcast-style audio standard notes for effortless listening.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding2.png',
      title: 'Learn & Transform',
      description:
      'Convert uploaded PDFs into beautifully styled notes and generate custom flashcards in seconds.',
    ),
    OnboardingData(
      image: 'assets/images/onboarding3.png',
      title: 'Play & Bloom',
      description:
      'Slay monster quizzes by answering correctly while watching your personal flower bloom with every study session.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _goToPage(_currentPage + 1);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>  const LoginPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  right: 24,
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.55),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Onboarding pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _OnboardingContent(
                    data: _pages[index],
                  );
                },
              ),
            ),

            // Bottom controls
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 10, 28, 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Page indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                          (index) {
                        final bool isActive = _currentPage == index;

                        return GestureDetector(
                          onTap: () => _goToPage(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            width: isActive ? 28 : 12,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF977272)
                                  : const Color(0xFFD8D5E8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Arrow on the last page
                  if (_currentPage == _pages.length - 1) ...[
                    const SizedBox(width: 20),

                    GestureDetector(
                      onTap: _nextPage,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFF977272),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF977272)
                                  .withOpacity(0.25),
                              blurRadius: 15,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final OnboardingData data;

  const _OnboardingContent({
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          const Spacer(),

          // Cutout image
          Expanded(
            flex: 5,
            child: Center(
              child: Image.asset(
                data.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.image_outlined,
                    size: 100,
                    color: Color(0xFF977272),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 29,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202124),
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 14),

          // Description
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Color(0xFF977272),
              fontWeight: FontWeight.w400,
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String description;

  OnboardingData({
    required this.image,
    required this.title,
    required this.description,
  });
}
