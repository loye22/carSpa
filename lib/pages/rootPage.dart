import 'package:car_spa/widgets/calender.dart';
import 'package:car_spa/widgets/accountAvatar.dart';
import 'package:car_spa/widgets/orders.dart';
import 'package:car_spa/widgets/services.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class rootPage extends StatefulWidget {
  static const routeName = '/rootPage';

  const rootPage({super.key});

  @override
  State<rootPage> createState() => _rootPageState();
}

class _rootPageState extends State<rootPage> {
  late PageController _pageController;
  late SideMenuController _sideMenuController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _sideMenuController = SideMenuController();

    _sideMenuController.addListener((index) {
      _pageController.jumpToPage(index);
    });

    DateTime now = DateTime.now();
  }

  List<SideMenuItem> _buildMenuItems() {
    return [
      SideMenuItem(
        title: 'calendar',
        onTap: (index, _) {
          _sideMenuController.changePage(index);
        },
        icon: Icon(Icons.calendar_month),
      ),
      SideMenuItem(
        title: 'comenzi',
        onTap: (index, _) {
          _sideMenuController.changePage(index);
        },
        icon: Icon(Icons.shopping_cart),
      ),
      SideMenuItem(
        title: 'angajat',
        onTap: (index, _) {
          _sideMenuController.changePage(index);
        },
        icon: Icon(Icons.person),
      ),
      SideMenuItem(
        title: 'servicii',
        onTap: (index, _) {
          _sideMenuController.changePage(index);
        },
        icon: Icon(Icons.inventory_2),
      ),
      SideMenuItem(
        title: 'Setting',
        onTap: (index, _) {
          _sideMenuController.changePage(index);
        },
        icon: Icon(Icons.settings),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        //backgroundColor: Color.fromRGBO(242, 247, 252, 1),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Animate(
              effects: [FadeEffect(duration: Duration(milliseconds: 700))],
              child: SideMenu(
                style: SideMenuStyle(
                  decoration: BoxDecoration(
                    color: Color(0xFF2c3e50), // Sidebar background color
                  ),
                  displayMode: SideMenuDisplayMode.auto,
                  openSideMenuWidth: 200,
                  compactSideMenuWidth: 40,
                  hoverColor: Color(0xFF34495e),
                  // Hover color for menu items
                  selectedColor: Color(0xFF1abc9c),
                  // Background color for selected item
                  selectedIconColor: Colors.white,
                  unselectedIconColor: Colors.white,
                  // White icon color for unselected items
                  backgroundColor: Color(0xFF2c3e50),
                  // Sidebar background color
                  selectedTitleTextStyle: TextStyle(color: Colors.white),
                  // White text color for selected item
                  unselectedTitleTextStyle: TextStyle(color: Colors.white),
                  // White text color for unselected items
                  iconSize: 20,
                  itemBorderRadius:
                      const BorderRadius.all(Radius.circular(5.0)),
                  showTooltip: true,
                  showHamburger: true,
                  itemHeight: 50.0,
                  itemInnerSpacing: 8.0,
                  itemOuterPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                  toggleColor: Colors.white, // White color for
                ),
                controller: _sideMenuController,
                // title: Image.asset('assets/logo.png'),
                items: _buildMenuItems(),
              ),
            ),
            Expanded(
                child: PageView(
              controller: _pageController,
              children: [
                services(),
                Container(
                  child: Center(
                    child: calenderView(),
                  ),
                ),
                orders(),
                Container(
                  child: Center(
                    child: Text("3"),
                  ),
                ),
                Container(
                  child: Center(
                    child: customAccountWidget(),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
