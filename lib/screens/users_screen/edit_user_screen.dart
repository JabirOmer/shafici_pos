import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shafici_pos/app.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/user_model.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/users_provider.dart';
import 'package:shafici_pos/screens/app_layout_screens/responsive_app_layout_screen.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_drop_down_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:shafici_pos/ui/ui_toggle_button_widget.dart';
import 'package:provider/provider.dart';

class EditUserScreen extends StatefulWidget {
  final UserModel userData;
  final void Function() onBackClick;

  const EditUserScreen({
    super.key,
    required this.userData,
    required this.onBackClick,
  });

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late UsersProvider _usersProvider;
  late UserModel _currentUser;
  late bool _canEdit;
  late Map<String, String> _userRolesMap;
  late bool _isActive;
  late bool _permitedToEdit;

  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  String? _selectedRole;
  bool _openDropDown = false;
  // final bool _showDeletePopup = false;

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  final usernameRegex = RegExp(r'^[A-Za-z-]+$');
  final digitsOnlyRegex = RegExp(r'^\d+$');

  final GlobalKey _appBarKey = GlobalKey();
  double _appBarHeight = 0;

  // - - - - - - >>
  // - - - V A L I D A T I O N S
  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!usernameRegex.hasMatch(value)) return 'Name can only contain letters and hyphens (-).';
    return null;
  }
  String? _validateMiddleName(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!usernameRegex.hasMatch(value)) return 'Name can only contain letters and hyphens (-).';
    return null;
  }
  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!usernameRegex.hasMatch(value)) return 'Name can only contain letters and hyphens (-).';
    return null;
  }
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!digitsOnlyRegex.hasMatch(value)) return 'Only digits (0-9) are allowed.';
    if (int.tryParse(value) == null) return 'invalid phone number';
    return null;
  }
  String? _validatePIN(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!digitsOnlyRegex.hasMatch(value)) return 'Only digits (0-9) are allowed.';
    if (int.tryParse(value) == null) return 'invalid phone number';
    if (value.length != 4) return 'PIN should be 4 digits';
    return null;
  }
  // - - - V A L I D A T I O N S
  // - - - - - - >>


  // - - - - - - >>
  // - - - F U N C T I O N S
  void _handleDropDownToggle() {
    setState(() => _openDropDown = !_openDropDown);
  }
  void _handleDropDownOptionClick(String role) {
    setState(() => _selectedRole = role);
    _handleDropDownToggle();
  }

  void _generateRandomPIN() {
    final random = Random();
    final pin = 1000 + random.nextInt(9000);
    setState(() => _pinController.text = pin.toString(),);
  }

  Future<void> _handleFormSubmit() async {
    if (!_canEdit) return setState(() => _errorMessage = 'you are not allowed to edit',);
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true,);
      try {
        final dataMap = UserModel(
          userId: widget.userData.userId, 
          firstName: _firstNameController.text.isEmpty ? widget.userData.firstName : _firstNameController.text.trim().toLowerCase(), 
          middleName: _middleNameController.text.isEmpty ? widget.userData.middleName : _middleNameController.text.trim().toLowerCase(), 
          lastName: _lastNameController.text.isEmpty ? widget.userData.lastName : _lastNameController.text.trim().toLowerCase(), 
          phoneNumber: _phoneNumberController.text.isEmpty ? widget.userData.phoneNumber : _phoneNumberController.text.trim().toLowerCase(), 
          userRole: _selectedRole == null ? widget.userData.userRole : _selectedRole!, 
          isActive: _isActive,
          canEditInventory: _permitedToEdit
        ).toJson();
        dataMap.addAll({ "password": _pinController.text.isEmpty ? null : _pinController.text.trim() });

        final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
        final response = await _apiServices.patchRequest(url: CUrlStrings.updateUserDataUrl, data: dataMap, authToken: deviceToken);
        
        switch (response.statusCode) {
          case 200: {
            _successMessage = response.data['msg'];
            await _usersProvider.setUsers();
            if (widget.userData.userId == _currentUser.userId) { 
              await appInfoProvider.userLogout();
              if (!mounted) return;
              CHelperFunctions.navigateToScreen(context: context, screen: App(), replacement: true);
            }
          }
          default: _errorMessage = response.data;
        }


      } catch (e) {
         _errorMessage = 'failed to register user';
      } finally {
        setState(() => _isLoading = false,);
      }
    }
  }

  void _closeSuccessPopup() {
    setState(() => _successMessage = null);
    _handleBack();
  }

  void _closeErrorPopup() {
    setState(() => _errorMessage = null);
  }

  void _handleBack() {
    Navigator.canPop(context) ? Navigator.pop(context) 
    : CHelperFunctions.navigateToScreen(
      context: context, 
      screen: ResponsiveAppLayoutScreen(), 
      replacement: true
    );
  }

  // void _showDeletePopupToggle() {
  //   setState(() => _showDeletePopup = !_showDeletePopup);
  // }

  // Future<void> _handleUserDelete() async {
  //   _showDeletePopupToggle();

  //   if (!_canEdit) return setState(() => _errorMessage = 'you are not allowed to edit',);
  //   final UsersProvider usersProvider = Provider.of(context, listen: false);

  //   setState(() {
  //     _isLoading = true;
  //     _successMessage = null;
  //     _errorMessage = null;  
  //   });
    
  //   try {
  //     final dataMap = { "user_id": widget.userData.userId };
  //     final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
  //     final response = await _apiServices.deleteRequest(url: CUrlStrings.deleteUserUrl, data: dataMap, authToken: deviceToken);
  //     if (!mounted) return;
      
  //     switch (response.statusCode) {
  //       case 200: {
  //         _successMessage = response.data['msg'];
  //         usersProvider.setUsers();
  //       }

  //       default: _errorMessage = response.data;
  //     }
  //   } catch (e) {
  //     _errorMessage = 'failed to delete user';
  //   } finally {
  //     setState(() => _isLoading = false,);
  //   }
  // }
  // - - - F U N C T I O N S
  // - - - - - - >>


  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox = _appBarKey.currentContext?.findRenderObject() as RenderBox?;
      double height = renderBox?.size.height ?? 0;
      setState(() => _appBarHeight = height,);
    });
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _usersProvider = Provider.of(context, listen: false);
    final AppInfoProvider appInfoProvider = Provider.of(context, listen: false);
    // final currentUser = appInfoProvider.currentUser;

    setState(() {
      _currentUser = appInfoProvider.currentUser!;
      _userRolesMap = _usersProvider.rolesMap;
      _isActive = widget.userData.isActive;
      _permitedToEdit = widget.userData.canEditInventory;
      _canEdit = _currentUser.userRole == UserRolesEnum.admin.name;
    });
  }


  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
      
          // - - - M A I N _ W I N D O W
          Scaffold(
            appBar: AppBar(
              key: _appBarKey,
            ),
            body: _updateUserFormMethod(context)
          ),
      
          // // - - - D E L E T E _ P O P U P
          // if (_showDeletePopup) UiPopupWidget(
          //   message: "this action can't be undone !", 
          //   primaryText: 'continue', 
          //   primaryClick: _handleUserDelete, 
          //   secondaryText: 'back',
          //   secondaryClick: _showDeletePopupToggle,
          //   outSideClick: _showDeletePopupToggle,
          // ),
      
          // - - - S U C C E S S _ P O P U P
          if (_successMessage != null) UiPopupWidget(
            isSuccess: true,
            message: _successMessage!, 
            primaryText: 'ok', 
            primaryClick: _closeSuccessPopup, 
            outSideClick: _closeSuccessPopup
          ),
      
          // - - - E R R O R _ P O P U P
          if (_errorMessage != null) UiPopupWidget(
            message: _errorMessage!, 
            primaryText: 'ok', 
            primaryClick: _closeErrorPopup, 
            outSideClick: _closeErrorPopup
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





  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -





  // - - - E D I T _ U S E R _ F O R M
  SingleChildScrollView _updateUserFormMethod(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - _appBarHeight),
        child: Padding(
          padding: EdgeInsets.only(bottom: CSizes.xLargeGap),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          
          
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1000,),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColors.white,
                      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                    ),
                    padding: EdgeInsets.all(CSizes.largeGap),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                  
                          // - - - T I T L E
                          UiTitleWidget(
                            text: 'Edit user',
                            bigger: true,
                          ),
                  
                          SizedBox(height: CSizes.largeGap,),
              
                          UiTitleWidget(
                            text: 'basic info',
                          ),
              
                          SizedBox(height: CSizes.largeGap,),
                
                          _editUserTitle(
                            controller: _firstNameController, 
                            label1: 'first name', 
                            label2: 'new first name', 
                            initial: CHelperFunctions.capitalizeWords(widget.userData.firstName), 
                            validator: (value) => _validateFirstName(value), 
                            onChange: (value) {},
                          ),
              
                          SizedBox(height: CSizes.largeGap,),
              
                          _editUserTitle(
                            controller: _middleNameController, 
                            label1: 'middle name', 
                            label2: 'new middle name', 
                            initial: CHelperFunctions.capitalizeWords(widget.userData.middleName), 
                            validator: (value) => _validateMiddleName(value), 
                            onChange: (value) {},
                          ),
              
                          SizedBox(height: CSizes.largeGap,),
              
                          _editUserTitle(
                            controller: _lastNameController, 
                            label1: 'last name', 
                            label2: 'new last name', 
                            initial: CHelperFunctions.capitalizeWords(widget.userData.lastName), 
                            validator: (value) => _validateLastName(value), 
                            onChange: (value) {},
                          ),
              
                          SizedBox(height: CSizes.largeGap,),
              
                          // - - - U S E R _ R O L E
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: UiTextFieldWidget(
                                  initialValue: CHelperFunctions.capitalize(widget.userData.userRole),
                                  readOnly: true,
                                  label: 'role',
                                ),
                              ),
              
                              SizedBox(width: CSizes.mediumGap,),
              
                              Expanded(
                                flex: 3,
                                child: UiDropDownWidget(
                                  value: _selectedRole, 
                                  hint: 'select new role', 
                                  items: _userRolesMap, 
                                  openDropDown: _openDropDown, 
                                  dropDownClick: _handleDropDownToggle, 
                                  optionClick: (key) => _handleDropDownOptionClick(key),
                                ),
                              ),
                            ],
                          ),
              
                          SizedBox(height: CSizes.largeGap,),
              
                          UiTitleWidget(
                            text: 'authentication'
                          ),
              
                          SizedBox(height: CSizes.mediumGap,),
                          
                          // - - - P H O N E _ N U M B E R
                          _editUserTitle(
                            controller: _phoneNumberController, 
                            label1: 'phone number', 
                            label2: 'new phone number', 
                            initial: widget.userData.phoneNumber, 
                            validator: (value) => _validatePhoneNumber(value), 
                            onChange: (value) {},
                          ),
              
                          SizedBox(height: CSizes.xLargeGap,),

                          Row(
                            children: [

                              // - - - A C T I V E _ A C C O U N T
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: CColors.whiteShade2),
                                  borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                ),
                                padding: EdgeInsets.all(CSizes.mediumGap),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    UiTitleWidget(
                                      text: 'Account status',
                                      defaultText: true,
                                      bold: false,
                                    ),
                                          
                                    SizedBox(width: CSizes.mediumGap,),
                                    
                                    UiToggleButtonWidget(
                                      isOn: _isActive, 
                                      onClick: () => setState(() => _isActive = !_isActive,)
                                    )
                                  ],
                                ),
                              ),

                              SizedBox(width: CSizes.mediumGap,),

                              // - - - P E R M I S S I O N _ T O _ E D I T
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: CColors.whiteShade2),
                                  borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                ),
                                padding: EdgeInsets.all(CSizes.mediumGap),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    UiTitleWidget(
                                      text: 'Permission to edit',
                                      defaultText: true,
                                      bold: false,
                                    ),
                                          
                                    SizedBox(width: CSizes.mediumGap,),
                                    
                                    UiToggleButtonWidget(
                                      isOn: _permitedToEdit, 
                                      onClick: () => setState(() => _permitedToEdit = !_permitedToEdit,)
                                    )
                                  ],
                                ),
                              ),

                              SizedBox(width: CSizes.mediumGap,),

                              // - - - N E W _ P A S S W O R D
                              Expanded(
                                child: IntrinsicHeight(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // phone number
                                      Expanded(
                                        child: UiTextFieldWidget(
                                          hint: 'New PIN',
                                          defaultLabel: true,
                                          textController: _pinController,
                                          validator: (value) => _validatePIN(value),
                                          readOnly: true,
                                          // enabled: false,
                                        ),
                                      ),
                                  
                                      SizedBox(width: CSizes.mediumGap,),
                                  
                                      UiButtonWidget(
                                        // text: 'generate new PIN',
                                        icon: CIcons.lockIcon,
                                        vericalPadding: 0,
                                        defaultText: true,
                                        onClick: _generateRandomPIN
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              
                            ],
                          ),
              
                          SizedBox(height: CSizes.xLargeGap,),
              
                          // - - - B U T T O N S
                          Row(
                            children: [
                              Expanded(
                                child: UiButtonWidget(
                                  text: 'back',
                                  tranparent: true,
                                  onClick: _handleBack
                                )
                              ),
              
                              SizedBox(width: CSizes.mediumGap,),
              
                              Expanded(
                                child: UiButtonWidget(
                                  text: 'submit',
                                  onClick: _handleFormSubmit
                                )
                              ),
                            ],
                          )
                  
                        ],
                      ),
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





  // - - - E D I T _ P R O D U C T _ T I L E
  Container _editUserTitle({
    required TextEditingController controller,
    required String label1,
    required String label2,
    required String initial,
    bool isDate = false,
    void Function()? onDateClick,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String? value) validator,
    required void Function(String? value) onChange,
    bool enabled = true,
    bool readOnly = false,
  }) {
    return Container(
      decoration: BoxDecoration(
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: UiTextFieldWidget(
              initialValue: initial,
              label: label1,
              readOnly: true,
            ),
          ),

          SizedBox(width: CSizes.mediumGap,),

          Expanded(
            flex: 3,
            child: UiTextFieldWidget(
              textController: controller,
              label: label2,
              keyboardType: keyboardType,
              validator: (value) => validator(value),
              onChange: (value) => onChange(value),
              onTap: onDateClick ?? () {},
              readOnly: isDate || readOnly,
              enabled: enabled,
            ),
          ),
        ],
      ),
    );
  }
}