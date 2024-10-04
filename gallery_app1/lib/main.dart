import 'package:gallery_app1/controllers/photos_controller.dart';

import 'app.dart';
import 'headers.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AlbumsController()),
        ChangeNotifierProvider(create: (_) => MediaManager()),
        ChangeNotifierProvider(create: (_) => MediaProvider()),
        ChangeNotifierProvider(create: (_) => HiddenMediaProvider()),
        ChangeNotifierProvider(create: (_) => PhotosController()),
      ],
      child: MyApp(),
    ),
  );
}
