import 'package:flutter/material.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/models/order_session_model.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';

class OrderSessionsDisplayWidget extends StatelessWidget {
  final List<OrderSessionModel> orderSessions;
  final void Function() addNewSession;
  final void Function(int sessionId) changeActiveSessionId;
  final int? activeSessionId;

  const OrderSessionsDisplayWidget({
    super.key,
    required this.orderSessions,
    required this.addNewSession,
    required this.changeActiveSessionId,
    required this.activeSessionId
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: CSizes.largeGap),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemBuilder: (context, index) => orderSessionButtonMethod(
                orderSession: orderSessions[index],
                isActive: orderSessions[index].sessionId == activeSessionId, 
                onSessionClick: (sessionId) => changeActiveSessionId(sessionId),
              ), 
              separatorBuilder: (context, index) => SizedBox(width: CSizes.mediumGap,), 
              itemCount: orderSessions.length
            ),
        
            SizedBox(width: CSizes.mediumGap,),
        
            UiButtonWidget(
              icon: CIcons.addIcon,
              onClick: addNewSession,
              horizontalPadding: 0,
              vericalPadding: 0,
              width: 40,
              tranparent: true,
            )
          ],
        ),
      ),
    );
  }





  // - - - - - -
  // - - - M E T H O D S
  // - - - - - -
  




  // - - - O R D E R _ S E S S I O N _ B U T T O N _ M E T H O D
  GestureDetector orderSessionButtonMethod({ 
    required OrderSessionModel orderSession, 
    required bool isActive, 
    required void Function(int sessionId) onSessionClick,
  }) {
    return GestureDetector(
      child: UiButtonWidget(
        text: orderSession.sessionId.toString(),
        onClick: () => onSessionClick(orderSession.sessionId),
        tranparent: !isActive,
        horizontalPadding: 0,
        vericalPadding: 0,
        width: 40,
      ),
    );
  }
}