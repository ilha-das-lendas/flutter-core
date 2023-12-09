import 'package:http/http.dart' as http;

import 'request.dart';

class MultipartRequest extends Request {
  final Map<String, String>? fields;
  final List<http.MultipartFile>? files;

  MultipartRequest({
    required super.path,
    required super.verb,
    super.headers,
    this.fields,
    this.files,
  });
}
