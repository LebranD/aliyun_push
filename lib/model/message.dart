class Message {
  final String body;
  final int? badge;
  final String title;
  final bool? silent;

  Message({
    required this.body,
    this.badge = 0,
    required this.title,
    this.silent = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        body: json['body']!,
        badge: intValue(json['badge']),
        title: json['title'],
        silent: boolValue(json['silent']),
      );

  static bool? boolValue(dynamic json) {
    if (json is bool) {
      return json;
    }
    if (json is int) {
      return json == 1;
    }
    if (json is String) {
      return json == '1';
    }
    return null;
  }

  static int? intValue(dynamic json) {
    if (json is int) {
      return json;
    }
    if (json is num) {
      return json.toInt();
    }
    if (json is String) {
      return int.tryParse(json);
    }
    return null;
  }
}

class CCPSysMessage {
  final String title;
  final String body;

  CCPSysMessage(this.title, this.body);
  factory CCPSysMessage.fromJson(Map<String, dynamic> json) => CCPSysMessage(json['title'], json['body']);
}
