import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;

class FFmpegUtil {
  static String? _ffmpegPath;

  static String? get ffmpegPath => _ffmpegPath;

  static Future<void> initFFmpeg() async {
    // 获取应用程序运行目录
    final exePath = Platform.resolvedExecutable;
    final appDirectory = path.dirname(exePath);
    debugPrint('App Directory: $appDirectory');
    // FFmpeg 预期位置
    final ffmpegExe = path.join(appDirectory, 'ffmpeg', 'ffmpeg.exe');

    // 验证 FFmpeg 是否存在
    if (await File(ffmpegExe).exists()) {
      _ffmpegPath = ffmpegExe;
    } else {
      throw Exception('FFmpeg not found in application directory');
    }
  }

  static Future<void> convertAudio(String inputFilePath, String outputFilePath, String bitRate, String sampleRate,
      String channels, String codec) async {
    if (_ffmpegPath == null) {
      throw Exception('FFmpeg not initialized');
    }

    try {
      final result = await Process.run(_ffmpegPath!, [
        '-i',
        inputFilePath,
        '-b:a',
        bitRate,
        '-ar',
        sampleRate,
        '-ac',
        channels == 'Mono' ? '1' : '2',
        '-c:a',
        codec,
        outputFilePath,
      ]);

      if (result.exitCode != 0) {
        throw Exception('FFmpeg error: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error executing FFmpeg: $e');
    }
  }
}
