import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/blocs/cubits/credit_cubit.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/helpers/helper_functions.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/providers/payments_provider.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_form_message.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class NewCreditRecordForm extends StatefulWidget {
  final CreditModel credit;
  final void Function() onCancel;

  const NewCreditRecordForm({
    super.key,
    required this.onCancel,
    required this.credit
  });

  @override
  State<NewCreditRecordForm> createState() => _NewCreditRecordFormState();
}

class _NewCreditRecordFormState extends State<NewCreditRecordForm> {
  final _secureStorageService = CSecureStorageService();
  final _apiServices = CApiServices();

  final _formKey = GlobalKey<FormState>();
  final _methodNameController = TextEditingController();
  final _amountController = TextEditingController();

  bool _showMethodsList = true;
  PaymentMethodModel? _selectedMethod;

  String? _errorMessage;
  String? _successMessage;
  bool _isLoading = false;

  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty)  return 'amount is missing';
    if (double.tryParse(value) == null) return 'invalid amount';
    if (double.parse(value) <= 0) return 'amount should be greater than zero';
    return null;
  }

  void _handlePaymentMethodChange(PaymentMethodModel method) {
    setState(() {
      _selectedMethod = method;
      _methodNameController.text = CHelperFunctions.capitalizeWords(method.paymentName);
    });
    _toggleShowMethodsList();
  }

  void _toggleShowMethodsList() {
    setState(() => _showMethodsList = !_showMethodsList,);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _isLoading = true,);

      await Future.delayed(Duration(seconds: 2));

      final dataMap = {
        'credit_id': widget.credit.creditId, 
        'payment_id': _selectedMethod?.paymentId,
        'amount_paid': double.tryParse(_amountController.text)
      };

      final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
      final response = await _apiServices.postRequest(url: CUrlStrings.registerCreditRecord, data: dataMap, authToken: deviceToken);
      if (!mounted) return;

      switch (response.statusCode) {
        case 201: {
          _successMessage = response.data['msg'];
          context.read<CreditCubit>().fetchCredits();
        }

        default: {
          _errorMessage = response.data;
        }
      }

    } 
    catch (e) {
      _errorMessage = 'Failed to register new record';
    }
    finally {
      setState(() => _isLoading = false,);
      await Future.delayed(Duration(seconds: 2));
      _clearMessages();
    }
  }

  void _clearMessages() {
    if (!mounted) return;
    
    if (_errorMessage != null) setState(() => _errorMessage = null,);
    if (_successMessage != null) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        color: CColors.dimmedBackgound,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints( maxWidth: 600 ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColors.white,
                      borderRadius: BorderRadius.circular(CSizes.largeGap)
                    ),
                    padding: EdgeInsets.all(CSizes.largeGap),
                    margin: EdgeInsets.all(CSizes.largeGap),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                  
                          // - - --
                          UiTitleWidget(text: 'New record', bigger: true,),
                  
                          SizedBox(height: CSizes.largeGap,),
                        
                          // - - - C U S T O M E R
                          if (!_showMethodsList)  UiTextFieldWidget(
                            textController: _methodNameController,
                            label: 'payment method',
                            onTap: _toggleShowMethodsList,
                          ),
                            
                          if (!_showMethodsList)  SizedBox(height: CSizes.largeGap,),
                  
                          // - - - L I S T
                          if (_showMethodsList) ConstrainedBox(
                            constraints: BoxConstraints( maxHeight: 400,  ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: CColors.whiteShade1,
                                border: Border.all(width: 1, color: CColors.whiteShade2),
                                borderRadius: BorderRadius.circular(CSizes.largeGap)
                              ),
                              margin: EdgeInsets.only(bottom: CSizes.largeGap),
                              child: Consumer<PaymentMethodsProvider>(
                                builder: (context, provider, child) {
                                  if (provider.paymentMethods.isEmpty) {
                                    return Padding(
                                      padding: EdgeInsets.all(CSizes.largeGap),
                                      child: UiTitleWidget(text: 'No payment methods are founded', bold: false,)
                                    );
                                  }
                  
                                  return ListView.separated(
                                    padding: EdgeInsets.all(CSizes.largeGap),
                                    shrinkWrap: true,
                                    physics: AlwaysScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final method = provider.paymentMethods[index];
                                      return _methodListTile(
                                        index: index,
                                        method: method,
                                        onClick: () => _handlePaymentMethodChange(method)
                                      );
                                    }, 
                                    separatorBuilder: (context, index) => Divider( height: 1, color: CColors.whiteShade2, indent: 47, ), 
                                    itemCount: provider.paymentMethods.length
                                  );
                                },
                              ),
                            ),
                          ),
                  
                  
                          if (!_showMethodsList) UiTextFieldWidget(
                            textController: _amountController,
                            label: 'amount paid',
                            validator: (value) => _validateAmount(value),
                            fieldSubmit: (_) => _handleSubmit(),
                          ),

                          if (!_showMethodsList)  SizedBox(height: CSizes.largeGap,),
                  
                          UiFormMessage(
                            message: _successMessage ?? _errorMessage,
                            isSuccess: _successMessage != null,
                          ),
                  
                          // if (!_showMethodsList)  SizedBox(height: CSizes.largeGap,),
                            
                          // - - - B U T T O N S
                          Row(
                            children: [
                              Expanded(
                                child: UiButtonWidget(
                                  text: 'cancel',
                                  tranparent: true,
                                  isDisabled: _isLoading,
                                  onClick: widget.onCancel
                                )
                              ),
                            
                              if (!_showMethodsList)  SizedBox(width: CSizes.mediumGap,),
                            
                              if (!_showMethodsList)  Expanded(
                                child: UiButtonWidget(
                                  text: 'submit',
                                  isDisabled: _isLoading,
                                  onClick: _handleSubmit
                                )
                              )
                            ],
                          )
                  
                        ],
                      )
                    ),
                  ),
                ),
              )
        
            ],
          ),
        ),
      ),
    );
  }

  // 
  GestureDetector _methodListTile({
    required int index,
    required PaymentMethodModel method,
    required void Function() onClick
  }) {
    return GestureDetector(
      onTap: onClick,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          color: CColors.transparent,
          padding: EdgeInsets.symmetric( vertical: CSizes.smallGap ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: CColors.whiteShade2,
                  borderRadius: BorderRadius.circular(CSizes.mediumGap)
                ),
                margin: EdgeInsets.only(right: CSizes.mediumGap),
                child: Center(
                  child: UiTitleWidget(
                    text: (index+1).toString().padLeft(2, '0'),
                    customSize: 10,
                  )
                ),
              ),
                  
              UiTitleWidget(text: method.paymentName, bold: false,)
                  
            ],
          ),
        ),
      ),
    );
  }
}