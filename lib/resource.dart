class Resource<T> {
  final String? message;
  final Status status;
  final T? data;

  Resource({this.message, required this.status, this.data});

  Resource.success(this.data)
      : status = Status.success,
        message = null;

  Resource.error(
    this.message, {
    this.data,
  }) : status = Status.error;
}

enum Status { success, error }

extension StatusExtension on Status {
  bool isSuccessful() => this == Status.success;
}
