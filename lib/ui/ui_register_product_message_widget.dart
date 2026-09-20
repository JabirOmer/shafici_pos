import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shafici_pos/constants/animations.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/register_product_message_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';
import 'package:lottie/lottie.dart';

class UiRegisterProductMessageWidget extends StatefulWidget {
  final RegisterProductMessageModel message;
  final void Function() onCancel;

  const UiRegisterProductMessageWidget({
    super.key,
    required this.message,
    required this.onCancel
  });

  @override
  State<UiRegisterProductMessageWidget> createState() => _UiRegisterProductMessageWidgetState();
}

class _UiRegisterProductMessageWidgetState extends State<UiRegisterProductMessageWidget> {
  bool _showDublicates = false;
  bool _showFails = false;


  void _toggleShowDublicates() {
    setState(() => _showDublicates = !_showDublicates);
  }

  void _toggleShowFails() {
    setState(() => _showFails = !_showFails);
  }

  @override
  Widget build(BuildContext context) {
    // final List<importsModel> ss = List.generate(
    //   10, 
    //   (i) => importsModel(
    //     productName: 'product ${(i+1).toString().padLeft(2, '0')}',
    //     error: i.isEven ? null : 'ejhvjh jhvujhv. kjvi kb jh. jiuvuyvrror ${i+1}'
    //   )
    // );

    return Scaffold(
      backgroundColor: CColors.dimmedBackgound,
      body: GestureDetector(
        onTap: widget.onCancel,
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: CSizes.blurSigma, sigmaY: CSizes.blurSigma),
            child: GestureDetector(
              onTap: () {},
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                        maxWidth: 800
                      ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CColors.white,
                      borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                    ),
                    padding: EdgeInsets.all(CSizes.largeGap),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                    
                          // - - - I C O N
                          Lottie.asset(
                            height: 96,
                            CAnimations.animation2,
                            repeat: false
                          ),

                          // if (widget.message.successMessage != null) Lottie.asset(
                          //   height: 96,
                          //   CAnimations.animation2
                          // ) else SvgPicture.asset(
                          //   CIcons.warningIcon,
                          //   height: 64,
                          //   colorFilter: ColorFilter.mode(CColors.red, BlendMode.srcIn),
                          // ),
                    
                          
                          SizedBox(height: CSizes.xLargeGap,),
                      
                    
                          // // - - - E R R O R S
                          // if (widget.message.errorMessage != null) UiTitleWidget(
                          //   text: widget.message.errorMessage!,
                          //   textAlign: TextAlign.center,
                          // ),
                      
                      
                          // - - - M E S S A G E
                          UiTitleWidget(
                            text: widget.message.successMessage,
                            textAlign: TextAlign.center,
                            bigger: true,
                            bold: false,
                            capitalizeWords: true,
                          ),
                    
                          
                          SizedBox(height: CSizes.xLargeGap,),
        
        
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // - - - S U C C E S S E S
                              Expanded(
                                // flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1, color: CColors.green),
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.all(CSizes.mediumGap),
                                  child: Column(
                                    children: [
                                      UiTitleWidget(
                                        text: 'success',
                                        color: CColors.green,
                                        bold: false,
                                      ),
                                                    
                                      UiTitleWidget(
                                        text: widget.message.successfulImports.toString().padLeft(2, '0'),
                                        color: CColors.green,
                                        bigger: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
        
                              // SizedBox(width: CSizes.xLargeGap,),
        
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CColors.whiteShade1,
                                    border: Border.all(width: 1, color: CColors.whiteShade2),
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.all(CSizes.mediumGap),
                                  margin: EdgeInsets.symmetric(horizontal: CSizes.mediumGap),
                                  child: Column(
                                    children: [
                                      UiTitleWidget(
                                        text: 'dublicates:',
                                        bold: false,
                                      ),
                                                    
                                      UiTitleWidget(
                                        text: widget.message.dublicatedImports.length.toString().padLeft(2, '0'),
                                        bigger: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                                                            
                                                            
                              // - - - F A I L E D
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CColors.whiteShade1,
                                    border: Border.all(width: 1, color: widget.message.failedImports.isEmpty ? CColors.whiteShade2 : CColors.red),
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.all(CSizes.mediumGap),
                                  child: Column(
                                    children: [
                                      UiTitleWidget(
                                        text: 'fails:',
                                        color: CColors.red,
                                        bold: false,
                                      ),
                                                    
                                      UiTitleWidget(
                                        text: widget.message.failedImports.length.toString().padLeft(2, '0'),
                                        color: CColors.red,
                                        bigger: true,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          
                          
                          SizedBox(height: CSizes.xLargeGap,),

                          if (widget.message.failedImports.isNotEmpty) _displayMessageList(
                            messageList: widget.message.failedImports,
                            title: 'failed',
                            showDetails: _showFails,
                            onToggleClick: _toggleShowFails,
                            red: true
                          ),

                          if (widget.message.failedImports.isNotEmpty) SizedBox(height: CSizes.xLargeGap,),

                          if (widget.message.dublicatedImports.isNotEmpty) _displayMessageList(
                            messageList: widget.message.dublicatedImports,
                            title: 'dublicates',
                            showDetails: _showDublicates,
                            onToggleClick: _toggleShowDublicates
                          ),

                          if (widget.message.dublicatedImports.isNotEmpty) SizedBox(height: CSizes.xLargeGap,),
            
        
                          UiButtonWidget(
                            text: 'back',
                            onClick: widget.onCancel,
                          )
                      
                        ],
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
  Container _displayMessageList({
    required List<ImportsModel> messageList,
    required String title,
    required bool showDetails,
    required void Function() onToggleClick,
    bool red = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(width: 1, color: CColors.whiteShade2),
        borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
      ),
      padding: EdgeInsets.all(CSizes.mediumGap,),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: onToggleClick,
            child: Container(
              decoration: BoxDecoration(
                color: CColors.whiteShade1,
                border: Border.all(width: 1, color: CColors.whiteShade2),
                borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
              ),
              padding: EdgeInsets.all(CSizes.smallGap),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // - - - T I T L E
                  UiTitleWidget(
                    text: title,
                    bold: false,
                  ),
              
                  // - - - D R O P D O W N _ I C O N
                  SvgPicture.asset(
                    showDetails ? CIcons.arrowToUp : CIcons.arrowToDown,
                    colorFilter: ColorFilter.mode(CColors.whiteShade3, BlendMode.srcIn),
                  )
                ],
              ),
            ),
          ),

          if (showDetails) SizedBox(height: CSizes.mediumGap,),

          if (showDetails) ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 250),
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final item = messageList[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: CColors.whiteShade1,
                            borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                          ),
                          padding: EdgeInsets.symmetric(vertical: 4),
                          width: 30,
                          child: UiTitleWidget(
                            text: (index+1).toString().padLeft(2, '0'),
                            bold: false,
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(width: CSizes.smallGap,),
                                
                        UiTitleWidget(
                          text: item.productName,
                          bold: false,
                        ),
                      ],
                    ),

                    SizedBox(width: CSizes.smallGap,),

                    if (item.error != null) Expanded(
                      child: UiTitleWidget(
                        text: item.error!,
                        bold: false,
                        color: CColors.red,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) => SizedBox(height: CSizes.smallGap,),
              itemCount: messageList.length,
            ),
          ),

        ],
      ),
    );
  }
}