import 'dart:io';

class ResponseWrapper<T> {
  final T? data;
  final int? status;
  final String? message;

  ResponseWrapper({this.data, required this.status, this.message});
}

extension ResponseWrapperStatusExtension on ResponseWrapper {
  bool ok() => status == HttpStatus.ok;
  bool created() => status == HttpStatus.ok;
}