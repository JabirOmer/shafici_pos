import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shafici_pos/constants/shadows.dart';
import 'package:provider/provider.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/providers/app_info_provider.dart';
import 'package:shafici_pos/providers/app_routes_provider.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class LoginFormSectionWidget extends StatelessWidget {
  final TextEditingController phoneNumberController;
  final TextEditingController passwordController;
  final bool hidePassword;
  final void Function() toggleHidePassword;
  final void Function() onSubmit;
  final bool isLoading;

  const LoginFormSectionWidget({
    super.key,
    required this.phoneNumberController,
    required this.passwordController,
    required this.hidePassword,
    required this.toggleHidePassword,
    required this.onSubmit,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final AppInfoProvider appInfoProvider = context.watch<AppInfoProvider>();
    final deviceData = appInfoProvider.deviceData;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      
          Padding(
            padding: EdgeInsets.symmetric(horizontal: CSizes.xLargeGap),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 600
              ),
              child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: CColors.white,
                  borderRadius: BorderRadius.circular(CSizes.smallRadius + 20),
                  boxShadow: CShadows.shadow1
                ),
                padding: EdgeInsets.symmetric(
                  vertical: CSizes.xLargeGap,
                  horizontal: CSizes.xLargeGap
                ),
                child: Form(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/mizan-logo-small-and-rounded.png',
                            height: 40,
                          ),

                          SizedBox(width: CSizes.mediumGap,),

                          UiTitleWidget(text: 'Shafici POS', defaultText: true, bigger: true,)
                        ],
                      ),

                      SizedBox(height: CSizes.xLargeGap,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          UiTitleWidget(text: 'Branch:', medium: true,),
                          UiTitleWidget(text: deviceData?.branchName ?? '---', medium: true,)
                        ],
                      ),

                      // UiTitleWidget(text: deviceData?.businessName ?? '---', textAlign: TextAlign.center, bigger: true,),

                      // SizedBox(height: CSizes.mediumGap,),

                      // UiTitleWidget(text: 'Login', textAlign: TextAlign.center, bigger: true,),
            
                      SizedBox(height: CSizes.xLargeGap,),
            
                      SizedBox(
                        height: 48,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: CColors.whiteShade1,
                                borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
                              child: SvgPicture.asset(
                                CIcons.phoneIcon,
                                height: 16,
                              ),
                            ),
                        
                            SizedBox(width: CSizes.mediumGap,),
                        
                            Expanded(
                              child: UiTextFieldWidget(
                                textController: phoneNumberController, 
                                keyboardType: TextInputType.phone,
                                label: 'phone number',
                              ),
                            ),
                          ],
                        ),
                      ),
            
                      SizedBox(height: CSizes.xLargeGap,),
            
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                  color: CColors.whiteShade1,
                                  borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                ),
                                padding: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
                                child: SvgPicture.asset(
                                  CIcons.lockIcon,
                                  height: 16,
                                ),
                              ),
                          
                            SizedBox(width: CSizes.mediumGap,),
                        
                            Expanded(
                              child: UiTextFieldWidget(
                                textController: passwordController, 
                                keyboardType: TextInputType.number,
                                obscureText: hidePassword,
                                label: 'pin number',
                                fieldSubmit: (value) => onSubmit(),
                              ),
                            ),
                        
                            SizedBox(width: CSizes.mediumGap,),
                        
                            UiButtonWidget(
                              icon: hidePassword ? CIcons.eyeOpen : CIcons.eyeClosed, 
                              onClick: toggleHidePassword,
                              tranparent: true,
                              horizontalPadding: CSizes.mediumGap,
                              // vericalPadding: 13,
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: CSizes.xLargeGap,),
            
                      UiButtonWidget(
                        text: 'submit',
                        onClick: onSubmit,
                        isDisabled: isLoading,
                        vericalPadding: CSizes.mediumGap,
                      ),  

                      SizedBox(height: CSizes.xLargeGap,),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          UiTitleWidget(
                            text: 'Developed by',
                            color: CColors.whiteShade3,
                            bold: false,
                          ),


                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                CIcons.saqrIcon,
                                height: 18,
                              ),
                          
                              SizedBox(width: CSizes.smallGap,),
                          
                              UiTitleWidget(
                                text: 'SAQR Innovations',
                                bold: false,
                                defaultText: true,
                              ),
                            ],
                          ),
                        ],
                      ),                  
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