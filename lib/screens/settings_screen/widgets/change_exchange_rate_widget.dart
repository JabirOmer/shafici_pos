import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/secure_strings.dart';
import 'package:shafici_pos/constants/shared_prefs_keys.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/constants/url_strings.dart';
import 'package:shafici_pos/services/api_services.dart';
import 'package:shafici_pos/services/secure_store_services.dart';
import 'package:shafici_pos/services/shared_preferences_services.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:shafici_pos/ui/ui_toggle_button_widget.dart';

class ChangeExchangeRateWidget extends StatefulWidget {
  final void Function() onCancel;

  const ChangeExchangeRateWidget({
    super.key,
    required this.onCancel
  });

  @override
  State<ChangeExchangeRateWidget> createState() => _ChangeExchangeRateWidgetState();
}

class _ChangeExchangeRateWidgetState extends State<ChangeExchangeRateWidget> {
  late String currentExchange;

  final CSharedPreferencesServices _sharedPreferencesServices = CSharedPreferencesServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();
  final CApiServices _apiServices = CApiServices();

  final _formKey = GlobalKey<FormState>();
  final _newExchangeController = TextEditingController();
  bool _updateProducts = true;

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;


  // - - - - - - >>
  // - - - V A L I D A T I O N S
  String? _validateExchange(String? value) {
    if (value == null || value.isEmpty) return 'exchange rate is missing';
    if (double.tryParse(value) == null) return 'invalid exchange';
    return null;
  }
  // - - - V A L I D A T I O N S
  // - - - - - - >>

  
  // - - - - - - >>
  // - - - F U N C T I O N S
  void _toggleUpdateProducts() {
    setState(() => _updateProducts = !_updateProducts,);
  }

  Future<void> _handleExchangeChange() async {
    if (_formKey.currentState!.validate()) {
      
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      if (!_updateProducts) {
        try {
          await _sharedPreferencesServices.setString(CSharedPrefsKeys.exchangeRate, _newExchangeController.text );
          setState(() => _successMessage = 'Exchange rate changed (Locally)');
        } catch (e) {
          setState(() => _errorMessage = 'Failed to update exchange-rate');
        } finally {
          await Future.delayed(Duration(seconds: 2));
          if (mounted) _successMessage != null ? widget.onCancel() : setState(() => _errorMessage = null);
        }
      } else {
        try {
          setState(() => _isLoading = true);

          final data = { 
            'exchange_rate': _newExchangeController.text 
          };
          final token = await _secureStorageService.read(CSecureStrings.deviceToken);
          final response = await _apiServices.patchRequest(url: CUrlStrings.updateExchangeRateUrl, data: data, authToken: token);
          if (!mounted) return;

          switch (response.statusCode) {
            case 200: {
              await _sharedPreferencesServices.setString(CSharedPrefsKeys.exchangeRate, _newExchangeController.text );
              _successMessage = response.data['msg'];
            }
            default: _errorMessage = response.data;
          }
        } catch (e) {
          _errorMessage = 'Failed to update exchange-rate';
        } finally {
            setState(() => _isLoading = false); 
            await Future.delayed(Duration(seconds: 2));
            if (mounted) _successMessage != null ? widget.onCancel() : setState(() => _errorMessage = null);
        }
      }
      
    }
  }
  // - - - F U N C T I O N S
  // - - - - - - >>


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentExchange = _sharedPreferencesServices.getString(CSharedPrefsKeys.exchangeRate) ?? '180';
  }

  @override
  void dispose() {
    // _formKey.currentState?.dispose();
    _newExchangeController.dispose();
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
                              UiTitleWidget(text: 'update exchange rate', bigger: true,),

                              SizedBox(height: CSizes.largeGap,),
                          
                              UiTextFieldWidget(
                                hint: 'Current Exchange',
                                initialValue: currentExchange,
                                enabled: false,
                              ),
                          
                              SizedBox(height: CSizes.largeGap,),

                              Container(
                                decoration: BoxDecoration(
                                  color: CColors.whiteShade2,
                                  borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                ),
                                padding: EdgeInsets.all(CSizes.mediumGap),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    UiTitleWidget(
                                      text: 'update products price',
                                      bold: false,
                                    ),
                                
                                    UiToggleButtonWidget(
                                      isOn: _updateProducts, 
                                      onClick: _toggleUpdateProducts,
                                      smaller: true,
                                    )
                                  ],
                                ),
                              ),

                              SizedBox(height: CSizes.largeGap,),

                              UiTextFieldWidget(
                                label: 'new exchange rate',
                                keyboardType: TextInputType.number,
                                textController: _newExchangeController,
                                validator: (value) => _validateExchange(value),
                                fieldSubmit: (value) => _handleExchangeChange(),
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
                                      onClick: _handleExchangeChange,
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