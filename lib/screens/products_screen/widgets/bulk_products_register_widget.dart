// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shafici_pos/constants/colors.dart';
// import 'package:shafici_pos/constants/icons.dart';
// import 'package:shafici_pos/constants/sizes.dart';
// import 'package:shafici_pos/screens/products_screen/register_products_screen.dart';
// import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
// import 'package:shafici_pos/ui/ui_button_widget.dart';
// import 'package:shafici_pos/ui/ui_text_field_widget.dart';
// import 'package:shafici_pos/ui/ui_title_widget.dart';

// class BulkProductsRegisterWidget extends StatefulWidget {
//   final void Function(RegisterProductType type) onSingleClick;
//   final void Function(PlatformFile file, String sheetName) onSubmit;
//   final void Function() onBackClick;

//   const BulkProductsRegisterWidget({
//     super.key,
//     required this.onSingleClick,
//     required this.onSubmit,
//     required this.onBackClick,
//   });

//   @override
//   State<BulkProductsRegisterWidget> createState() => _BulkProductsRegisterWidgetState();
// }

// class _BulkProductsRegisterWidgetState extends State<BulkProductsRegisterWidget> {
//   final TextEditingController _sheetNameController = TextEditingController();
//   PlatformFile? _selectedFile;
//   String? _fileStatus;
//   final _formKey = GlobalKey<FormState>();

//   // - - - - - - >>
//   // - - - V A L I D A T O R S
//   String? _validateSheetName(String? value) {
//     if (value == null || value.isEmpty) return 'sheet name is missing';
//     return null;
//   }
//   // - - - V A L I D A T O R S
//   // - - - - - - >>


//   // - - - - - - >>
//   // - - - F U N C T I O N S
//   // Future<void> _handleDownloadClick() async {
//   //   try {
//   //     Map<Permission, PermissionStatus> permissionStatus = await [
//   //       Permission.storage
//   //     ].request();

//   //     if (permissionStatus[Permission.storage]!.isGranted) {
//   //       print('granted');
//   //     } else {
//   //       print('not granted');
//   //     }
      
//   //   } catch (e) {
//   //     print('could not: $e');
//   //   }
//   // }

  
//   // Future<void> _handlePickFile() async {
//   //   if (_fileStatus != null) return;

//   //   setState(() => _fileStatus = 'picking file ...');

//   //   await Future.delayed(Duration(seconds: 2));

//   //   try {
//   //     FilePickerResult? result = await FilePicker.platform.pickFiles(
//   //       type: FileType.custom,
//   //       allowedExtensions: [ 'xls', 'xlsx', 'numbers', ],
//   //       allowMultiple: false
//   //     );

//   //     if (result == null) {
//   //       setState(() {
//   //         _selectedFile = null;
//   //         _fileStatus = 'no file is selected';
//   //       });
//   //       return;
//   //     }

//   //     final picked = result.files.single;
//   //     final path = picked.path;
//   //     if (path == null) {
//   //       setState(() => _fileStatus = 'selected file path is null');
//   //       return;
//   //     }
//   //     setState(() => _fileStatus = 'uploading ${picked.name}');
//   //     final file = File(path);

//   //     // final MultipartFile multipartFile = await MultipartFile.fromFile(
//   //     //   file.path,
//   //     //   filename: picked.name
//   //     // );

//   //     final 

//   //     setState(() {
//   //       _selectedFile = multipartFile;
//   //       _fileStatus = 'file is uploaded';
//   //     });
//   //   } catch (e) {
//   //     setState(() {
//   //       _fileStatus = 'failed to upload file';
//   //       _selectedFile = null;
//   //     });
//   //   } finally {
//   //     await Future.delayed(Duration(seconds: 2));
//   //     setState(() => _fileStatus = null);
//   //   }
//   // }

//   Future<void> _handlePickFile() async {
//     if (_fileStatus != null) return;
//     setState(() => _fileStatus = 'Picking file ...',);

//     try {
//       FilePickerResult? result = await FilePicker.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: [ 'xls', 'xlsx', 'numbers' ],
//         allowMultiple: false
//       );

//       if (!mounted) return;

