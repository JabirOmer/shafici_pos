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

class RegisterProductCategoryPoup extends StatefulWidget {
  final void Function(bool reload) onBackCall;

  const RegisterProductCategoryPoup({
    super.key,
    required this.onBackCall
  });

  @override
  State<RegisterProductCategoryPoup> createState() => _RegisterProductCategoryScreenState();
}

class _RegisterProductCategoryScreenState extends State<RegisterProductCategoryPoup> {
  final CApiServices _apiServices = CApiServices();
  final CSecureStorageService _secureStorageService = CSecureStorageService();

  final TextEditingController _categoryNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _successMessage;
  String? _errorMessage;


  // - - - V A L I D A T I O N
  String? _validateCategoryName(String? value) {
    if (value == null || value.isEmpty) return 'Category name is missing';
    return null;
  }


  // - - - F U N C T I O N S
  Future<void> _handleSubmitClick() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final dataMap = { "category_name": _categoryNameController.text.trim().toLowerCase() };
        final deviceToken = await _secureStorageService.read(CSecureStrings.deviceToken);
        final response = await _apiServices.postRequest(url: CUrlStrings.registerCategoryUrl, data: dataMap, authToken: deviceToken);

        switch (response.statusCode) {
          case 201: _successMessage = response.data['msg'];
          default: _errorMessage = response.data;
        }
      } catch (e) {
        _errorMessage = 'failed to register category';
      } finally {
        setState(() => _isLoading = false);
        await Future.delayed(Duration(seconds: 2));
        if (mounted) _successMessage != null ? widget.onBackCall(true) : setState(() => _errorMessage = null);
      }
    }
  }


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
                                      text: 'register category',
                                      bigger: true,
                                      textAlign: TextAlign.center,
                                      capitalizeWords: true,
                                    ),
                                    
                                    SizedBox(height: CSizes.largeGap,),
                                    
                                    // - - - P R O D U C T _ N A M E
                                    UiTextFieldWidget(
                                      textController: _categoryNameController,
                                      label: 'category name',
                                      validator: (value) => _validateCategoryName(value),
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
                                    
                                  ],
                                ),
                              )
                            )
                          )
                        ),
                      )
            
                    ],
                  )
                )
              )
            ),
          ),
        ),
      ),
    );
  }
}