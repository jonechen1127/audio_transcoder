import 'dart:io';

import 'package:audio_transcoder/routes/app_routes.dart';
import 'package:audio_transcoder/utils/ffmpeg_util.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  void initSettings() {
    // 设置窗口大小
    if (Platform.isWindows) {
      WindowManager.instance.setSize(const Size(800, 600)); // 设置初始窗口大小
      WindowManager.instance.setMinimumSize(const Size(800 / 1.2, 600 / 1.2)); // 设置最小窗口大小
      // 可选：设置窗口是否可调整大小
      WindowManager.instance.setResizable(true);
      WindowManager.instance.setIcon('assets/icons/app-icon.ico');
      WindowManager.instance.setTitle('音频转换工具');
    }
  }

  WidgetsFlutterBinding.ensureInitialized();
  await WindowManager.instance.ensureInitialized();
  await FFmpegUtil.initFFmpeg();
  initSettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      builder: (BuildContext context, Widget? child) {
        // 在这里可以添加全局错误处理、加载指示器等
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