//       if (result != null && result.files.isNotEmpty) {
//         setState(() {
//           _selectedFile = result.files.single;
//           _fileStatus = null;
//         });
//       } else {
//         setState(() {
//           _fileStatus = 'no file is selected';
//           _selectedFile = null;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _fileStatus = 'failed to pick file';
//         _selectedFile = null;
//       });
//     } finally {
//       await Future.delayed(Duration(seconds: 2));
//       if (mounted) setState(() => _fileStatus = null,);
//     }
//   }

  
//   Future<void> _handleSubmitClick() async {
//     if (_formKey.currentState!.validate()) {
//       widget.onSubmit(_selectedFile!, _sheetNameController.text.trim());
//     }
//   }
//   // - - - F U N C T I O N S
//   // - - - - - - >>

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
//         child: Padding(
//           padding: EdgeInsetsGeometry.all(CSizes.largeGap),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
              
//               // 
//               Center(
//                 child: ConstrainedBox(
//                   constraints: BoxConstraints(maxWidth: 500),
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: CColors.white,
//                       borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
//                     ),
//                     padding: EdgeInsets.all(CSizes.largeGap),
//                     child: Form(
//                       key: _formKey,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.stretch,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: UiTitleWidget(
//                                   text: 'register products',
//                                   bigger: true,
//                                   capitalizeWords: true,
//                                 ),
//                               ),


//                               UiButtonWidget(
//                                 text: 'single',
//                                 icon: CIcons.file2Icon,
//                                 vericalPadding: CSizes.smallGap,
//                                 onClick: () => widget.onSingleClick(RegisterProductType.single)
//                               )
//                             ],
//                           ),
    
//                           SizedBox(height: CSizes.xLargeGap,),

//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Expanded(
//                                 child: UiTextFieldWidget(
//                                   textController: _sheetNameController,
//                                   label: 'sheet name',
//                                   validator: (value) => _validateSheetName(value),
//                                 ),
//                               ),
                          
//                               // SizedBox(width: CSizes.mediumGap,),
                          
//                               // UiButtonWidget(
//                               //   icon: CIcons.file2Icon,
//                               //   tranparent: true,
//                               //   horizontalPadding: CSizes.mediumGap,
//                               //   // vericalPadding: 0,
//                               //   borderColor: CColors.primaryColor,
//                               //   onClick: _handleDownloadClick
//                               // ),
//                             ],
//                           ),

//                           SizedBox(height: CSizes.largeGap,),

//                           IntrinsicHeight(
//                             child: MouseRegion(
//                               cursor: SystemMouseCursors.click,
//                               child: GestureDetector(
//                                 onTap: _handlePickFile,
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color: CColors.whiteShade1,
//                                     borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
//                                   ),
//                                   padding: EdgeInsets.all(CSizes.xLargeGap),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                                     children: [
                                
//                                       SvgPicture.asset(
//                                         CIcons.file2Icon,
//                                         colorFilter: ColorFilter.mode(_selectedFile == null ? CColors.red : CColors.green, BlendMode.srcIn),
//                                         height: 48,
//                                       ),
                                
//                                       SizedBox(height: CSizes.xLargeGap,),
                              
//                                       UiTitleWidget(
//                                         text: _selectedFile?.name ?? 'no file is selected',
//                                         bold: false,
//                                         textAlign: TextAlign.center,
//                                       )
                                
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),

//                           UiAnimatedMiniMessageWidget(
//                             displayText: _fileStatus,
//                             isNeutral: true,
//                           ),

//                           SizedBox(height: CSizes.xLargeGap,),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: UiButtonWidget(
//                                   text: 'back',
//                                   tranparent: true,
//                                   onClick: widget.onBackClick
//                                 ),
//                               ),

//                               SizedBox(width: CSizes.mediumGap,),

//                               Expanded(
//                                 child: UiButtonWidget(
//                                   icon: CIcons.sendIcon,
//                                   text: 'submit',
//                                   isDisabled: _selectedFile == null || _fileStatus != null,
//                                   onClick: _handleSubmitClick,
//                                 )
//                               ),
//                             ],
//                           )
//                         ],
//                       ),
//                     )
//                   )
//                 )
//               )

