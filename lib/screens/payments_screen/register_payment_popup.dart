import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class RegisterPaymentPopup extends StatefulWidget {
  final void Function(bool reload) onBackCall;

  const RegisterPaymentPopup({
    super.key,
    required this.onBackCall
  });

  @override
  State<RegisterPaymentPopup> createState() => _RegisterPaymentPopupState();
}

class _RegisterPaymentPopupState extends State<RegisterPaymentPopup> {
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _paymentNameController = TextEditingController();
  final TextEditingController _paymentAccountController = TextEditingController();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;


  // - - - - - - >>
  // - - - V A L I D A T I O N S
  final digitsOnlyRegex = RegExp(r'^\d+$');

  String? _validatePaymentName(String? value) {
    if (value == null || value.isEmpty) return 'Payment name is missing';
    return null;
  }
  String? _validatePaymentAccount(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!digitsOnlyRegex.hasMatch(value.trim())) return 'only numbers are allowed ';
    return null;
  }
  // - - - V A L I D A T I O N S
  // - - - - - - >>


  // - - - - - - >>
  // - - - F U N C T I O N S
  Future<void> _handleSubmitClick() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final dataMap = { 
          "method_name": _paymentNameController.text.trim().toLowerCase(),
          "method_account": _paymentAccountController.text.isNotEmpty ? _paymentAccountController.text.trim().toLowerCase() : null,
        };
        final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
        final response = await _apiServices.postRequest(url: CUrlStrings.registerPaymentUrl, data: dataMap, authToken: deviceToken);

        switch (response.statusCode) {
          case 201: _successMessage = response.data['msg'];
          default: _errorMessage = response.data;
        }
      } catch (e) {
        _errorMessage = 'failed to register payment';
      } finally {
        setState(() => _isLoading = false);
        await Future.delayed(Duration(seconds: 2));
        if (mounted) _successMessage != null ? widget.onBackCall(true) : setState(() => _errorMessage = null);
      }
    }
  }
  // - - - F U N C T I O N S
  // - - - - - - >>

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
        child: GestureDetector(
          onTap: () => _isLoading ? () : widget.onBackCall(false),
          child: Container(
            decoration: BoxDecoration(
              color: CColors.dimmedBackgound,
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                child: Padding(
                  padding: EdgeInsetsGeometry.all(CSizes.largeGap),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // 
                      GestureDetector(
                        onTap: () {},
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 500),
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
                                      text: 'register payment',
                                      bigger: true,
                                      textAlign: TextAlign.center,
                                      capitalizeWords: true,
                                    ),

                                    SizedBox(height: CSizes.largeGap,),
                                    
                                    // - - - P A Y M E N T _ N A M E
                                    UiTextFieldWidget(
                                      textController: _paymentNameController,
                                      label: 'payment name',
                                      validator: (value) => _validatePaymentName(value),
                                      fieldSubmit: (value) => _handleSubmitClick(),
                                    ),

                                    SizedBox(height: CSizes.largeGap,),

                                    // - - - P A Y M E N T _ A C C O U N T
                                    UiTextFieldWidget(
                                      textController: _paymentAccountController,
                                      label: 'account number',
                                      keyboardType: TextInputType.number,
                                      validator: (value) => _validatePaymentAccount(value),
                                      fieldSubmit: (value) => _handleSubmitClick(),
                                    ),
                                  
                                    UiAnimatedMiniMessageWidget(
                                      displayText: _successMessage ?? _errorMessage,
                                      isSuccess: _successMessage != null,
                                    ),
                                    
                                    SizedBox(height: CSizes.largeGap,),

                                    // - - - B U T T O N S
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: UiButtonWidget(
                                            text: 'back',
                                            tranparent: true,
                                            onClick: () => _isLoading ? {} : widget.onBackCall(false)
                                          ),
                                        ),
                                    
                                        SizedBox(width: CSizes.mediumGap,),
                                        
                                        Expanded(
                                          flex: 1,
                                          child: UiButtonWidget(
                                            text: _isLoading ? 'loading...' : 'submit',
                                            isDisabled: _isLoading || _successMessage != null,
                                            icon: CIcons.sendIcon,
                                            onClick: _handleSubmitClick
                                          )
                                        ),
                                      ],
                                    )

                                  ]
                                )
                              )
                            )
                          )
                        )
                      )

                    ]
                  )
                )
              )
            )
          )
        )
      )
    );
  }
}