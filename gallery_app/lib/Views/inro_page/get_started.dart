// ignore_for_file: deprecated_member_use

import 'package:gallery_app/headers.dart';

class GetStartScreen extends StatefulWidget {
  const GetStartScreen({super.key});

  @override
  State<GetStartScreen> createState() => _GetStartScreenState();
}

class _GetStartScreenState extends State<GetStartScreen> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/welcome_img.png',
              ),
              const SizedBox(
                height: 70,
              ),
              const Text(
                "Welcom to Gallery",
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 4,
              ),
              const Text(
                'Effortlessly organize and showcase your\nphotos with our intuitive app.',
                style: TextStyle(
                  color: Color(0xff929292),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w400,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.clip,
              ),
              const SizedBox(
                height: 45,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isChecked = !_isChecked;
                      });
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: _isChecked
                            ? const Color(0xffC1003F)
                            : const Color(0xffFFFFFF),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color(0xffC1003F), width: 2.0),
                      ),
                      child: _isChecked
                          ? Icon(
                              Icons.check,
                              color: _isChecked
                                  ? const Color(0xffFFFFFF)
                                  : const Color(0xffFF6C01),
                              size: 15.0,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'I have read and agreed to your',
                            style: TextStyle(
                              color: Color(0xff929292),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '  Terms and Service',
                            style: const TextStyle(
                              color: Color(0xff000000),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                const url = '';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                          ),
                          const TextSpan(
                            text: '  and',
                            style: TextStyle(
                              color: Color(0xff929292),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '  \nPrivacy Policy',
                            style: const TextStyle(
                              color: Color(0xff000000),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                const url = '';
                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  if (_isChecked) {
                    Navigator.pushNamed(context, AppRoutes.introScreen);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                            'Please agree to the Terms and Privacy Policy to continue.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  // Get.to(Intro());
                },
                child: Container(
                  height: 49,
                  width: 193,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color(0xffC1003F),
                  ),
                  child: const Center(
                    child: Text(
                      textAlign: TextAlign.center,
                      "GET STARTED",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
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
}
