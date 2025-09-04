import 'package:flutter/services.dart'; // Import for SystemNavigator
import 'dart:ui';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:taskify/screens/settings/setting_screen.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../config/strings.dart';
import '../../utils/widgets/my_theme.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import '../home_screen/home_screen.dart';
import '../task/all_task_from_dash_screen.dart';
import '../Project/project_from_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottomNavWidget.dart';

class DashBoard extends StatefulWidget {
  final int initialIndex;
  const DashBoard({super.key, this.initialIndex = 0});

  @override
  State<DashBoard> createState() => _DashBoardState();
}

class _DashBoardState extends State<DashBoard>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int selBottom = 0;
  int _selectedIndex = 0;
  String? currency;
  String? statusPending;
  late TabController _tabController;
  String? userRole; // Store the user's role
  List<Widget> _widgetOptions = []; // Dynamic widget options
  List<Map<String, dynamic>> _navItems = []; // Dynamic navigation items

  void isAA() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('firstTimeUserKey', false);
  }

  String? workSpaceTitle;

  // Fetch workspace and role
  getWorkspaceAndRole() async {
    var box = await Hive.openBox(userBox);
    workSpaceTitle = box.get('workspace_title');
    userRole = box.get('role'); // Fetch the role
    if (mounted) {
      BlocProvider.of<AuthBloc>(context)
          .add(WorkspaceUpdate(workspaceTitle: workSpaceTitle));
      // Update widget options and nav items based on role
      setState(() {
        _widgetOptions = _getWidgetOptions();
        _navItems = _getNavItems();
        // Ensure selected index is valid for the role
        if (_selectedIndex >= _widgetOptions.length) {
          _selectedIndex = 0;
        }
      });
    }
  }

  // Define widget options based on role
  List<Widget> _getWidgetOptions() {
    if (userRole == 'member') {
      return [
        const AllTaskScreen(),
        const Settingscreen(),
      ];
    } else {
      // Admin or default case
      return [
        const HomeScreen(),
        const ProjectScreen(),
        const AllTaskScreen(),
        const Settingscreen(),
      ];
    }
  }

  // Define navigation items based on role
  List<Map<String, dynamic>> _getNavItems() {
    if (userRole == 'member') {
      return [
        {
          'icon': HeroIcons.documentCheck,
          'index': 0,
        },
        {
          'icon': HeroIcons.cog8Tooth,
          'index': 1,
        },
      ];
    } else {
      // Admin or default case
      return [
        {
          'icon': HeroIcons.home,
          'index': 0,
        },
        {
          'icon': HeroIcons.wallet,
          'index': 1,
        },
        {
          'icon': HeroIcons.documentCheck,
          'index': 2,
        },
        {
          'icon': HeroIcons.cog8Tooth,
          'index': 3,
        },
      ];
    }
  }

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    getWorkspaceAndRole(); // Fetch workspace and role

    super.initState();
    isAA();

    Future.delayed(Duration.zero, () {
      _tabController = TabController(
        length: _widgetOptions.length,
        vsync: this,
        initialIndex: _selectedIndex,
      );

      _tabController.addListener(() {
        Future.delayed(const Duration(microseconds: 10)).then((value) {
          setState(() {
            selBottom = _tabController.index;
          });
        });
      });
    });
  }

  @override
  void didUpdateWidget(DashBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update tab controller length if widget options change
    if (_widgetOptions.length != _tabController.length) {
      _tabController.dispose();
      _tabController = TabController(
        length: _widgetOptions.length,
        vsync: this,
        initialIndex: _selectedIndex < _widgetOptions.length ? _selectedIndex : 0,
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  Future<bool?> _onWillPop() async {
    if (_selectedIndex == 0) {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
          backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
          title: Text(AppLocalizations.of(context)!.exitApp),
          content: Text(AppLocalizations.of(context)!.doyouwanttoexitApp),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(AppLocalizations.of(context)!.yes),
            ),
          ],
        ),
      );
      if (shouldExit ?? false) {
        SystemNavigator.pop();
        return true;
      } else {
        return false;
      }
    } else {
      setState(() {
        _selectedIndex = 0;
        _tabController.animateTo(0);
      });
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _onWillPop() ?? false;
        if (context.mounted && shouldPop) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        extendBodyBehindAppBar: false,
        extendBody: true,
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: _getBottomBar(isLightTheme),
      ),
    );
  }

  _getBottomBar(isLightTheme) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40.4, sigmaY: 83.4),
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.map((item) {
              return GlowIconButton(
                icon: item['icon'],
                isSelected: _selectedIndex == item['index'],
                glowColor: Colors.white,
                selectedColor: Theme.of(context).colorScheme.textClrChange,
                unselectedColor: AppColors.greyForgetColor,
                onTap: () => _navigateToIndex(item['index']),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}