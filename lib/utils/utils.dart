import 'dart:io';

import 'package:flutter/cupertino.dart';

class AudioUtils {
  static Future<void> convertAudio(String inputFilePath, String outputFilePath) async {
    // FFmpeg 转码命令，假设输入是 WAV，输出是 MP3
    final ProcessResult result = await Process.run(
      'ffmpeg',
      <String>['-i', inputFilePath, outputFilePath],
    );

    if (result.exitCode == 0) {
      debugPrint('Audio converted successfully!');
    } else {
      debugPrint('Error during conversion: ${result.stderr}');
    }
  }
}
