class DeviceModel {
  final String deviceId;
  final String businessId;
  final String businessName;
  final String businessType;
  final String branchId;
  final String branchName;



  DeviceModel({
    required this.deviceId,
    
    required this.businessId,
    required this.businessName,
    required this.businessType,
    
    required this.branchId,
    required this.branchName,
  });



  factory DeviceModel.fromMap(Map<String, dynamic> data) {
    return DeviceModel(
      deviceId: data['device_id'], 
      
      businessId: data['business_id'],
      businessName: data['business_name'],
      businessType: data['business_type'],
      
      branchId: data['branch_id'],
      branchName: data['branch_name'],
    );
  }
}