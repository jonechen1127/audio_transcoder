import 'package:audio_transcoder/pages/another_page.dart';
import 'package:audio_transcoder/pages/audio_transcoder_page.dart';
import 'package:audio_transcoder/pages/home_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static final Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    '/': (_) => const HomePage(),
    '/audioTranscoder': (_) => const AudioTranscoderPage(),
    '/anotherPage': (_) => const AnotherPage(),
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // 处理未定义的路由
    return MaterialPageRoute<dynamic>(
      builder: (_) => const Scaffold(
        body: Center(
          child: Text('页面未找到'),
        ),
      ),
    );
  }

  // 路由跳转方法
  static Future<T?> navigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  // 替换路由方法
  static Future<T?> replaceTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed<T, void>(context, routeName, arguments: arguments);
  }

  // 清除路由栈并跳转
  static Future<T?> clearStackAndNavigateTo<T>(BuildContext context, String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil<T>(context, routeName, (Route<dynamic> route) => false,
        arguments: arguments);
  }
}
