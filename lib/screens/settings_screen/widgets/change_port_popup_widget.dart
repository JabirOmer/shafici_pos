import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class ChangePortPopupWidget extends StatefulWidget {
  final void Function() onCancel;
  
  const ChangePortPopupWidget({
    super.key,
    required this.onCancel
  });

  @override
  State<ChangePortPopupWidget> createState() => _ChangePortPopupWidgetState();
}

class _ChangePortPopupWidgetState extends State<ChangePortPopupWidget> {
  String? currentPort = CSharedPreferencesServices().getString(CSharedPrefsKeys.socketPort);

  final CSharedPreferencesServices _sharedPreferencesServices = CSharedPreferencesServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();

  final _formKey = GlobalKey<FormState>();
  final _portController = TextEditingController();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;



  // - - - - - - >>
  // - - - V A L I D A T I O N S
  String? _validatePort(String? value) {
    if (value == null || value.isEmpty) return 'Port number is missing';
    if (double.tryParse(value) == null) return 'invalid number';
    if (value.length != 4) return 'Port number should be 4 digits';
    return null;
  }



  // - - - Functions
  Future<void> _handleChangePort() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _sharedPreferencesServices.setString(CSharedPrefsKeys.socketPort, _portController.text);
        _successMessage = 'Port is successfully changed';
      } catch (e) {
        _errorMessage = 'Failed to change port';
      } finally {
        setState(() => _isLoading = false,);

        await Future.delayed(Duration(seconds: 2));
        if (mounted && _successMessage != null) widget.onCancel;
        if (mounted) _clearMessage();
      }
    }
  }


  void _clearMessage() {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });
  }

  @override
  void dispose() {
    _portController.dispose();
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
                              UiTitleWidget(text: 'Change server port', bigger: true,),

                              SizedBox(height: CSizes.largeGap,),
                          
                              UiTextFieldWidget(
                                hint: 'Current port',
                                initialValue: currentPort,
                                enabled: false,
                              ),
                          
                              SizedBox(height: CSizes.largeGap,),

                              UiTextFieldWidget(
                                label: 'new port',
                                keyboardType: TextInputType.number,
                                textController: _portController,
                                validator: (value) => _validatePort(value),
                                fieldSubmit: (value) => _handleChangePort(),
                              ),

                              // - - - A N I M A T E D _ M I N I _ M E S S A G E
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
                                      onClick: _handleChangePort,
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