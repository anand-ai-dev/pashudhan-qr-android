class AuthorizeRoleRequest {
  final String status;
  final String comments;
  final int requestId;

  AuthorizeRoleRequest({
    required this.status,
    required this.comments,
    required this.requestId,
  });

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'comments': comments,
      'requestId': requestId,
    };
  }
}
