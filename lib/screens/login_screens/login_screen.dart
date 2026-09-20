import 'package:flutter/material.dart';
import 'package:shafici_pos/app.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/screens/login_screens/widgets/login_form_section_widget.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final CApiServices _apiServices = CApiServices();
  late AppInfoProvider _appInfoProvider;

  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _isLoading = false;
  String? _errorMessage;


  // - - - F U N C T I O N S

  void _toggleHidePassword() {
    setState(() => _hidePassword = !_hidePassword);
  }

  // Func_1
  Future<void> _handleFormSubmit() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final formData = {
        'phone_number': _phoneNumberController.text.trim(),
        'password': _passwordController.text.trim()
      };

      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.postRequest(url: CUrlStrings.loginUrl, data: formData, authToken: deviceToken);
      if (!mounted) return;

      switch (response.statusCode) {
        case 200: {
          _appInfoProvider = Provider.of<AppInfoProvider>(context, listen: false);
          final String token = response.data['token'];
          await _secureStorageService.write(CSecureStrings.jwtKey, token);
          if (mounted) CHelperFunctions.navigateToScreen(context: context, screen: App(), replacement: true);
          // _appInfoProvider.getAuthStatusEnum();
        }

        default: {
          setState(() {
            _errorMessage = response.data;
          });
        }
      }
    } catch (e) {
      setState(() => _errorMessage = 'failed to login',);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // - - - func
  void _closePopup() {
    setState(() => _errorMessage = null,);
  }



  @override
  void dispose() {
    _phoneNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          
          // Login Form
          LoginFormSectionWidget(
            phoneNumberController: _phoneNumberController, 
            passwordController: _passwordController, 
            hidePassword: _hidePassword,
            toggleHidePassword: _toggleHidePassword,
            onSubmit: _handleFormSubmit,
            isLoading: _isLoading,
          ),

          // Alert Popup
          if (_errorMessage != null) UiPopupWidget(
            message: _errorMessage!, 
            primaryText: 'try again', 
            primaryClick: _closePopup,
            outSideClick: _closePopup,
          )
        ],
      ),
    );
  }
}