//             ]
//           )
//         )
//       )
//     );
//   }
// }














// // import 'package:flutter/material.dart';
// // import 'package:file_picker/file_picker.dart';
// // import 'package:dio/dio.dart';
// // import 'dart:io';

// // class ExcelUploadWidget extends StatefulWidget {
// //   @override
// //   _ExcelUploadWidgetState createState() => _ExcelUploadWidgetState();
// // }

// // class _ExcelUploadWidgetState extends State<ExcelUploadWidget> {
// //   PlatformFile? selectedFile;
// //   bool isUploading = false;
// //   double uploadProgress = 0.0;

// //   final Dio dio = Dio();

// //   Future<void> pickExcelFile() async {
// //     try {
// //       FilePickerResult? result = await FilePicker.platform.pickFiles(
// //         type: FileType.custom,
// //         allowedExtensions: ['xlsx', 'xls'],
// //         allowMultiple: false,
// //         withData: false, // Don't load file data into memory for large files
// //       );

// //       if (result != null && result.files.isNotEmpty) {
// //         setState(() {
// //           selectedFile = result.files.first;
// //         });
// //         _showSnackBar('File selected: ${selectedFile!.name}');
// //       }
// //     } catch (e) {
// //       _showSnackBar('Error selecting file: $e');
// //     }
// //   }

// //   Future<void> uploadFileToAPI() async {
// //     if (selectedFile == null) {
// //       _showSnackBar('Please select a file first');
// //       return;
// //     }

// //     setState(() {
// //       isUploading = true;
// //       uploadProgress = 0.0;
// //     });

// //     try {
// //       FormData formData;

// //       // For file_picker ^5.5.0, use path when available
// //       if (selectedFile!.path != null) {
// //         formData = FormData.fromMap({
// //           'file': await MultipartFile.fromFile(
// //             selectedFile!.path!,
// //             filename: selectedFile!.name,
// //           ),
// //           'description': 'Excel file upload',
// //           'fileType': 'excel',
// //         });
// //       } else if (selectedFile!.bytes != null) {
// //         formData = FormData.fromMap({
// //           'file': MultipartFile.fromBytes(
// //             selectedFile!.bytes!,
// //             filename: selectedFile!.name,
// //           ),
// //           'description': 'Excel file upload',
// //           'fileType': 'excel',
// //         });
// //       } else {
// //         throw Exception('No file data available');
// //       }

// //       Response response = await dio.post(
// //         'https://your-api-endpoint.com/upload',
// //         data: formData,
// //         options: Options(
// //           headers: {
// //             'Content-Type': 'multipart/form-data',
// //             // Add authorization if needed
// //             // 'Authorization': 'Bearer your-token',
// //           },
// //         ),
// //         onSendProgress: (sent, total) {
// //           setState(() {
// //             uploadProgress = sent / total;
// //           });
// //         },
// //       );

// //       if (response.statusCode == 200 || response.statusCode == 201) {
// //         _showSnackBar('File uploaded successfully!');
// //         setState(() {
// //           selectedFile = null;
// //         });
// //       } else {
// //         _showSnackBar('Upload failed: ${response.statusMessage}');
// //       }
// //     } catch (e


import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shafici_pos/constants/colors.dart';
import 'package:shafici_pos/constants/icons.dart';
import 'package:shafici_pos/constants/sizes.dart';
import 'package:shafici_pos/screens/products_screen/register_products_screen.dart';
import 'package:shafici_pos/ui/ui_animated_mini_message_widget.dart';
import 'package:shafici_pos/ui/ui_button_widget.dart';
import 'package:shafici_pos/ui/ui_text_field_widget.dart';
import 'package:shafici_pos/ui/ui_title_widget.dart';

class BulkProductsRegisterWidget extends StatefulWidget {
  final void Function(RegisterProductType type) onSingleClick;
  final void Function(PlatformFile file, String sheetName) onSubmit;
  final void Function() onBackClick;

  const BulkProductsRegisterWidget({
    super.key,
    required this.onSingleClick,
    required this.onSubmit,
    required this.onBackClick,
  });

