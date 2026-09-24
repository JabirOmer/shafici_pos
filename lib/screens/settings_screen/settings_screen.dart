import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/setting_tile_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/web_socket_server_provider.dart';
// import 'package:shafici_pos/providers/web_socket_server_provider.dart';
import 'package:shafici_pos/screens/settings_screen/widgets/change_exchange_rate_widget.dart';
import 'package:shafici_pos/screens/settings_screen/widgets/change_pin_widget.dart';
import 'package:shafici_pos/screens/settings_screen/widgets/change_port_popup_widget.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/ui/ui_toggle_button_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<SettingTileModel> _merchantInfoSettingsList = [];
  List<SettingTileModel> _userInfoSettingsList = [];
  List<SettingTileModel> _salesRelatedSettingsList = [];
  List<SettingTileModel> _displayInfoSettingsList = [];
  List<SettingTileModel> _redZoneSettingsList = [];

  final CApiServices _apiServices = CApiServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();

  bool _showchangePINPopup = false;
  bool _showExchangePopup = false;
  bool _showChangePortPopup = false;
  bool _showAppRevokePopup = false;

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  // - - - - - - >>
  // - - - F U N C T I O N S
  // void _setSettingsData() {
  //   final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
  //   final WebSocketServerProvider webSocketServerProvider = Provider.of(context, listen: false);
    
  //   final int serverClientsCount = webSocketServerProvider.clientCount;
  //   final bool serverIsRunning = webSocketServerProvider.serverStatus == ServerStatus.running;

  //   setState(() {
  //     _merchantInfoSettingsList = [
  //       SettingTileModel(icon: CIcons.branchesIcon, title: 'Business name', value: appInfoProvider.deviceData?.businessName ?? '---',),
  //       SettingTileModel(icon: CIcons.branchesIcon, title: 'Branch name', value: appInfoProvider.deviceData?.branchName ?? '---',),
  //       SettingTileModel(icon: CIcons.branchesIcon, title: 'Add VAT', toggleValue: appInfoProvider.calculateVAT, onClick: appInfoProvider.toggleVAT),
  //       SettingTileModel(icon: CIcons.branchesIcon, title: 'Exchange rate', onClick: _toggleExchangePopup),
  //     ];

  //     _userInfoSettingsList = [
  //       SettingTileModel(icon: CIcons.profileIcon, title: 'Full name', value: '${appInfoProvider.currentUser?.firstName} ${appInfoProvider.currentUser?.middleName} ${appInfoProvider.currentUser?.lastName}'),
  //       SettingTileModel(icon: CIcons.phoneIcon, title: 'Phone number', value: appInfoProvider.currentUser?.phoneNumber),
  //       SettingTileModel(icon: CIcons.profileTag, title: 'Role', value: appInfoProvider.currentUser?.userRole),
  //       SettingTileModel(icon: CIcons.lockIcon, title: 'Change password', onClick: _toggleChangePassword)
  //     ];

  //     _displayInfoSettingsList = [
  //       SettingTileModel(icon: CIcons.linkIcon, title: _getServerStatus(webSocketServerProvider.serverStatus), toggleValue: serverIsRunning, onClick: () async { await webSocketServerProvider.toggleConnection(); }),
  //       SettingTileModel(icon: CIcons.linkIcon, title: 'Address', value: '---', onClick: () {}),
  //       SettingTileModel(icon: CIcons.linkIcon, title: 'PORT', value: '4040', onClick: _toggleChangePort),
  //     ];

  //     _redZoneSettingsList = [
  //       SettingTileModel(icon: CIcons.logoutIcon, title: 'Logout', onClick: () {}),
  //       SettingTileModel(icon: CIcons.warningIcon, title: 'Revoke app', onClick: _toggleShowAppRevokePopup)
  //     ];
  //   });
  // }

  void _toggleChangePassword() {
    setState(() => _showchangePINPopup = !_showchangePINPopup);
  }

  void _toggleExchangePopup() {
    setState(() => _showExchangePopup = !_showExchangePopup);
  }

  void _toggleChangePort() {
    setState(() => _showChangePortPopup = !_showChangePortPopup);
  }

  void _toggleShowAppRevokePopup() {
    setState(() => _showAppRevokePopup = !_showAppRevokePopup);
  }

  String _getServerStatus(ServerStatus status) {
    switch (status) {
      case ServerStatus.starting: return '...';
      case ServerStatus.running: return 'Server is ( ON )';
      case ServerStatus.stopping: return '...';
      case ServerStatus.stopped: return 'Server is ( OFF )';
      case ServerStatus.error: return 'Failed to start server';
    }
  }

  Future<void> _handleAppRevoke() async {
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
    setState(() => _isLoading = true);

    setState(() => _showAppRevokePopup = !_showAppRevokePopup);

    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.patchRequest(url: CUrlStrings.deviceRevokeUrl, data: {}, authToken: deviceToken);

      switch (response.statusCode) {
        case 200: appInfoProvider.revokeDevice();
        default: _errorMessage = response.data;
      }

    } catch (e) {
      _errorMessage = 'failed to revoke app';
    } finally {
      setState(() => _isLoading = false);
      await Future.delayed(Duration(seconds: 2));
      if (mounted) setState(() => _errorMessage = null,);
      // if (mounted) _successMessage != null ? appInfoProvider.revokeDevice() : setState(() => _errorMessage = null,);
    }
  }
  // - - - F U N C T I O N S
  // - - - - - - >>


  // - - - - - -

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _setSettingsData();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final appInfoProvider = context.watch<AppInfoProvider>();
    final webSocketServerProvider = context.watch<WebSocketServerProvider>();
    
    final int serverClientsCount = webSocketServerProvider.clientCount;
    final bool serverIsRunning = webSocketServerProvider.serverStatus == ServerStatus.running;

    _merchantInfoSettingsList = [
      SettingTileModel(icon: CIcons.homeLine, title: 'Business name', value: appInfoProvider.deviceData?.businessName ?? '---',),
      SettingTileModel(icon: CIcons.addIcon, title: 'Business type', value: appInfoProvider.deviceData?.businessType ?? '---',),
      SettingTileModel(icon: CIcons.branch, title: 'Current branch name', value: appInfoProvider.deviceData?.branchName ?? '---',),
    ];

    _salesRelatedSettingsList = [
      SettingTileModel(icon: CIcons.walletOut, title: 'Add VAT', toggleValue: appInfoProvider.calculateVAT, onClick: appInfoProvider.toggleVAT),
      SettingTileModel(icon: CIcons.refreshIcon, title: 'Update exchange rate', onClick: _toggleExchangePopup),
    ];

    _userInfoSettingsList = [
      SettingTileModel(icon: CIcons.profileIcon, title: 'Full name', value: '${appInfoProvider.currentUser?.firstName} ${appInfoProvider.currentUser?.middleName} ${appInfoProvider.currentUser?.lastName}'),
      SettingTileModel(icon: CIcons.phoneIcon, title: 'Phone number', value: appInfoProvider.currentUser?.phoneNumber),
      SettingTileModel(icon: CIcons.profileTag, title: 'Role', value: appInfoProvider.currentUser?.userRole),
      SettingTileModel(icon: CIcons.lockIcon, title: 'Change password', onClick: _toggleChangePassword)
    ];

    _displayInfoSettingsList = [
      SettingTileModel(
        icon: CIcons.link, 
        title: _getServerStatus(webSocketServerProvider.serverStatus), 
        toggleValue: serverIsRunning, 
        toggleIsLoading: [ServerStatus.starting, ServerStatus.stopping].contains(webSocketServerProvider.serverStatus),
        onClick: () async { await webSocketServerProvider.toggleConnection(); }
      ),
      SettingTileModel(
        icon: CIcons.location, 
        title: 'Address', 
        value: webSocketServerProvider.serverStatus == ServerStatus.running ? (webSocketServerProvider.serverAddress ?? '---') : 'no address'
      ),
      SettingTileModel(
        icon: CIcons.hashtag, 
        title: 'PORT', 
        value: CSharedPreferencesServices().getString(CSharedPrefsKeys.socketPort) ?? '4040', 
        onClick: webSocketServerProvider.serverStatus == ServerStatus.running ? null : _toggleChangePort
      ),
    ];

    _redZoneSettingsList = [
      SettingTileModel(icon: CIcons.warningIcon, title: 'Revoke app', onClick: _toggleShowAppRevokePopup)
    ];

    return Scaffold(
      body: Stack(
        children: [
          // // - - - S E T T I N G S _ L I S T
          // mainSettingsWindowMethod(
          //   appInfoProvider,
          //   webSocketServerProvider
          // ),

          // - - - S E T T I N G S _ L I S T
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints( maxWidth: 1000 ),
              child: ListView(
                padding: EdgeInsets.all(CSizes.largeGap),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      UiTitleWidget(text: 'Settings', bigger: true,),
                      
                      SizedBox(height: CSizes.largeGap,),
            
                      _settingsGroupMethod(
                        title: 'Merchant',
                        tileList: _merchantInfoSettingsList
                      ),
                  
                      SizedBox(height: CSizes.largeGap,),

                      _settingsGroupMethod(
                        title: 'sales related',
                        tileList: _salesRelatedSettingsList
                      ),
                  
                      SizedBox(height: CSizes.largeGap,),
                  
                      _settingsGroupMethod(
                        title: 'User info',
                        tileList: _userInfoSettingsList
                      ),
                      
                      SizedBox(height: CSizes.largeGap,),
                  
                      _settingsGroupMethod(
                        title: 'Customer display',
                        tileList: _displayInfoSettingsList
                      ),
                  
                      SizedBox(height: CSizes.largeGap,),
                  
                      _settingsGroupMethod(
                        title: 'Red zone',
                        tileList: _redZoneSettingsList,
                        isDangerZone: true
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),



          
          // - - - C H A N G E _ P A S S W O R D
          if (_showchangePINPopup) ChangePinWidget(
            onCancel: _toggleChangePassword
          ),

          
          // - - - C H A N G E _ E X C H A N G E
          if (_showExchangePopup) ChangeExchangeRateWidget(
            onCancel: _toggleExchangePopup,
          ),


          // - - - C H A N G E _ P O R T
          if (_showChangePortPopup) ChangePortPopupWidget(
            onCancel: _toggleChangePort,
          ),
      
          
          // - - - A P P _ D E T E L E
          if (_showAppRevokePopup) UiPopupWidget(
            message: "do you want to revoke app's connection", 
            primaryText: _isLoading ? 'loading...' : 'continue', 
            primaryClick: _handleAppRevoke, 
            secondaryText: 'back',
            secondaryClick: _toggleShowAppRevokePopup,
            outSideClick: _toggleShowAppRevokePopup,
            isDisabled: _isLoading || _successMessage != null,
            iconColor: CColors.red,
          ),


          // - - - S U C C E S S _ P O P U P
          if (_successMessage != null) UiPopupWidget(
            isSuccess: true,
            message: _successMessage!, 
            primaryText: 'ok', 
            primaryClick: () {}, 
            outSideClick: () {}
          ),
          
          
          // - - - E R R O R _ P O P U P
          if (_errorMessage != null) UiPopupWidget(
            message: _errorMessage!, 
            primaryText: 'try again', 
            primaryClick: () {}, 
            outSideClick: () {}
          ),


          // - - - L O A D I N G
          if (_isLoading) UiLoadingScreenWidget(
            fullScreen: true,
            transparent: true,
          )
        ],
      ),
    );
  }





  // - - - - M E T H O D S - - - -





  Column _settingsGroupMethod({
    required String title,
    required List<SettingTileModel> tileList,
    bool isDangerZone = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiTitleWidget(text: title, color: isDangerZone ? CColors.red : null, bold: false,),

        SizedBox(height: CSizes.smallGap,),

        Container(
          decoration: BoxDecoration(
            color: CColors.white,
            border: Border.all(width: 1, color: isDangerZone ? CColors.red : CColors.white, strokeAlign: BorderSide.strokeAlignOutside),
            borderRadius: BorderRadius.circular(CSizes.largeGap)
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => _appSettingTile(tile: tileList[index]), 
            separatorBuilder: (context, index) => Container(height: 1, color: CColors.whiteShade2, margin: EdgeInsets.only(left: 40),), 
            itemCount: tileList.length
          )
        )
      ],
    );
  }




  // - - - A P P _ S E T T I N G _ T I L E
  GestureDetector _appSettingTile({
    required SettingTileModel tile,
  }) {
    return GestureDetector(
      onTap: () {
        if (tile.toggleValue != null) return;
        if (tile.onClick != null) tile.onClick!();
      },
      child: Container(
        color: CColors.transparent,
        // padding: EdgeInsets.symmetric(vertical: CSizes.largeGap),
        padding: EdgeInsets.symmetric(horizontal: CSizes.largeGap, vertical: CSizes.largeGap),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // - - - Icon
                  SvgPicture.asset(
                    tile.icon, 
                    height: 20, 
                    colorFilter: ColorFilter.mode(CColors.black, BlendMode.srcIn),
                  ),
          
                   SizedBox(width: CSizes.mediumGap,),
          
                  // - - - Title
                  UiTitleWidget(text: tile.title, defaultText: true, bold: false,),
                ],
              ),
          
              Row(
                children: [
                  if (tile.value != null) UiTitleWidget(text: tile.value!, color: CColors.blackShade2, capitalizeWords: true, bold: false,), 

                  if (tile.onClick != null && tile.toggleValue == null) Container(
                    margin: EdgeInsets.only(left: CSizes.smallGap),
                    child: SvgPicture.asset(
                      CIcons.arrowToRight, 
                      height: 18, 
                      colorFilter: ColorFilter.mode(CColors.blackShade2, BlendMode.srcIn),
                    ),
                  ),

                  if (tile.toggleValue != null) UiToggleButtonWidget(
                    isOn: tile.toggleValue!, 
                    isDisabled: tile.onClick == null,
                    isLoading: tile.toggleIsLoading,
                    onClick: () {
                      if (tile.onClick != null) {
                        tile.onClick!();
                        // _setSettingsData();
                      }
                    }
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }





  // - M E T H O D _ 1.0
  SingleChildScrollView mainSettingsWindowMethod(AppInfoProvider appInfoProvider, WebSocketServerProvider webSocketServerProvider) {
    final int clientsCount = webSocketServerProvider.clientCount;
    final bool isRunning = webSocketServerProvider.serverStatus == ServerStatus.running;

    return SingleChildScrollView(
        child: Padding(
          padding: EdgeInsetsGeometry.all(CSizes.largeGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [            
              UiTitleWidget(
                text: 'settings',
                bigger: true,
              ),
      
              SizedBox(height: CSizes.largeGap,),
      
              // - - - S E T T I N G S _ D I S P L A Y
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // - - - Personal Information
                      UiTitleWidget(
                        text: 'personal information',
                        bold: false,
                        color: CColors.whiteShade3,
                      ),
                
                      SizedBox(height: CSizes.mediumGap,),
                      
                      // - - - User Name
                      settingTileDisplayMethod(
                        icon: CIcons.profileIcon,
                        title: 'full name', 
                        value: '${appInfoProvider.currentUser!.firstName} ${appInfoProvider.currentUser!.middleName} ${appInfoProvider.currentUser!.lastName}'
                      ),
                
                      SizedBox(height: CSizes.mediumGap,),
                
                      // - - - phone number
                      settingTileDisplayMethod(
                        icon: CIcons.phoneIcon,
                        title: 'phone number', 
                        value: appInfoProvider.currentUser!.phoneNumber
                      ),
                
                      SizedBox(height: CSizes.mediumGap,),
                
                      // - - - user roles
                      settingTileDisplayMethod(
                        icon: CIcons.profileTag,
                        title: 'user role', 
                        value: appInfoProvider.currentUser!.userRole
                      ),
                
                      SizedBox(height: CSizes.mediumGap,),

                      // - - - Inventoy management
                      settingTileDisplayMethod(
                        icon: CIcons.bagIcon,
                        isToggle: true,
                        toggleValue: appInfoProvider.currentUser!.canEditInventory,
                        isDisabled: true,
                        value: 'inventory manager'
                      ),
                
                      SizedBox(height: CSizes.mediumGap,),
                
                      // - - - change password
                      settingTileDisplayMethod(
                        icon: CIcons.lockIcon,
                        value: 'change PIN', 
                        onClick: _toggleChangePassword
                      ),
                      
                      SizedBox(height: CSizes.xLargeGap,),
                      
                      // - - - Others
                      UiTitleWidget(
                        text: 'others',
                        bold: false,
                        color: CColors.whiteShade3,
                      ),

                      SizedBox(height: CSizes.mediumGap,),

                      settingTileDisplayMethod(
                        value: 'change exchange rate',
                        onClick: _toggleExchangePopup
                      ),

                      SizedBox(height: CSizes.mediumGap,),

                      // - - - A d d _ V A T
                      settingTileDisplayMethod(
                        icon: CIcons.bagIcon,
                        isToggle: true,
                        toggleValue: appInfoProvider.calculateVAT,
                        toggleClick: appInfoProvider.toggleVAT,
                        value: 'add vat'
                      ),

                      SizedBox(height: CSizes.mediumGap,),
                      
                      
                      // - - - W E B _ S O C K E T
                      Container(
                        decoration: BoxDecoration(
                          color: CColors.whiteShade2,
                          borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                        ),
                        padding: EdgeInsets.all(CSizes.largeGap),
                        child: Column(
                          children: [

                            // - - - Toggle Server Connection
                            settingTileDisplayMethod(
                              value: '${_getServerStatus(webSocketServerProvider.serverStatus)} ${isRunning ? '( clients: $clientsCount )' : ''}', 
                              isToggle: true, 
                              toggleIsLoading: [ServerStatus.starting, ServerStatus.stopping].contains(webSocketServerProvider.serverStatus),
                              toggleValue: webSocketServerProvider.serverStatus == ServerStatus.running,
                              toggleClick: webSocketServerProvider.toggleConnection, 
                            ),
                      
                            SizedBox(height: CSizes.mediumGap,),

                            // - - - Port Change
                            settingTileDisplayMethod(
                              icon: CIcons.linkIcon,
                              value: 'Socket PORT: ${CSharedPreferencesServices().getString(CSharedPrefsKeys.socketPort) ?? '4040'}',
                              onClick: webSocketServerProvider.serverStatus != ServerStatus.running ? _toggleChangePort : null
                            ),

                            SizedBox(height: CSizes.mediumGap,),

                            // - - - Socket Adrress Display
                            Container(
                              decoration: BoxDecoration(
                                color: CColors.white,
                                borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                              ),
                              padding: EdgeInsets.all(CSizes.largeGap),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: (webSocketServerProvider.serverAddress != null && webSocketServerProvider.serverStatus == ServerStatus.running) ? CColors.green : CColors.redDimmed,
                                          borderRadius: BorderRadius.circular(CSizes.mediumGap)
                                        ),
                                        padding: EdgeInsets.all(CSizes.mediumGap),
                                      ),
                                      SizedBox(width: CSizes.smallGap,),
                                      UiTitleWidget(text: 'Server address: ', bold: false,)
                                    ],
                                  ),
                            
                                  UiTitleWidget(
                                    text: webSocketServerProvider.serverStatus == ServerStatus.running ? webSocketServerProvider.serverAddress ?? 'no address is founded' : 'no address',
                                    bold: false,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: CSizes.mediumGap,),

                      // settingTileDisplayMethod(value: 'Include VAT', isDisabled: true, defaultText: true, isToggle: true, toggleValue: appInfoProvider.calculateVAT),
                
                      // SizedBox(height: CSizes.mediumGap,),

                      // settingTileDisplayMethod(value: 'On Discount', isDisabled: true, defaultText: true, isToggle: true, toggleValue: appInfoProvider.onDiscount, ),
                
                      // SizedBox(height: CSizes.mediumGap,),

                      Container(
                        decoration: BoxDecoration(
                          color: CColors.white,
                          // border: Border.all(width: 1, color: CColors.green),
                          borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                        ),
                        padding: EdgeInsets.all(CSizes.largeGap),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SvgPicture.asset(
                                  CIcons.branchesIcon,
                                ),

                                SizedBox(width: CSizes.mediumGap,),

                                UiTitleWidget(text: 'branch: ', bold: false,)
                              ],
                            ),
                      
                            UiTitleWidget(
                              text: appInfoProvider.deviceData?.branchName ?? '---',
                              bold: false,
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: CSizes.mediumGap,),
                
                      Container(
                        decoration: BoxDecoration(
                          color: CColors.white,
                          borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
                          border: Border.all(width: 1, color: CColors.redDimmed)
                        ),
                        padding: EdgeInsets.all(CSizes.largeGap),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            UiTitleWidget(
                              text: 'revoke app connection',
                              bold: false,
                            ),
                
                            UiButtonWidget(
                              icon: CIcons.trashIcon,
                              horizontalPadding: CSizes.smallGap,
                              // color: CColors.black,
                              backgroundColor: CColors.redDimmed,
                              vericalPadding: CSizes.smallGap,
                              onClick: () => setState(() => _showAppRevokePopup = true,)
                            )
                          ],
                        ),
                      ),
                
                
                    ],
                  ),
                ),
              )
      
            ],
          ),
        ),
      );
  }





  // - M E T H O D _ 1.1
  Container settingTileDisplayMethod({
    String? icon,
    String? title, 
    required String value,
    void Function()? onClick,
    bool addNext = false,
    bool isDisabled = false,
    bool defaultText = false,
    Color? iconBackgroundColor,
    bool isToggle = false,
    bool? toggleValue,
    void Function()? toggleClick,
    bool toggleIsLoading = false
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDisabled ? CColors.whiteShade2 : CColors.white,
        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
      ),
      padding: EdgeInsets.symmetric(vertical: CSizes.largeGap, horizontal: CSizes.largeGap),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          
          Row(
            children: [
              if (icon != null) SvgPicture.asset(
                icon,
                colorFilter: ColorFilter.mode(CColors.black, BlendMode.srcIn),
              ),

              if (icon != null)  SizedBox(width: CSizes.mediumGap,),

              UiTitleWidget(
                text: value,
                bold: false,
                capitalizeWords: !defaultText,
                defaultText: defaultText,
                color: isDisabled ? CColors.whiteShade3 : null,
              ),
            ],
          ),


          if (onClick != null) UiButtonWidget(
            icon: CIcons.arrowToRight,
            vericalPadding: CSizes.smallGap,
            horizontalPadding: CSizes.smallGap,
            tranparent: true,
            onClick: onClick
          ),

          if (isToggle && toggleValue != null) UiToggleButtonWidget(
            isOn: toggleValue,
            onClick: toggleClick ?? () {},
            isDisabled: isDisabled,
            isLoading: toggleIsLoading,
          )
        ],
      ),
    );
  }

}