class ApiExceptionService implements Exception {
  final int statusCode;
  final String message;

  ApiExceptionService(this.statusCode, this.message);

  @override
  String toString() => message;
}
