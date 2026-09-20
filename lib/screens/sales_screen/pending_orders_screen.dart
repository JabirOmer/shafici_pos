// import 'package:flutter/material.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:shafici_pos/constants/animations.dart';
// import 'package:shafici_pos/constants/colors.dart';
// import 'package:shafici_pos/constants/sizes.dart';
// import 'package:shafici_pos/helpers/helper_functions.dart';
// import 'package:shafici_pos/models/order_data_model.dart';
// import 'package:shafici_pos/providers/orders_provider.dart';
// import 'package:shafici_pos/screens/order_details_screen/order_details_screen.dart';
// import 'package:shafici_pos/ui/ui_no_data_founded.dart';
// import 'package:shafici_pos/ui/ui_title_widget.dart';
// import 'package:provider/provider.dart';

// class PendingOrdersScreen extends StatefulWidget {
//   const PendingOrdersScreen({super.key});

//   @override
//   State<PendingOrdersScreen> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<PendingOrdersScreen> {

//   int _getCrossAxisCount(double maxWidth) {
//     if (maxWidth < 800) { return 3; }
//     else if (maxWidth < 1000) { return 4; }
//     else if (maxWidth < 1200) { return 5; }
//     else if (maxWidth < 1400) { return 6; }
//     else { return 7; }
//   }


//   void _handleShowDetails(OrderDataModel order) {
//     CHelperFunctions.navigateToScreen(context: context, screen: OrderDetailsScreen());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [


//           // - - - D I S P L A Y _ P E N D I N G _ O R D E R S
//           Padding(
//             padding: EdgeInsetsGeometry.all(CSizes.largeGap),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 UiTitleWidget(text: 'Pending Orders', bigger: true,),

//                 SizedBox(height: CSizes.largeGap,),

//                 Consumer<OrdersProvider>(
//                   builder: (context, provider, child) {
                    
//                     // No Orders
//                     if (provider.pendingOrders.isEmpty) {
//                       return UiNoDataFounded(
//                         title: 'pending orders will be listed here',
//                         noDataAnimation: CAnimations.emptyList,
//                       );
//                     }

//                     return LayoutBuilder(
//                       builder: (context, constraints) {
                        
//                         int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

//                         return Expanded(
//                           child: MasonryGridView.count(
//                             shrinkWrap: true,
//                             crossAxisCount: crossAxisCount,
//                             crossAxisSpacing: CSizes.mediumGap,
//                             mainAxisSpacing: CSizes.mediumGap, 
//                             itemCount: provider.pendingOrders.length, 
//                             itemBuilder: (context, index) => _pendingOrderTileWidget(
//                               order: provider.pendingOrders[index],
//                               onShowDetails: () => _handleShowDetails(provider.pendingOrders[index])
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   },
//                 )
//               ],
//             ),
//           ),

//         ],
//       ),
//     );
//   }





//   // - - - - - - 
//   // - - - M E T H O D S
//   // - - - - - - 




//   // P E N D I N G _ O R D E R _ T I L E
//   MouseRegion _pendingOrderTileWidget({
//     required OrderDataModel order,
//     required void Function() onShowDetails,
//   }) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: GestureDetector(
//         onTap: onShowDetails,
//         child: Container(
//           decoration: BoxDecoration(
//             color: CColors.white,
//             borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
//           ),
//           padding: EdgeInsets.all(CSizes.largeGap),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               UiTitleWidget(
//                 text: CHelperFunctions.formatDateTime(order.createdAt, addTime: true), 
//                 capitalizeWords: true, 
//                 bold: false,
//                 textAlign: TextAlign.center,
//               ),
            
//               SizedBox(height: CSizes.smallGap,),
            
//               Container(
//                 height: 1,
//                 color: CColors.whiteShade2,
//               ),
            
//               SizedBox(height: CSizes.mediumGap,),
            
//               UiTitleWidget(
//                 text: '${CHelperFunctions.formatNumberWithComma(order.orderCalculation.grandTotal, addDecimal: false)} Birr', 
//                 capitalizeWords: true,
//                 bigger: true,
//                 textAlign: TextAlign.center,
//               ),
            
//               SizedBox(height: CSizes.mediumGap,),
            
//               Container(
//                 height: 1,
//                 color: CColors.whiteShade2,
//               ),
            
//               SizedBox(height: CSizes.smallGap,),
            
//               Row(
//                 children: [
//                   UiTitleWidget(
//                     text: 'saller: ',
//                     bold: false,
//                     color: CColors.whiteShade3,
//                   ),
            
//                   Expanded(
//                     child: UiTitleWidget(
//                       text: order.sellerName, 
//                       capitalizeWords: true, 
//                       bold: false,
//                       textAlign: TextAlign.end,
//                     )
//                   ),
//                 ],
//               ),
              
//             ],
//           ),
//         ),
//       ),
//     );
//   }

// }