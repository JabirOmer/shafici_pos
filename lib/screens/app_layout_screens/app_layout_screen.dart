import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shafici_pos/app.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/app_routes_provider.dart';
import 'package:shafici_pos/screens/app_layout_screens/side_bar_widget.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:provider/provider.dart';

class AppLayoutScreen extends StatefulWidget {
  const AppLayoutScreen({super.key});

  @override
  State<AppLayoutScreen> createState() => _AppLayoutScreenState();
}

class _AppLayoutScreenState extends State<AppLayoutScreen> {
  final CSharedPreferencesServices _sharedPreferencesServices = CSharedPreferencesServices();
  late AppInfoProvider _appInfoProvider;
  late bool _miniSidebar;
  // late bool _showMoreInfo;
  bool _showLogoutPopup = false;


  @override
  void initState() {
    super.initState();
    setSavedSidebarData();
  }

  Future<void> _toggleMiniSidebar() async {
    // if (!_miniSidebar) {
    //   setState(() {
    //     _showMoreInfo = !_showMoreInfo;
    //     _miniSidebar = _sharedPreferencesServices.getBool(CSharedPrefsKeys.showMiniSideBar)!;
    //   });
    // } else {
    //   // setState(() => _miniSidebar = _sharedPreferencesServices.getBool(CSharedPrefsKeys.showMiniSideBar)!);
    //   // await Future.delayed(Duration(milliseconds: 150));
    //   if (!mounted) return;
      
    //   setState(() => _showMoreInfo = !_showMoreInfo);
    // }
    setState(() => _miniSidebar = !_miniSidebar);
    _sharedPreferencesServices.setBool(CSharedPrefsKeys.showMiniSideBar, _miniSidebar);

    // await Future.delayed(Duration(milliseconds: 150));
    // if (mounted) setState(() => _showMoreInfo = !_showMoreInfo);
  }

  void _toggleShowLogout() {
    setState(() => _showLogoutPopup = !_showLogoutPopup);
  }

  Future<void> _handleLogout() async {
    _appInfoProvider = Provider.of<AppInfoProvider>(context, listen: false);
    final logout = await _appInfoProvider.userLogout();
    if (!mounted) return;
    logout ? _goBack() : null;
  }

  void _goBack() {
    Navigator.canPop(context) ? Navigator.pop(context) : 
    CHelperFunctions.navigateToScreen(context: context, screen: App(), replacement: true);
  }

  Future<void> setSavedSidebarData() async {
    final miniSide = _sharedPreferencesServices.getBool(CSharedPrefsKeys.showMiniSideBar)!;
    setState(() {
      _miniSidebar = miniSide;
      // _showMoreInfo = !miniSide;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppRoutesProvider, AppInfoProvider>(
      builder: (context, routesProvider, infoProvider, child) {
        if (infoProvider.currentUser == null) {
          return Scaffold(
            body: Center(
              child: UiNoDataFounded(
                addAnimation: false,
                title: 'user data is not founded',
                onButtonClick: infoProvider.getAuthStatusEnum,
              ),
            ),
          );
        }

        return Scaffold(
          body: Stack(
            children: [
        
              // - - - - - -
              // - - - M A I N _ S C R E E N
              // - - - - - -
              Row(
                children: [
                  // - - - S I D E B A R
                  SideBarWidget(
                    routes: routesProvider.appRoutes, 
                    activeRouteIndex: routesProvider.activeRouteIndex, 
                    onRouteClick: (index) => routesProvider.changeActiveRouteIndex(index), 
                    userData: infoProvider.currentUser!, 
                    miniSidebar: _miniSidebar, 
                    toggleMiniSidebar: _toggleMiniSidebar, 
                    logoutClick: _toggleShowLogout,
                  ),
                
                  // - - - S C R E E N S
                  Expanded(
                    child: routesProvider.appRoutes[routesProvider.activeRouteIndex].element,
                  )
                ],
              ),

              
              // - - - - - -
              // - - - L O G O U T _ P O P U P
              // - - - - - -
              if (_showLogoutPopup) UiPopupWidget(
                message: 'do you want to logout!', 
                primaryText: 'logout', 
                primaryClick: _handleLogout, 
                secondaryText: 'cancel',
                secondaryClick: _toggleShowLogout,
                outSideClick: _toggleShowLogout
              ),

            ],
          ),
        );

      }
    );
  }
}