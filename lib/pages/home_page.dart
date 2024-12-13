import 'package:audio_transcoder/pages/another_page.dart';
import 'package:audio_transcoder/pages/audio_transcoder_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MainPageState();
}

class _MainPageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Navigator(
          initialRoute: '/',
          onGenerateRoute: (RouteSettings settings) {
            WidgetBuilder builder;
            switch (settings.name) {
              case '/':
                builder = (BuildContext context) => const AudioTranscoderPage();
                break;
              case '/anotherPage':
                builder = (BuildContext context) => const AnotherPage();
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return MaterialPageRoute<dynamic>(builder: builder, settings: settings);
          },
        ),
      ),
    );
  }
}
