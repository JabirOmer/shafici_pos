class BulkRegisterMessageModel {
  final List<String> successfullImports;
  final List<String> dublicatedImports;
  final List<String> failedImports;

  BulkRegisterMessageModel({
    required this.successfullImports,
    required this.dublicatedImports,
    required this.failedImports,
  });

  factory BulkRegisterMessageModel.fromMap(Map<String, dynamic> data) {
    return BulkRegisterMessageModel(
      // successfullImports: data['successfull_imports'], 
      // dublicatedImports: data['dublicated_imports'], 
      successfullImports: List<String>.from(data['successfull_imports'] ?? []),
      dublicatedImports: List<String>.from(data['dublicated_imports'] ?? []),
      failedImports: List<String>.from(data['failed_imports'] ?? [])
    );
  }
}