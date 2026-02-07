class NotificationModel {
  String? responseCode;
  String? message;
  List<NotificationContentModel>? content;
  NotificationModel(this.responseCode, this.message, this.content);
  NotificationModel convertToModel(Map<String, dynamic> data) {
    return NotificationModel(
        data['response_code'],
        data['message'],
        (data['content'] as List)
            .map((e) => NotificationContentModel.convertToModel(e))
            .toList());
  }
}
class NotificationContentModel {

  String? id;
  String? userId;
  String? user_type;
  String? title;
  String? body;
  String? module;
  String? created_at;
  NotificationContentModel(this.id, this.userId, this.user_type, this.title,
      this.body, this.module, this.created_at);
  static NotificationContentModel convertToModel(Map<String, dynamic> data) {
    return NotificationContentModel(
      data['id'],
      data['user_id'],
      data['user_type'],
      data['title'],
      data['body'],
      data['module'],
      data['created_at'],
    );
  }
}