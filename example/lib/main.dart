import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aliyun_push/aliyun_push.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    PushManager.instance.init(appKey: '333444720', appSecret: 'd5d28fa571234b4fbb300d2f38d9e179');
    PushManager.instance.messageStream.listen((Message event) {
      print('监听到 ==== ${event.body}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('添加标签'),
              SizedBox(height: 30),
              CupertinoButton(
                child: Text('添加tag'),
                onPressed: () {
                  PushManager.instance.bindTag(tags: ['测试']);
                },
              ),
              SizedBox(height: 30),
              CupertinoButton(
                child: Text('删除tag'),
                onPressed: () {
                  PushManager.instance.unbindTag(tags: ['测试']);
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
