import 'package:gallery_app/headers.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;

  const HomePage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _showToggleButton = false;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();

    // Initialize PageController
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Navigate to the corresponding page using PageController
    _pageController.jumpToPage(index);

    // Handle visibility and searching states for AlbumsPage and SearchPage
    if (index == 1) {
      _showToggleButton = true;
      Provider.of<AlbumsController>(context, listen: false).isSearching = false;
    } else if (index == 2) {
      _showToggleButton = false;
      Provider.of<AlbumsController>(context, listen: false).isSearching = true;
    } else {
      _showToggleButton = false;
      Provider.of<AlbumsController>(context, listen: false).isSearching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final albumsController = Provider.of<AlbumsController>(context);
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(), // No leading icon
        elevation: 0,
        toolbarHeight: size.height * 0.075,
        backgroundColor: Colors.white,

        flexibleSpace: albumsController.isSearching
            ? _buildSearchBar(albumsController)
            : _buildLogo(),
        actions: _showToggleButton
            ? [
                IconButton(
                  icon: Icon(albumsController.isGridView
                      ? Icons.grid_view
                      : Icons.list),
                  onPressed: () {
                    setState(() {
                      albumsController.isGridView =
                          !albumsController.isGridView;
                      albumsController.resetScrollPositions();
                    });
                  },
                ),
              ]
            : [],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: [
          PhotosPage(),
          AlbumsPage(onToggleButtonVisibilityChanged: (visible) {
            setState(() {
              _showToggleButton = visible;
            });
          }),
          AlbumsPage(onToggleButtonVisibilityChanged: (visible) {
            setState(() {
              _showToggleButton = visible;
              albumsController.isSearching = true;
            });
          }),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.08,
        child: BottomNavigationBar(
          iconSize: 23,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xffFAD1E1),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: onTabTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.photo),
              label: 'Photos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: 'Album',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods to build UI elements

  Widget _buildSearchBar(AlbumsController controller) {
    return Container(
      alignment: Alignment.center,
      margin: EdgeInsets.only(top: 30, right: 20, left: 20, bottom: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      decoration: BoxDecoration(
        color: Color(0xffF6F6F6),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        style: TextStyle(
          // color: Color(0xffC5C5C5),
          fontSize: 16,
          fontFamily: 'AnekGujarati',
        ),
        controller: controller.searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search albums',
          hintStyle: TextStyle(
            color: Color(0xffC5C5C5),
            fontSize: 16,
            fontFamily: 'AnekGujarati',
          ),
          border: InputBorder.none,
          suffixIcon: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  controller.searchController.clear();
                },
                icon: const Icon(
                  Icons.close,
                  color: Color(0xff818181),
                ),
              ),
              IconButton(
                icon: Icon(
                  controller.isGridView ? Icons.grid_view : Icons.list,
                  color: Color(0xff818181),
                ),
                onPressed: () {
                  setState(() {
                    controller.isGridView = !controller.isGridView;
                    controller.resetScrollPositions();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(left: 20, top: 20),
      child: Image.asset(
        'assets/images/pictoria_logo.png',
        height: 30,
        fit: BoxFit.contain,
      ),
    );
  }
}

// Dummy pages for navigation

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings Page'));
  }
}
