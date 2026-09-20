import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:shafici_pos/constants/url_strings.dart';

class CApiServices {

  final _dio = Dio(
    BaseOptions(
      baseUrl: CUrlStrings.baseUrl,
      connectTimeout: Duration(seconds: 15),
      sendTimeout: Duration(seconds: 15),
      receiveTimeout: Duration(seconds: 15),
    )
  );





  // - - - G E T _ M E T H O D
  Future<Response> getRequest({required String url, String? authToken}) async {
    try {
      final response = await _dio.get(
        url, 
        options: Options(headers: authToken != null ? 
          {'authorization': 'Bearer $authToken'} : 
          {'Content-Type': 'application/json'} 
        )
      );
      debugPrint('$url: success');
      return response;
    } 
    on DioException catch (e) {
      if (kDebugMode) {
        print('\n$url: expected error');
        print('Error: ${e.response}');
      }

      final data = e.response?.data;
      late String message;
      
      if (data is Map && (data['msg'] != null)) {
        message = data['msg'].toString();
      } else {
        message = 'Request failed!';
      }

      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: e.response?.statusCode ?? 500,
        data: message
      );
    }
    catch (e) {
      debugPrint('$url: unexpected error');
      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 500,
        data: 'Unexcpected error! Please contact the developer'
      );
    }
  }





  // - - - P O S T
  Future<Response> postRequest({required String url, FormData? formData, required Map<String, dynamic> data, String? authToken}) async {
    try {
      final response = await _dio.post(
        url, 
        data: formData ?? data, 
        options: Options( headers: authToken != null ? 
          {'authorization': 'Bearer $authToken'} : 
          {'Content-Type': 'application/json'} 
        )
      );
      return response;
    } 
    on DioException catch (e) {
      if (kDebugMode) {
        print('\n$url: expected error');
        print('Error: $e');
      }
      
      final data = e.response?.data;
      late String message;
      if (data is Map && (data['msg'] != null)) {
        message = data['msg'].toString();
      } else {
        message = 'Request failed!';
      }

      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: e.response!.statusCode ?? 500,
        data: message
      );
    }
    catch (e) {
      debugPrint('$url: unexpected error');
      
      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 500,
        data: 'Unexcpected error! Please contact the developer'
      );
    }
  }





  // - - - P A T C H
  Future<Response> patchRequest({required String url, required Map<String, dynamic> data, String? authToken}) async {
    try {
      final response = await _dio.patch(
        url, 
        data: data, 
        options: Options( headers: authToken != null ? 
          {'authorization': 'Bearer $authToken'} : 
          {'Content-Type': 'application/json'} 
        )
      );
      return response;
    } 
    on DioException catch (e) {
      debugPrint('\n$url: expected error');

      final data = e.response?.data;
      late String message;
      if (data is Map && (data['msg'] != null)) {
        message = data['msg'].toString();
      } else {
        message = 'Request failed!';
      }

      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: e.response!.statusCode ?? 500,
        data: message
      );
    }
    catch (e) {
      debugPrint('$url: unexpected error');

      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 500,
        data: 'Unexcpected error! Please contact the developer'
      );
    }
  }





  // - - - D E L E T E
  Future<Response> deleteRequest({required String url, required Map<String, dynamic> data, String? authToken}) async {
    try {
      final response = await _dio.delete(
        url, 
        data: data, 
        options: Options( headers: authToken != null ? 
          {'authorization': 'Bearer $authToken'} : 
          {'Content-Type': 'application/json'} 
        )
      );
      return response;
    } 
    on DioException catch (e) {
      debugPrint('\n$url: expected error');

      final data = e.response?.data;
      late String message;
      if (data is Map && (data['msg'] != null)) {
        message = data['msg'].toString();
      } else {
        message = 'failed to resolve';
      }

      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: e.response!.statusCode ?? 500,
        data: message
      );
    }
    catch (e) {
      debugPrint('$url: unexpected error');

      return Response(
        requestOptions: RequestOptions(path: url),
        statusCode: 500,
        data: 'Unexcpected error! Please contact the developer'
      );
    }
  }
}