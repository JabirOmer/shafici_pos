import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/app.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class VerifyDeviceScreen extends StatefulWidget {
  const VerifyDeviceScreen({super.key});

  @override
  State<VerifyDeviceScreen> createState() => _VerifyDeviceScreenState();
}

class _VerifyDeviceScreenState extends State<VerifyDeviceScreen> {
  late AppInfoProvider _appInfoProvider;
  final CApiServices _apiServices = CApiServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final DeviceInfoPlugin _deviceInfoPlugin = DeviceInfoPlugin();

  final _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;


  // - - - F U N C T I O N S

  Future<void> _handleFormSubmit() async {    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _appInfoProvider = Provider.of(context, listen: false);

    try {
      final formData = {
        'verification_code': _verificationCodeController.text.trim(),
        "device_name": await _getDeviceName()
      };

      final response = await _apiServices.patchRequest(url: CUrlStrings.verifyVerificationCode, data: formData);
      if (!mounted) return;

      switch (response.statusCode) {
        case 200: {
          final token = response.data['token'];
          await _secureStorageService.write(CSecureStrings.deviceToken, token);
          await _appInfoProvider.getAuthStatusEnum();
          if (!mounted) return;
          // CHelperFunctions.navigateToScreen(context: context, screen: App(), replacement: true);
        }

        default: setState(() => _errorMessage = response.data);
      }
    } catch (e) {
      print(e);
      setState(() => _errorMessage = 'Failed to send code');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _verificationCodeController.clear();
        });
      }

      await Future.delayed(Duration(seconds: 2));
      if (mounted) setState(() => _errorMessage = null);
    }
  }


  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      // Android
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return info.model;
      } 

      // iOS
      else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.utsname.machine;
      } 

      // macOS
      else if (Platform.isMacOS) {
        final info = await deviceInfo.macOsInfo;
        return info.model;
      }

      // Windows
      else if (Platform.isWindows) {
        final info = await deviceInfo.windowsInfo;
        return info.productName;
      }

      return _getFallbackDeviceName();
    } catch (e) {
      return _getFallbackDeviceName();
    }
  }

  String _getFallbackDeviceName() {
    if (Platform.isMacOS) return 'Mac Computer';
    if (Platform.isWindows) return 'Windows Computer';
    if (Platform.isIOS) return 'iPhone/iPad';
    if (Platform.isAndroid) return 'Android Device';
    if (Platform.isLinux) return 'Linux Computer';
    return 'Unknown Device';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          // - - - F O R M
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 400
              ),
              child: Container(
                width: double.maxFinite,
                  decoration: BoxDecoration(
                    color: CColors.white,
                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: CSizes.xLargeGap,
                    horizontal: CSizes.xLargeGap
                  ),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // - - - T I T L E
                      UiTitleWidget(
                        text: 'device verification',
                        textAlign: TextAlign.center,
                        bigger: true,
                      ),
                
                      SizedBox(height: CSizes.largeGap,),
                
                      UiTextFieldWidget(
                        textController: _verificationCodeController, 
                        keyboardType: TextInputType.number,
                        label: 'enter verification code',
                        fieldSubmit: (value) => _handleFormSubmit(),
                        onChange: (value) => setState(() => _errorMessage = null,),
                      ),

                      AnimatedContainer(
                        duration: Duration(milliseconds: 150),
                        height: _errorMessage != null ? 40 : 0,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: CColors.redDimmed
                        ),
                        padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
                        margin: EdgeInsets.only(top: _errorMessage == null ? 0 : CSizes.largeGap),
                        child: Center(
                          child: Text(
                            _errorMessage ?? '',
                            style: TextStyle(
                              color: CColors.white
                            ),
                          ),
                        ),
                      ),
            
                      SizedBox(height: CSizes.largeGap,),
            
                      UiButtonWidget(
                        text: 'verify',
                        onClick: _handleFormSubmit,
                        isDisabled: _isLoading,
                      )
                    ],
                  )
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}