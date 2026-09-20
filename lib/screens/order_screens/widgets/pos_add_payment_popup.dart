import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/order_payment_model.dart';
import 'package:shafici_pos/models/payment_method_model.dart';
import 'package:shafici_pos/providers/payments_provider.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_drop_down_widget.dart';
import 'package:shafici_pos/ui/ui_loading_screen_widget.dart';
import 'package:shafici_pos/ui/ui_no_data_founded.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class PosAddPaymentPopup extends StatefulWidget {
  final void Function() onCloseClick;
  // final void Function(PaymentMethodModel paymentMethod, double amount) onSubmitClick;
  final void Function(OrderPaymentModel payment) onSubmitClick;

  const PosAddPaymentPopup({
    super.key,
    required this.onCloseClick,
    required this.onSubmitClick,
  });

  @override
  State<PosAddPaymentPopup> createState() => _PosAddPaymentPopupState();
}

class _PosAddPaymentPopupState extends State<PosAddPaymentPopup> {
  final _amountController = TextEditingController();
  PaymentMethodModel? _selectedMethod;
  bool _openDropDown = false;
  final formKey = GlobalKey<FormState>();
  final FocusNode _amountFieldFocus = FocusNode();


  
  // - - - - - - >>
  // - - - V A L I D A T I O N S

  // -- -- --
  String? _validateAmount(String? value) {
    if (value == null || value.isEmpty)  return 'amount is missing';
    if (double.tryParse(value) == null) return 'invalid amount';
    if (double.parse(value) <= 0) return 'amount should be greater than zero';
    return null;
  }



  // - - - - - - >>
  // - - - F U N C T I O N S

  // -- -- --
  void _toggleShowDropDown() {
    setState(() => _openDropDown = !_openDropDown,);
  }

  // -- -- --
  void _handleMethodChange(PaymentMethodModel method) {
    setState(() => _selectedMethod = method);
    _amountFieldFocus.requestFocus();
    _toggleShowDropDown();
  }

  void _sendPaymentData() {
    if (_selectedMethod == null || _amountController.text.isEmpty) return;

    final payment = OrderPaymentModel(
      paymentId: _selectedMethod!.paymentId, 
      paymentName: _selectedMethod!.paymentName, 
      paidAmount: double.parse(_amountController.text)
    );

    widget.onSubmitClick(payment);
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: widget.onCloseClick,
      child: ClipRRect(
        child: Container(
          color: CColors.dimmedBackgound,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(CSizes.largeGap),
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        decoration: BoxDecoration(
                          color: CColors.white,
                          borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                        ),
                        padding: EdgeInsets.all(CSizes.largeGap),
                        child: Consumer<PaymentMethodsProvider>(
                          builder: (context, provider, child) {
                            if (provider.isLoading) {
                              return UiLoadingScreenWidget();
                            }

                            // if (provider.errorMessage != null) {
                            //   return UiNoDataFounded(
                            //     title: provider.errorMessage,
                            //     buttonText: 'back',
                            //     onButtonClick: widget.onCloseClick,
                            //   );
                            // }

                            return _addPaymentMethodForm(
                              provider.paymentMethods
                            );
                          },
                        ),
                      ),
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

  // - - - - - -
  Form _addPaymentMethodForm(List<PaymentMethodModel> methods) {
    final Map<String, String> methodsToMap = PaymentMethodModel.toDropDownMap(methods);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
      
          UiTitleWidget(
            text: 'add new payment', 
            bigger: true,
            textAlign: TextAlign.center,
          ),
                    
          SizedBox(height: CSizes.xLargeGap,),
                    
          
          // - - - S E L E C T _ M E T H O D
          UiDropDownWidget(
            value: _selectedMethod?.paymentName,
            hint: 'select method',
            items: methodsToMap,
            openDropDown: _openDropDown,
            dropDownClick: _toggleShowDropDown,
            optionClick: (key) => _handleMethodChange(methods.firstWhere((method) => method.paymentId == key)),
          ),
                    
          SizedBox(height: CSizes.mediumGap,),
                    
          
          // - - - E N T E R _ A M O U N T
          UiTextFieldWidget(
            focusNode: _amountFieldFocus,
            label: 'Enter amount',
            textController: _amountController,
            keyboardType: TextInputType.number,
            fieldSubmit: (_) => _sendPaymentData(),
            validator: (value) => _validateAmount(value),
            onChange: (value) => setState(() {}),
          ),
                    
          SizedBox(height: CSizes.xLargeGap,),
          
          // - - - B U T T O N S
          Row(
            children: [
              Expanded(
                child: UiButtonWidget(
                  text: 'cancel',
                  tranparent: true,
                  onClick: widget.onCloseClick
                ),
              ),
      
              SizedBox(width: CSizes.mediumGap,),
      
              Expanded(
                child: UiButtonWidget(
                  text: 'submit',
                  isDisabled: _selectedMethod == null || formKey.currentState?.validate() == false,
                  onClick: _selectedMethod != null && _amountController.text.isNotEmpty ? _sendPaymentData : () {}
                ),
              ),
            ],
          )
      
        ],
      ),
    );
  }
}