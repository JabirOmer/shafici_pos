class RegisterProductMessageModel {
  // final String? errorMessage;
  final String successMessage;
  final int successfulImports;
  final List<ImportsModel> dublicatedImports;
  final List<ImportsModel> failedImports;

  RegisterProductMessageModel({
    // required this.errorMessage,
    required this.successMessage,
    required this.successfulImports,
    required this.dublicatedImports,
    required this.failedImports,
  });

  factory RegisterProductMessageModel.fromMap(Map<String, dynamic> message) {
    return RegisterProductMessageModel(
      successMessage: message['msg'], 
      successfulImports: message['summary']['successful_imports'], 
      dublicatedImports: (message['dublicated_imports'] as List<dynamic>).map((data) => ImportsModel.fromMap(data)).toList(),
      failedImports: (message['failed_imports'] as List<dynamic>).map((data) => ImportsModel.fromMap(data)).toList()
    );
  }
}


class ImportsModel {
  final String productName;
  final String? error;

  ImportsModel({
    required this.productName,
    this.error,
  });

  factory ImportsModel.fromMap(Map<String, dynamic> data) {
    return ImportsModel(
      productName: data['product_name'], 
      error: data['error']
    );
  }
}