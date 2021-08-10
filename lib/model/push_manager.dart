import 'dart:async';

import 'package:aliyun_push/model/message.dart';
import 'package:flutter/services.dart';

class PushManager {
  PushManager._() {
    _channel.setMethodCallHandler((MethodCall call) async {
      switch (call.method) {
        case 'onReceived':
          Message message = Message.fromJson(call.arguments as Map<String, dynamic>);
          _controller.add(message);
          break;
        case 'onDeviceId':
          String deviceId = call.arguments as String;
          print('deviceId === $deviceId');
          break;
        case 'onCCPMessage':
          CCPSysMessage message = CCPSysMessage.fromJson(call.arguments as Map<String, dynamic>);
          _ccpController.add(message);
          break;
        default:
      }
    });
  }

  static PushManager? _instance;
  static PushManager get instance => _instance ??= PushManager._();

  static const MethodChannel _channel = const MethodChannel('aliyun_push');

  final StreamController<Message> _controller = StreamController<Message>();
  final StreamController<CCPSysMessage> _ccpController = StreamController<CCPSysMessage>();

  Stream<Message> get messageStream => _controller.stream;
  Stream<CCPSysMessage> get ccpMessageStream => _ccpController.stream;

  Future<void> init({
    required String appKey,
    required String appSecret,
  }) async {
    return _channel.invokeMethod('init', <String, String>{
      'appKey': appKey,
      'appSecret': appSecret,
    });
  }

  Future<void> bindTag({
    required List<String> tags,
    int type = 1,
    String? alias,
  }) async {
    assert(tags.isNotEmpty);
    return _channel.invokeMethod('bindTag', <String, dynamic>{
      'type': type,
      'tags': tags,
      'alias': alias,
    });
  }

  Future<void> unbindTag({
    required List<String> tags,
    int type = 1,
    String? alias,
  }) async {
    assert(tags.isNotEmpty);
    return _channel.invokeMethod('unbindTag', <String, dynamic>{
      'type': type,
      'tags': tags,
      'alias': alias,
    });
  }
}
