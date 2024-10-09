import 'package:gallery_app/Views/HideMedia/hide_media.dart';
import 'package:gallery_app/Views/inro_page/get_started.dart';
import 'package:gallery_app/Views/inro_page/intro_page.dart';
import 'package:gallery_app/Views/splash_screen/splash_screen.dart';
import 'package:gallery_app/headers.dart';

class AppRoutes {
  static String splashScreen = '/';
  static String introScreen = '/intro_screen';
  static String getStartPage = '/get_start_page';
  static String homePage = '/home_page';
  static String albumsPage = '/albums_page';
  static String albumPage = '/album_page';
  static String imagePage = '/image_page';
  static String videoPage = '/video_page';
  static String mediaViewerPage = '/media_viewer_page';
  static String hiddenPage = '/hidden_page';

  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splashScreen: (context) => SplashScreen(),
    AppRoutes.getStartPage: (context) => const GetStartScreen(),
    AppRoutes.introScreen: (context) => const IntroScreen(),
    AppRoutes.homePage: (context) => HomePage(),
    AppRoutes.albumsPage: (context) => AlbumsPage(
          onToggleButtonVisibilityChanged: (visible) {},
          // onToggleButtonVisibilityChanged: (bool) {},
        ),
    AppRoutes.hiddenPage: (context) => HiddenMediaPage(),
    // AppRoutes.albumsPage:(context)=> AlbumPage(album: {}),
  };

  AppRoutes._();
  static final AppRoutes appRoutes = AppRoutes._();
}
