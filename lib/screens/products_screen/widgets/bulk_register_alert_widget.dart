import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/bulk_register_message_model.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class BulkRegisterAlertWidget extends StatelessWidget {
  final BulkRegisterMessageModel info;

  const BulkRegisterAlertWidget({
    super.key,
    required this.info
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // 
        UiTitleWidget(text: 'Successfull imports: ${info.successfullImports.length}'),

        SizedBox(height: CSizes.mediumGap,),

        if (info.dublicatedImports.isEmpty) UiTitleWidget(text: 'No Dublicates'),
        if (info.dublicatedImports.isNotEmpty) Container(
          decoration: BoxDecoration(
            color: CColors.whiteShade1,
            borderRadius: BorderRadius.circular(16)
          ),
          padding: EdgeInsets.all(CSizes.largeGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiTitleWidget(text: 'Dublicates'),

              SizedBox(height: CSizes.mediumGap),

              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final error = info.dublicatedImports[index];
                  return UiTitleWidget(text: error, bold: false,);
                },
                separatorBuilder: (context, index) => Divider(height: CSizes.mediumGap, color: CColors.whiteShade3,),
                itemCount: info.dublicatedImports.length,
              ),
            ],
          ),
        ),

        SizedBox(height: CSizes.mediumGap,),

        //
        if (info.failedImports.isEmpty) UiTitleWidget(text: 'No Fails'), 
        if (info.failedImports.isNotEmpty) Container(
          decoration: BoxDecoration(
            color: CColors.redDimmed,
            borderRadius: BorderRadius.circular(16)
          ),
          padding: EdgeInsets.all(CSizes.largeGap),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiTitleWidget(text: 'Fails'),

              SizedBox(height: CSizes.mediumGap),

              ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final error = info.failedImports[index];
                  return UiTitleWidget(text: error, bold: false,);
                },
                separatorBuilder: (context, index) => Divider(height: CSizes.mediumGap, color: CColors.whiteShade3,),
                itemCount: info.failedImports.length,
              ),
            ],
          ),
        )

        // 

      ],
    );
  }
}