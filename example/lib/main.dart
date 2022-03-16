import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:easy_app_installer/easy_app_installer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  String _cancelTag = "";

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await EasyAppInstaller.instance.platformVersion ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildButton('下载并安装apk', () {
                downloadAndInstalApk();
              }),
              _buildButton('取消下载任务', () {
                if (_cancelTag.isNotEmpty) {
                  EasyLoading.dismiss();
                  EasyAppInstaller.instance.cancelDownload(_cancelTag);
                } else {
                  EasyLoading.showError("没有下载中的任务");
                }
              }),
              _buildButton('打开应用市场', () {
                EasyAppInstaller.instance.openAppMarket();
              }),
            ],
          ),
        ),
      ),
    );
  }

  void downloadAndInstalApk() {
    EasyLoading.show(status: "准备下载");
    EasyAppInstaller.instance.downloadAndInstallApp(
        fileUrl:
            "https://hipos.oss-cn-shanghai.aliyuncs.com/hipos-kds-v.5.10.031-g.apk",
        fileDirectory: "updateApk",
        fileName: "newApk.apk",
        downloadListener: (progress) {
          if (progress < 100) {
            EasyLoading.showProgress(progress / 100, status: "下载中");
          } else {
            EasyLoading.showSuccess("下载成功");
          }
        },
        cancelTagListener: (cancelTag) {
          _cancelTag = cancelTag;
        });
  }

  Widget _buildButton(String text, Function function) {
    return MaterialButton(
      color: Colors.blue,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      onPressed: () {
        function();
      },
    );
  }

  @override
  void dispose() {
    EasyAppInstaller.instance.dispose();
    super.dispose();
  }
}