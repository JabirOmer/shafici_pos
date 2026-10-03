import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shafici_pos/blocs/cubits/customer_cubit.dart';
import 'package:shafici_pos/blocs/states/customer_state.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/credit_model.dart';
import 'package:shafici_pos/models/customer_model.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_drop_down_widget.dart';
import 'package:shafici_pos/ui/ui_form_message.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class CreateCreditWidget extends StatefulWidget {
  final void Function(CustomerModel customer, double amount) onSubmit;
  final void Function() onCancel;

  const CreateCreditWidget({
    super.key,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  State<CreateCreditWidget> createState() => _CreateCreditWidgetState();
}

class _CreateCreditWidgetState extends State<CreateCreditWidget> {
  final _secureStorageService = CSecureStorageService();
  final _apiServices = CApiServices();

  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController(); 
  final _creditAmountController = TextEditingController(); 
  CustomerModel? _selectedCustomer;

  bool _showCustomersList = true;
  bool _isLoading = false;
  String? _errorMessage;

  


  // - - - - - - F U N C T I O N S

  // -- -- --
  void _toggleShowCustomersList() {
    setState(() => _showCustomersList = !_showCustomersList);
  }

  // -- -- --
  void _handleCustomerChange(CustomerModel customer) {
    setState(() {
      _selectedCustomer = customer;
      _customerNameController.text = customer.customerName;
    });
    _toggleShowCustomersList();
  }

  // -- -- --
  Future<void> _handleSubmit() async {
    if (_isLoading) return;

    if (_formKey.currentState!.validate()) {
      try {
        setState(() => _isLoading = false,);

        final customer = _selectedCustomer;
        final amount = double.tryParse(_creditAmountController.text);

        if (customer == null) {
          _errorMessage = 'customer id is not founded';
          return;
        }

        if (amount == null) {
          _errorMessage = 'invalid amount';
          return;
        }
        
        widget.onSubmit(customer, amount);
      }
      finally {
        setState(() => _isLoading = false,);
        await Future.delayed(Duration(seconds: 2));
        _clearMessages();
      }
    }
  }

  void _clearMessages() {
    if (!mounted) return;
    setState(() => _errorMessage = null,);
  }


  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        color: CColors.dimmedBackgound,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Center(
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                        
                      // - - - T I T L E
                      UiTitleWidget(text: 'add credit balance', medium: true,),
                        
                      SizedBox(height: CSizes.largeGap,),
                        
                      // - - - C U S T O M E R
                      if (!_showCustomersList)  UiTextFieldWidget(
                        textController: _customerNameController,
                        label: 'Customer',
                        onTap: _toggleShowCustomersList,
                      ),
                        
                      if (!_showCustomersList)  SizedBox(height: CSizes.largeGap,),

                      // - - - L I S T
                      if (_showCustomersList) ConstrainedBox(
                        constraints: BoxConstraints( maxHeight: 400,  ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CColors.whiteShade1,
                            border: Border.all(width: 1, color: CColors.whiteShade2),
                            borderRadius: BorderRadius.circular(CSizes.largeGap)
                          ),
                          margin: EdgeInsets.only(bottom: CSizes.largeGap),
                          child: BlocBuilder<CustomerCubit, CustomerState>(
                            builder: (context, state) {
                              if (state.customersDataList.isEmpty) {
                                return Padding(
                                  padding: EdgeInsets.all(CSizes.largeGap),
                                  child: UiTitleWidget(text: 'No customers are founded', bold: false,)
                                );
                              }
                              return ListView.separated(
                                padding: EdgeInsets.all(CSizes.largeGap),
                                shrinkWrap: true,
                                physics: AlwaysScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final customer = state.customersDataList[index];
                                  return _customerListTile(
                                    index: index,
                                    customer: customer,
                                    onClick: () => _handleCustomerChange(customer)
                                  );
                                }, 
                                separatorBuilder: (context, index) => Divider( height: 1, color: CColors.whiteShade2, indent: 47, ), 
                                itemCount: state.customersDataList.length
                              );
                            },
                          ),
                        ),
                      ),
                        
                        
                      // - - - A M O U N T
                      if (!_showCustomersList) UiTextFieldWidget(
                        textController: _creditAmountController,
                        label: 'total amount',
                        fieldSubmit: (_) => _handleSubmit(),
                      ),

                      if (!_showCustomersList)  SizedBox(height: CSizes.largeGap,),

                      UiFormMessage(message: _errorMessage),
                        
                      // - - - B U T T O N S
                      Row(
                        children: [
                          Expanded(
                            child: UiButtonWidget(
                              text: 'cancel',
                              tranparent: true,
                              onClick: widget.onCancel
                            )
                          ),
                        
                          if (!_showCustomersList)  SizedBox(width: CSizes.mediumGap,),
                        
                          if (!_showCustomersList)  Expanded(
                            child: UiButtonWidget(
                              text: 'add',
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
          ),
        ),
      ),
    );
  }




  // - - - - - - 
  // - - - - - - 
  // - - - - - - 




  // 
  GestureDetector _customerListTile({
    required int index,
    required CustomerModel customer,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Expanded(
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
                        
                    UiTitleWidget(text: customer.customerName, bold: false,)
                        
                  ],
                ),
              ),

              SizedBox(width: CSizes.mediumGap,),

              UiTitleWidget(text: customer.phoneNumber, bold: false, color: CColors.whiteShade3,)

            ],
          ),
        ),
      ),
    );
  }
}