  @override
  State<BulkProductsRegisterWidget> createState() => _BulkProductsRegisterWidgetState();
}

class _BulkProductsRegisterWidgetState extends State<BulkProductsRegisterWidget> {
  final TextEditingController _sheetNameController = TextEditingController();
  PlatformFile? _selectedFile;
  String? _fileStatus;
  final _formKey = GlobalKey<FormState>();

  
  
  // - - - - - - V A L I D A T O R S

  // -- -- --
  String? _validateSheetName(String? value) {
    if (value == null || value.isEmpty) return 'sheet name is missing';
    return null;
  }



  // - - - - - - F U N C T I O N S

  // -- -- --
  Future<void> _handlePickFile() async {
    if (_fileStatus != null) return;

    try {
      setState(() => _fileStatus = 'Picking file ...');

      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: [ 'xlsx', 'xls' ],
      );

      setState(() {
        _selectedFile = file;
        _fileStatus = file == null ? 'No file is selected' : 'File is uploaded';
      });
    } 
    catch (e) {
      setState(() => _fileStatus = 'Failed to upload file',);
      print('Error: $e');
    }
    finally {
      await Future.delayed(Duration(milliseconds: 1500));
      if (mounted) setState(() => _fileStatus = null,);
    }
  }

  // -- -- --
  Future<void> _handleSubmitClick() async {}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
        child: Padding(
          padding: EdgeInsetsGeometry.all(CSizes.largeGap),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              // 
              Center(
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: UiTitleWidget(
                                  text: 'register products',
                                  bigger: true,
                                  capitalizeWords: true,
                                ),
                              ),


                              UiButtonWidget(
                                text: 'single',
                                icon: CIcons.file2Icon,
                                vericalPadding: CSizes.smallGap,
                                onClick: () => widget.onSingleClick(RegisterProductType.single)
                              )
                            ],
                          ),
    
                          SizedBox(height: CSizes.xLargeGap,),

                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: UiTextFieldWidget(
                                  textController: _sheetNameController,
                                  label: 'sheet name',
                                  validator: (value) => _validateSheetName(value),
                                ),
                              ),
                          
                              // SizedBox(width: CSizes.mediumGap,),
                          
                              // UiButtonWidget(
                              //   icon: CIcons.file2Icon,
                              //   tranparent: true,
                              //   horizontalPadding: CSizes.mediumGap,
                              //   // vericalPadding: 0,
                              //   borderColor: CColors.primaryColor,
                              //   onClick: _handleDownloadClick
                              // ),
                            ],
                          ),

                          SizedBox(height: CSizes.largeGap,),

                          IntrinsicHeight(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: _handlePickFile,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: CColors.whiteShade1,
                                    borderRadius: BorderRadius.circular(CSizes.smallRadius + 20)
                                  ),
                                  padding: EdgeInsets.all(CSizes.xLargeGap),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                
                                      SvgPicture.asset(
                                        CIcons.file2Icon,
                                        colorFilter: ColorFilter.mode(_selectedFile == null ? CColors.red : CColors.green, BlendMode.srcIn),
                                        height: 48,
                                      ),
                                
                                      SizedBox(height: CSizes.xLargeGap,),
                              
                                      UiTitleWidget(
                                        text: _selectedFile?.name ?? 'no file is selected',
                                        bold: false,
                                        textAlign: TextAlign.center,
                                      )
                                
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          UiAnimatedMiniMessageWidget(
                            displayText: _fileStatus,
                            isNeutral: true,
                          ),

                          SizedBox(height: CSizes.xLargeGap,),

                          Row(
                            children: [
                              Expanded(
                                child: UiButtonWidget(
                                  text: 'back',
                                  tranparent: true,
                                  onClick: widget.onBackClick
                                ),
                              ),

                              SizedBox(width: CSizes.mediumGap,),

                              Expanded(
                                child: UiButtonWidget(
                                  icon: CIcons.sendIcon,
                                  text: 'submit',
                                  isDisabled: _selectedFile == null || _fileStatus != null,
                                  onClick: _handleSubmitClick,
                                )
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  )
                )
              )

            ]
          )
        )
      )
    );
  }
}