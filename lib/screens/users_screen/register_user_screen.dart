import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/providers/users_provider.dart';
import 'package:shafici_pos/screens/app_layout_screens/responsive_app_layout_screen.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_drop_down_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:provider/provider.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  late UsersProvider _usersProvider;

  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  
  String? _selectedRole;
  late Map<String, String> _userRolesMap;
  bool _openDropDown = false;

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;

  final usernameRegex = RegExp(r'^[A-Za-z-]+$');
  final digitsOnlyRegex = RegExp(r'^\d+$');

  // - - - - - - >>
  // - - - V A L I D A T I O N S
  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) return 'first name is missing';
    if (!usernameRegex.hasMatch(value)) return 'Name can only contain letters and hyphens (-).';
    return null;
  }
  String? _validateMiddleName(String? value) {
    if (value == null || value.isEmpty) return 'middle name is missing';
    if (!usernameRegex.hasMatch(value)) return 'Name can only contain letters and hyphens (-).';
    return null;
  }
  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) return 'last name is missing';
    if (!usernameRegex.hasMatch(value)) return 'Name can only contain letters and hyphens (-).';
    return null;
  }
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) return 'phone number is missing';
    if (!digitsOnlyRegex.hasMatch(value)) return 'Only digits (0-9) are allowed.';
    if (int.tryParse(value) == null) return 'invalid phone number';
    return null;
  }
  String? _validatePIN(String? value) {
    if (value == null || value.isEmpty) return 'PIN is missing';
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
    setState(() => _pinController.text = pin.toString());
  }

  Future<void> _handleFormSubmit() async {
    _usersProvider = Provider.of(context, listen: false);
    if (_formKey.currentState!.validate()) {
      try {
        setState(() {
          _isLoading = true;
          _successMessage = null;
          _errorMessage = null;
        });

        final dataMap = {
          "first_name": _firstNameController.text.toLowerCase().trim(),
          "middle_name": _middleNameController.text.toLowerCase().trim(),
          "last_name": _lastNameController.text.toLowerCase().trim(),
          "user_role": _selectedRole,
          "phone_number": _phoneNumberController.text.toLowerCase().trim(),
          "password": _pinController.text.trim()
        };
        final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
        final response = await _apiServices.postRequest(url: CUrlStrings.registerUserUrl, data: dataMap, authToken: deviceToken);

        switch (response.statusCode) {
          case 201: {
            _successMessage = response.data['msg'];
            await _usersProvider.setUsers();
          }

          default: {
            _errorMessage = response.data;
          }
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
  // - - - F U N C T I O N S
  // - - - - - - >>


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _usersProvider = Provider.of(context, listen: false);
    setState(() => _userRolesMap = _usersProvider.rolesMap,);
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
      
          // - - - M A I N
          registerUserMethod(context),
      
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

  
  
  // - - - R E G I S T E R _ U S E R _ M E T H O D
  Scaffold registerUserMethod(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
          child: Padding(
            padding: EdgeInsetsGeometry.all(CSizes.largeGap),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
    
                Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColors.white,
                      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                    ),
                    padding: EdgeInsets.all(CSizes.largeGap),
                    child: Consumer<UsersProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          return UiLoadingScreenWidget();
                        }

                        if (provider.errorMessage != null) {
                          return UiNoDataFounded(
                            title: provider.errorMessage,
                            buttonText: 'back',
                            onButtonClick: _handleBack,
                          );
                        }

                        return _registerUserFormMethod();
                      },
                    ),
                    )
                  )
                )
    
              ]
            )
          )
        )
      ),
    );
  }

  Form _registerUserFormMethod() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [

          // - - - T I T L E
          UiTitleWidget(
            text: 'register user',
            bigger: true,
            capitalizeWords: true,
            textAlign: TextAlign.center,
          ),

          SizedBox(height: CSizes.xLargeGap,),


          UiTitleWidget(
            text: 'basic info'
          ),

          SizedBox(height: CSizes.mediumGap,),
          
          // - - - U S E R _ N A M E
          UiTextFieldWidget(
            label: 'first name',
            textController: _firstNameController,
            validator: (value) => _validateFirstName(value),
          ),
              
          SizedBox(height: CSizes.largeGap,),
              
          // middle name
          UiTextFieldWidget(
            label: 'middle name',
            textController: _middleNameController,
            validator: (value) => _validateMiddleName(value),
          ),
          
          SizedBox(height: CSizes.largeGap,),
          
          // last name
          UiTextFieldWidget(
            label: 'last name',
            textController: _lastNameController,
            validator: (value) => _validateLastName(value),
          ),

          SizedBox(height: CSizes.largeGap,),
          
          // - - - R O L E _ A N D _ P H O N E - N U M B E R
          UiDropDownWidget(
            value: _selectedRole, 
            hint: 'select user role', 
            items: _userRolesMap, 
            openDropDown: _openDropDown, 
            dropDownClick: _handleDropDownToggle, 
            optionClick: (key) => _handleDropDownOptionClick(key),
          ),
          
          SizedBox(height: CSizes.xLargeGap,),

          UiTitleWidget(
            text: 'authentication'
          ),

          SizedBox(height: CSizes.mediumGap,),
          
          // phone number
          UiTextFieldWidget(
            label: 'phone number',
            textController: _phoneNumberController,
            validator: (value) => _validatePhoneNumber(value),
          ),

          SizedBox(height: CSizes.xLargeGap,),


          // - - - D E F A U L T _ P I N
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // phone number
                Expanded(
                  child: UiTextFieldWidget(
                    hint: 'PIN',
                    defaultLabel: true,
                    textController: _pinController,
                    validator: (value) => _validatePIN(value),
                    readOnly: true,
                    // enabled: false,
                  ),
                ),
            
                SizedBox(width: CSizes.mediumGap,),
            
                UiButtonWidget(
                  icon: CIcons.lockIcon,
                  vericalPadding: 0,
                  defaultText: true,
                  onClick: _generateRandomPIN
                )
              ],
            ),
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

          // - - - E N D
        ],
      ),
    );
  }





  // - - - - - - 
  // - - - M E T H O D S
  // - - - - - - 




  // - - - F O R M _ I N P U T

}