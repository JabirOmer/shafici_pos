import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class EditPaymentPopup extends StatefulWidget {
  final PaymentMethodModel paymentMethod;
  final void Function(bool reload) onBackCall;

  const EditPaymentPopup({
    super.key,
    required this.paymentMethod,
    required this.onBackCall
  });

  @override
  State<EditPaymentPopup> createState() => _EditPaymentPopupState();
}

class _EditPaymentPopupState extends State<EditPaymentPopup> {
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
    // if (!digitsOnlyRegex.hasMatch(value.trim())) return 'only numbers are allowed ';
    return null;
  }
  // - - - V A L I D A T I O N S
  // - - - - - - >>



  // - - - - - - >>
  // - - - F U N C T I O N S
  Future<void> _handleFormSubmit() async {
    final dataMap = PaymentMethodModel(
      paymentId: widget.paymentMethod.paymentId, 
      paymentName: _paymentNameController.text.isEmpty ? widget.paymentMethod.paymentName : _paymentNameController.text.toLowerCase().trim(),
      paymentAccount: _paymentAccountController.text.isEmpty ? widget.paymentMethod.paymentAccount : ( _paymentAccountController.text == 'null' ? null : _paymentAccountController.text.trim()),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now()
    ).toJson();


    try {
      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.patchRequest(url: CUrlStrings.updatePaymentMethodUrl, data: dataMap, authToken: deviceToken);

      
      switch (response.statusCode) {
        case 200: _successMessage = response.data['msg'];
        default: _errorMessage = response.data;
      }
    } catch (e) {
      _errorMessage = 'failed to edit payment method';
    } finally {
      setState(() => _isLoading = false,);
      await Future.delayed(Duration(seconds: 2));
      if (mounted) _successMessage != null ? widget.onBackCall(true) : setState(() => _errorMessage = null);
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
                            constraints: BoxConstraints(maxWidth: 900),
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
                                      text: 'Edit payment',
                                      bigger: true,
                                      textAlign: TextAlign.center,
                                      capitalizeWords: true,
                                    ),

                                    SizedBox(height: CSizes.largeGap,),
                                    
                                    // - - - P A Y M E N T _ N A M E
                                    _editValueTitle(
                                      controller: _paymentNameController, 
                                      label: 'payment name', 
                                      initial: widget.paymentMethod.paymentName, 
                                      validator: (value) => _validatePaymentName(value), 
                                      onChange: (value) {}
                                    ),

                                    SizedBox(height: CSizes.largeGap,),

                                    // - - - P A Y M E N T _ A C C O U N T
                                    _editValueTitle(
                                      controller: _paymentAccountController, 
                                      label: 'account', 
                                      initial: widget.paymentMethod.paymentAccount.toString(), 
                                      validator: (value) => _validatePaymentAccount(value), 
                                      onChange: (value) {}
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
                                            onClick: _handleFormSubmit
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





  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -




  // - - - E D I T _ V A L U E _ T I L E
  Container _editValueTitle({
    required TextEditingController controller,
    required String label,
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
              readOnly: true,
              enabled: false,
            ),
          ),

          SizedBox(width: CSizes.mediumGap,),

          Expanded(
            flex: 3,
            child: UiTextFieldWidget(
              textController: controller,
              label: label,
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