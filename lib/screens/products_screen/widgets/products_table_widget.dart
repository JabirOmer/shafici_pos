// import 'package:flutter/material.dart';
// import 'package:shafici_pos/constants/colors.dart';
// import 'package:shafici_pos/constants/icons.dart';
// import 'package:shafici_pos/constants/sizes.dart';
// import 'package:shafici_pos/helpers/helper_functions.dart';
// import 'package:shafici_pos/models/product_model.dart';
// import 'package:shafici_pos/ui/ui_button_widget.dart';
// import 'package:shafici_pos/ui/ui_title_widget.dart';

// class ProductsTableWidget extends StatelessWidget {
//   final List<ProductModel> products;

//   const ProductsTableWidget({
//     super.key,
//     required this.products,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return ConstrainedBox(
//       constraints: BoxConstraints(minWidth: 3000),
//       child: SizedBox(
//         height: 300,
//         width: MediaQuery.of(context).size.width,
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Container(
//             color: CColors.primaryColor,
//             child: ListView.builder(
//               padding: EdgeInsets.all(0),
//               shrinkWrap: true,
//               itemBuilder: (context, index) {
//                 final product = products[index];
//                 return _productTileMothod(
//                   index: index,
//                   product: product
//                 );
//               }, 
//               itemCount: products.length
//             )
//           ),
//         ),
//       ),
//     );
//   }




//   // - - - - - -
//   // - - - M E T H O D S
//   // - - - - - -




//   // - - - P R O D U C T _ T I L E
//   Container _productTileMothod({
//     required int index,
//     required ProductModel product
//   }) {
//     return Container(
//       decoration: BoxDecoration(
//         color: index.isEven ? CColors.white : CColors.whiteShade2,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 32,
//             child: UiTitleWidget(
//               text: (index+1).toString().padLeft(2, '0'),
//               bold: false,
//             ),
//           ),

//           SizedBox(width: CSizes.mediumGap,),

//           UiTitleWidget(
//             text: product.productName,
//             capitalizeWords: true,
//             bold: false,
//           ),

//           SizedBox(width: CSizes.mediumGap,),

//           UiTitleWidget(
//             text: product.stock.toString(),
//             capitalizeWords: true,
//             bold: false,
//           ),

//           SizedBox(width: CSizes.mediumGap,),

//           UiTitleWidget(
//             text: product.categoryName,
//             capitalizeWords: true,
//             bold: false,
//           ),

//           SizedBox(width: CSizes.mediumGap,),

//           UiTitleWidget(
//             text: '${CHelperFunctions.formatNumberWithComma(product.sellingPrice)}birr',
//             capitalizeWords: true,
//             bold: false,
//           ),

//           SizedBox(width: CSizes.mediumGap,),

//           UiTitleWidget(
//             text: product.expireDate == null ? '---' : CHelperFunctions.formatDateTime(product.expireDate!),
//             capitalizeWords: true,
//             bold: false,
//           ),

//           SizedBox(width: CSizes.mediumGap,),

//           UiButtonWidget(
//             icon: CIcons.eyeOpen,
//             text: 'see more',
//             vericalPadding: CSizes.smallGap,
//             horizontalPadding: CSizes.smallGap,
//             onClick: () {}
//           )
//         ]
//       ),
//     );
//   }
// }







// //     return Container(
// //       decoration: BoxDecoration(
// //         color: index.isEven ? CColors.white : CColors.whiteShade2,
// //       ),
// //       padding: EdgeInsets.all(CSizes.mediumGap),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           SizedBox(
// //             width: 32,
// //             child: UiTitleWidget(
// //               text: (index+1).toString().padLeft(2, '0'),
// //               bold: false,
// //             ),
// //           ),

// //           SizedBox(width: CSizes.mediumGap,),

// //           Expanded(
// //             child: UiTitleWidget(
// //               text: product.productName,
// //               capitalizeWords: true,
// //               bold: false,
// //             ),
// //           ),

// //           SizedBox(width: CSizes.mediumGap,),

// //           Expanded(
// //             child: UiTitleWidget(
// //               text: product.stock.toString(),
// //               capitalizeWords: true,
// //               bold: false,
// //             ),
// //           ),

// //           SizedBox(width: CSizes.mediumGap,),

// //           Expanded(
// //             child: UiTitleWidget(
// //               text: product.categoryName,
// //               capitalizeWords: true,
// //               bold: false,
// //             ),
// //           ),

// //           SizedBox(width: CSizes.mediumGap,),

// //           Expanded(
// //             child: UiTitleWidget(
// //               text: '${CHelperFunctions.formatNumberWithComma(product.sellingPrice)}birr',
// //               capitalizeWords: true,
// //               bold: false,
// //             ),
// //           ),

// //           SizedBox(width: CSizes.mediumGap,),

// //           Expanded(
// //             child: UiTitleWidget(
// //               text: product.expireDate == null ? '---' : CHelperFunctions.formatDateTime(product.expireDate!),
// //               capitalizeWords: true,
// //               bold: false,
// //             ),
// //           ),

// //           SizedBox(width: CSizes.mediumGap,),

// //           UiButtonWidget(
// //             icon: CIcons.eyeOpen,
// //             text: 'see more',
// //             vericalPadding: CSizes.smallGap,
// //             horizontalPadding: CSizes.smallGap,
// //             onClick: () {}
// //           )
// //         ],
// //       ),
// //     );
// //   }
// // }