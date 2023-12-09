import 'package:flutter_core/datasources/remote/response/response_wrapper.dart';
import 'package:http/http.dart' as http;


abstract class Service {
  Future<ResponseWrapper<T>> get<T>(
    String path, {
    Map<String, String?>? query,
    Map<String, String>? headers,
  });

  Future<ResponseWrapper<T>> post<T>(
    String path, {
    Map<String, String>? query,
    dynamic body,
    Map<String, String>? headers,
  });

  Future<int> put(
    String path, {
    Map<String, String>? query,
    dynamic body,
    bool shouldAuthorize,
    Map<String, String>? headers,
  });

  Future<int> delete(
    String path, {
    Map<String, String>? query,
    Map<String, String>? headers,
  });

  Future<http.StreamedResponse> multipartRequest(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? fields,
    List<http.MultipartFile> files,
  });
}
