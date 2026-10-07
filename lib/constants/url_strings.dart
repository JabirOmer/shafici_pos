class CUrlStrings {
  CUrlStrings._();

  
  static String baseUrl = 'http://localhost:4040';
  // static String baseUrl = 'https://mizanserver.saqrinnovations.com';
  // static String baseUrl = 'https://wasl-pos-server-7alsz.ondigitalocean.app';
  // static String baseUrl = 'https://wasl-server-snvsj.ondigitalocean.app';


  // - - - Device
  static String checkTokenStatusUrl = '$baseUrl/devices/check-status';
  static String verifyVerificationCode = '$baseUrl/devices/verify';
  static String deviceRevokeUrl = '$baseUrl/devices/revoke';


  // - - - Users
  static String loginUrl = '$baseUrl/users/pos-login';
  static String getUsersUrl = '$baseUrl/users';
  static String registerUserUrl = '$baseUrl/users/register';
  static String updateUserDataUrl = '$baseUrl/users/update';
  static String updatePasswordUrl = '$baseUrl/users/change-password';
  static String deleteUserUrl = '$baseUrl/users/delete';


  // - - - Products
  static String getProductsUrl = '$baseUrl/products/by-branch';
  static String registerProductUrl = '$baseUrl/products/register';
  static String registerBulkProductsUrl = '$baseUrl/products/register-bulk';
  static String updateProductUrl = '$baseUrl/products/update';
  static String updateExchangeRateUrl = '$baseUrl/products/update-exchange';
  static String deleteProductUrl = '$baseUrl/products/delete/disable';
  static String setNewBarcodeUrl = '$baseUrl/products/custom-barcode';


  // - - - Categories
  static String getCategoriesUrl = '$baseUrl/product-categories';
  static String registerCategoryUrl = '$baseUrl/product-categories/register';
  static String updateCategoryUrl = '$baseUrl/product-categories/update';
  static String deleteCategoryUrl = '$baseUrl/product-categories/delete';


  // - - - Payments
  static String getPaymentMethodsUrl = '$baseUrl/payment-methods';
  static String registerPaymentUrl = '$baseUrl/payment-methods/register';
  static String updatePaymentMethodUrl = '$baseUrl/payment-methods/update';
  static String deletePaymentMethodUrl = '$baseUrl/payment-methods/delete';

  
  // - - - Sales / Order
  static String sendOrderUrl = '$baseUrl/sales/register';
  static String getSalesUrl = '$baseUrl/sales/history';


  // - - - C U S T O M E R S
  static String getCustomers = '$baseUrl/customers';
  static String registerCustomer = '$baseUrl/customers/register';

  // - - - C R E D I T S
  static String getBranchCredits = '$baseUrl/credits/by-branch/'; // add branch id as a params

  // - - - C R E D I T S _ R E C O R D S
  static String registerCreditRecord = '$baseUrl/credits/register-record'; // add branch id as a params
}