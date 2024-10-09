// ignore_for_file: prefer_final_fields, use_build_context_synchronously

import 'package:gallery_app/headers.dart';

class Intro extends StatelessWidget {
  const Intro({super.key});

  @override
  Widget build(BuildContext context) {
    // Delay to allow _checkIntroSeen to complete its async task before rendering
    Future.delayed(Duration.zero, () => _checkIntroSeen(context));
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _checkIntroSeen(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool introSeen = prefs.getBool('intro_seen') ?? false;

    if (introSeen) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const IntroScreen()),
      );
    }
  }
}

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            children: [
              buildPage(
                image: 'assets/images/intro_image2.png',
                title: "Seamless Organization",
                description:
                    "Easily categorize your photos and find what\nyou need in seconds.",
              ),
              buildPage(
                image: 'assets/images/intro_image3.png',
                title: "Smart Search",
                description:
                    "Quickly locate your favorite memories with powerful search features.",
              ),
              buildPage(
                image: 'assets/images/intro_image4.png',
                title: "Hide Photos Securely",
                description:
                    "Keep your private photos safe with our easy-to-use hiding feature.",
              ),
            ],
          ),
          Positioned(
            bottom: 80.0,
            left: 16.0,
            right: 16.0,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (_currentPage < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.setBool(
                          'intro_seen', true); // Set the intro as seen
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                HomePage()), // Navigate to AlbumsPage
                      );
                    }
                  },
                  child: Container(
                    height: 49,
                    width: 133,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(90),
                      color: const Color(0xffC1003F),
                    ),
                    child: const Center(
                      child: Text(
                        "NEXT",
                        style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                SmoothPageIndicator(
                  controller: _pageController,
                  count: 3, // Updated to match the number of pages
                  effect: const WormEffect(
                    activeDotColor: Color(0xffC1003F),
                    dotColor: Color(0xffFFE2EC),
                    dotHeight: 8.0,
                    dotWidth: 8.0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPage(
      {required String image,
      required String title,
      required String description}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 300,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            description,
            style: const TextStyle(
              color: Color(0xff929292),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w400,
              fontSize: 15,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
