// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

// import 'package:gallery_app/controllers/photos_controller.dart';
import 'package:gallery_app/headers.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3)); // Delay for 3 seconds
    _checkFirstTimeUser();
  }

  Future<void> _checkFirstTimeUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (isFirstTime) {
      // If first time, navigate to IntroScreen
      prefs.setBool('isFirstTime', false);
      Navigator.of(context).pushReplacementNamed(AppRoutes.getStartPage);
    } else {
      // If not first time, navigate to HomePage
      Navigator.of(context).pushReplacementNamed(AppRoutes.homePage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffC1003F),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/s_logo.png',
              height: 106,
              width: 97,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'YOUR PHOTOS, YOUR STORY.',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'AnekGujrati',
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
