import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class LoginDecorSectionWidget extends StatelessWidget {
  const LoginDecorSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [CColors.white, CColors.deepPurple])
      ),
      child: Column(
        children: [
          UiTitleWidget(text: 'decor')
        ],
      ),
    );
  }
}