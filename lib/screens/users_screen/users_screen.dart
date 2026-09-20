import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/data_tables/users_data_table.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/users_provider.dart';
import 'package:shafici_pos/screens/users_screen/register_user_screen.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:provider/provider.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UsersScreen> {
  bool _canEdit = false;
  final TextEditingController _searchController = TextEditingController();
  List<UserModel> _filteredUserList = [];


  // - - - - - - >>
  // - - - F U N C T I O N S
  void refreshUsersData() {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    usersProvider.setUsers();
  }

  void _handleSearch(String? value) {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    if (value == null) {
      _filteredUserList.clear();
    } else {
      _filteredUserList = usersProvider.userList.where((u) => u.firstName.toLowerCase().contains(value.toLowerCase())).toList();
    }
    setState(() {});
  }

  void _handleSearchReset() {
    setState(() {
      _filteredUserList.clear();
      _searchController.clear();
    });
  }

  void _handleNavigateToRegister() {
    _canEdit ? CHelperFunctions.navigateToScreen(context: context, screen: RegisterUserScreen()) : null;
  }
  // - - - F U N C T I O N S
  // - - - - - - >>

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
    final UserModel userData = appInfoProvider.currentUser!;
    setState(() => _canEdit = userData.userRole == 'admin' && userData.canEditInventory);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: CSizes.largeGap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: CSizes.largeGap,),
        
            UiTitleWidget(
              text: 'Users',
              bigger: true,
            ),
        
            SizedBox(height: CSizes.largeGap,),
        
            // - - - T O P _ S E C T I O N
            _topSectionMethod(),


            SizedBox(height: CSizes.largeGap,),


            // - - - U S E R S _ T A B L E
            Expanded(
              child: Consumer<UsersProvider>(
                builder: (context, provider, child) {
                  // - - - L O A D I N G
                  if (provider.isLoading) return UiLoadingScreenWidget();
              
                  // - - - E R R O R
                  if (provider.errorMessage != null) {
                    return UiPopupWidget(
                      message: provider.errorMessage!, 
                      primaryText: 'seach again', 
                      primaryClick: provider.setUsers, 
                      outSideClick: () {},
                      isDimmed: false,
                    );
                  }
              
                  // - - - N O _ U S E R S
                  if (provider.userList.isEmpty) {
                    return UiNoDataFounded(
                      title: 'no user is registered',
                      buttonText: 'register now',
                      onButtonClick: _handleNavigateToRegister,
                      noDataAnimation: CAnimations.emptyList,
                    );
                  }
                  
                  // USERS _ T A B L E
                  return UsersDataTable(
                    userList: _searchController.text.isNotEmpty ? _filteredUserList : provider.userList,
                    onSearchAgainClick: _handleSearchReset,
                    canEdit: _canEdit,
                    onBackCall: () {},
                  );
                },
              ),
            ),

            SizedBox(height: CSizes.largeGap,),


          ],
        ),
      ),
    );
  }

  IntrinsicHeight _topSectionMethod() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, 
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: UiTextFieldWidget(
                  label: 'Search User Name',
                  defaultLabel: true,
                  textController: _searchController,
                  onChange: (value) => _handleSearch(value),
                ),
              ),

              SizedBox(width: CSizes.mediumGap,),

              if (_searchController.text.isNotEmpty) UiButtonWidget(
                icon: CIcons.eraseIcon,
                vericalPadding: CSizes.smallGap,
                horizontalPadding: CSizes.smallGap,
                onClick: _handleSearchReset,
              )
            ],
          ),
      
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              UiButtonWidget(
                text: 'register user',
                icon: CIcons.addIcon, 
                vericalPadding: CSizes.smallGap,
                isDisabled: !_canEdit,
                onClick: _handleNavigateToRegister
              ), 
          
              SizedBox(width: CSizes.mediumGap,),
          
              UiButtonWidget(
                icon: CIcons.refreshIcon,
                vericalPadding: CSizes.smallGap,
                horizontalPadding: CSizes.smallGap,
                tranparent: true,
                borderColor: CColors.primaryColor,
                onClick: refreshUsersData
              )
            ],
          ),
        ],
      ),
    );
  }
}