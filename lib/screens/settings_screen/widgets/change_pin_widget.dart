import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class ChangePinWidget extends StatefulWidget {
  final void Function() onCancel;

  const ChangePinWidget({
    super.key,
    required this.onCancel,
  });

  @override
  State<ChangePinWidget> createState() => _ChangePinWidgetState();
}

class _ChangePinWidgetState extends State<ChangePinWidget> {
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _currentPINController = TextEditingController();
  final TextEditingController _newPINController = TextEditingController();
  final TextEditingController _confirmPINController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  

  // - - - - - - >>
  // - - - V A L I D A T I O N S
  String? _pinValidator(String? value) {
    if (value == null || value.isEmpty) return 'PIN is missing';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'use only 0-9 digits';
    if (value.length != 4) return 'PIN should be 4 digits';
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    if (value == null || value.isEmpty) return 'PIN is missing';
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) return 'use only 0-9 digits';
    if (value.length < 4) return 'PIN should be 4 digits';
    if (value != _newPINController.text) return 'PIN do not match';
    return null;
  }
  // - - - V A L I D A T I O N S
  // - - - - - - >>


  // - - - - - - >>
  // - - - F U N C T I O N S
  Future<void> _handlePasswordChangeSubmit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final data = {
        'current_password': _currentPINController.text,
        'new_password': _newPINController.text
      };
      final userToken = await _secureStorageService.read(CSecureStrings.jwtKey);
      final response = await _apiServices.patchRequest(url: CUrlStrings.updatePasswordUrl, data: data, authToken: userToken);
      if (!mounted) return;
      
      switch (response.statusCode) {
        case 200: _successMessage = response.data['msg'];
        default: _errorMessage = response.data;
      }

    } catch (e) {
      _errorMessage = 'Failed to change PIN';
    } finally {
      setState(() => _isLoading = false);
      await Future.delayed(Duration(seconds: 2));
      if (mounted) {
        _successMessage != null ? widget.onCancel() : setState(() => _errorMessage = null);
      }
    }
  }
  // - - - F U N C T I O N S
  // - - - - - - >>

  @override
  void dispose() {
    // _formKey.currentState?.dispose();
    _currentPINController.dispose();
    _newPINController.dispose();
    _confirmPINController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
        child: GestureDetector(
          onTap: widget.onCancel,
          child: Container(
            color: CColors.dimmedBackgound,
            padding: EdgeInsets.all(CSizes.largeGap),
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 500),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColors.white,
                      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                    ),
                    padding: EdgeInsets.all(CSizes.largeGap),
                    child: Wrap(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              UiTitleWidget(text: 'Change PIN', defaultText: true, bigger: true,),

                              SizedBox(height: CSizes.largeGap,),
                          
                              UiTextFieldWidget(
                                label: 'Current PIN',
                                defaultLabel: true,
                                textController: _currentPINController,
                                keyboardType: TextInputType.number,
                                validator: (value) => _pinValidator(value),
                                obscureText: true,
                              ),
                          
                              SizedBox(height: CSizes.largeGap,),
                          
                              UiTextFieldWidget(
                                label: 'New PIN',
                                defaultLabel: true,
                                textController: _newPINController,
                                keyboardType: TextInputType.number,
                                validator: (value) => _pinValidator(value),
                                obscureText: true,
                              ),
                              
                              SizedBox(height: CSizes.largeGap,),
                          
                              UiTextFieldWidget(
                                label: 'Confirm PIN',
                                defaultLabel: true,
                                textController: _confirmPINController,
                                keyboardType: TextInputType.number,
                                validator: (value) => _confirmPasswordValidator(value),
                                obscureText: true,
                              ),
                              
                              // AnimatedContainer(
                              //   duration: Duration(milliseconds: 150),
                              //   height: _errorMessage != null ? 40 : 0,
                              //   width: double.maxFinite,
                              //   decoration: BoxDecoration(
                              //     color: _successMessage != null ? CColors.green : CColors.red
                              //   ),
                              //   padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
                              //   margin: EdgeInsets.only(top: _errorMessage != null ? CSizes.largeGap : 0),
                              //   child: Center(
                              //     child: Text(
                              //       _errorMessage ?? '',
                              //       style: TextStyle(
                              //         color: CColors.white
                              //       ),
                              //     ),
                              //   ),
                              // ),

                              UiAnimatedMiniMessageWidget(
                                displayText: _successMessage ?? _errorMessage,
                                isSuccess: _successMessage != null,
                              ),
                              
                              SizedBox(height: CSizes.largeGap,),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: UiButtonWidget(
                                      text: 'cancel',
                                      onClick: widget.onCancel,
                                      tranparent: true,
                                    )
                                  ),
                              
                                  SizedBox(width: CSizes.mediumGap,),
                              
                                  Expanded(
                                    child: UiButtonWidget(
                                      text: 'submit',
                                      onClick: _handlePasswordChangeSubmit,
                                      isDisabled: _isLoading || _successMessage != null,
                                    )
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}