import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/bulk_register_message_model.dart';
import 'package:shafici_pos/ui/ui_popup_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class BulkRegisterAlertWidget extends StatefulWidget {
  final BulkRegisterMessageModel info;

  const BulkRegisterAlertWidget({
    super.key,
    required this.info
  });

  @override
  State<BulkRegisterAlertWidget> createState() => _BulkRegisterAlertWidgetState();
}

class _BulkRegisterAlertWidgetState extends State<BulkRegisterAlertWidget> {
  bool _showDublicated = false;
  bool _showFailed = false;

  void _clearShows() {
    setState(() {
      _showDublicated = false;
      _showFailed = false;
    });
  }

  void _toggleShowDublicated() {
    setState(() {
      _showDublicated = !_showDublicated;
      _showFailed = false;
    });
  }

  void _toggleShowFails() {
    setState(() {
      _showFailed = !_showFailed;
      _showDublicated = false;
    });
    
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        // 
        Row(
          children: [
            _countMethod(
              title: 'Successfull:',
              value: widget.info.successfullImports.length,
              color: CColors.green,
              onClick: _clearShows
            ),
            
            SizedBox(width: CSizes.mediumGap,),
            
            _countMethod(
              title: 'Dublicated:',
              value: widget.info.dublicatedImports.length,
              color: CColors.whiteShade3,
              onClick: _toggleShowDublicated
            ),
            
            SizedBox(width: CSizes.mediumGap,),
            
            _countMethod(
              title: 'Failed:',
              value: widget.info.failedImports.length,
              color: CColors.red,
              onClick: _toggleShowFails
            ),
          ],
        ),

        // 
        if (widget.info.dublicatedImports.isNotEmpty && _showDublicated) GestureDetector(
          onTap: _toggleShowDublicated,
          child: Container(
            decoration: BoxDecoration(
              color: CColors.whiteShade1,
              borderRadius: BorderRadius.circular(16)
            ),
            padding: EdgeInsets.all(CSizes.largeGap),
            margin: EdgeInsets.only(top: CSizes.largeGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiTitleWidget(text: 'Dublicates'),
          
                SizedBox(height: CSizes.mediumGap),
          
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final error = widget.info.dublicatedImports[index];
                    return UiTitleWidget(text: error, bold: false,);
                  },
                  separatorBuilder: (context, index) => Divider(height: CSizes.mediumGap, color: CColors.whiteShade3,),
                  itemCount: widget.info.dublicatedImports.length,
                ),
              ],
            ),
          ),
        ),

        // 
        if (widget.info.failedImports.isNotEmpty && _showFailed) GestureDetector(
          onTap: _toggleShowFails,
          child: Container(
            decoration: BoxDecoration(
              color: CColors.redDimmed,
              borderRadius: BorderRadius.circular(16)
            ),
            padding: EdgeInsets.all(CSizes.largeGap),
            margin: EdgeInsets.only(top: CSizes.largeGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiTitleWidget(text: 'Fails'),
          
                SizedBox(height: CSizes.mediumGap),
          
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final error = widget.info.failedImports[index];
                    return UiTitleWidget(text: error, bold: false,);
                  },
                  separatorBuilder: (context, index) => Divider(height: CSizes.mediumGap, color: CColors.whiteShade3,),
                  itemCount: widget.info.failedImports.length,
                ),
              ],
            ),
          ),
        )

        // 

      ],
    );
  }

  Expanded _countMethod({
    required String title,
    required int value,
    required Color color,
    required void Function() onClick
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onClick,
        child: Container(
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              border: Border.all(width: 1, color: color),
              borderRadius: BorderRadius.circular(24)
            ),
            padding: EdgeInsets.all(CSizes.mediumGap),
            child: Column(
              children: [
                UiTitleWidget(text: title, bold: false,),
                SizedBox(height: CSizes.mediumGap,),
                UiTitleWidget(text: value.toString().padLeft(2, '0'),),
              ],
            ),
          ),
      ),
    );
  }
}