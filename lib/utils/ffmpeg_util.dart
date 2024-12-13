import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;

class FFmpegUtil {
  static String? _ffmpegPath;

  static String? get ffmpegPath => _ffmpegPath;

  static Future<void> initFFmpeg() async {
    // 获取应用程序运行目录
    final String exePath = Platform.resolvedExecutable;
    final String appDirectory = path.dirname(exePath);
    debugPrint('App Directory: $appDirectory');
    // Built build\windows\x64\runner\Release\audio_transcoder.exe
    // FFmpeg 预期位置
    final String ffmpegExe = path.join(appDirectory, 'ffmpeg', 'ffmpeg.exe');

    // 验证 FFmpeg 是否存在
    if (await File(ffmpegExe).exists()) {
      _ffmpegPath = ffmpegExe;
    } else {
      throw Exception('FFmpeg not found in application directory');
    }
  }

  static Future<void> convertAudio(String inputFilePath, String outputFilePath, String bitRate, String sampleRate,
      String channels, String format) async {
    if (_ffmpegPath == null) {
      throw Exception('FFmpeg not initialized');
    }

    try {
      final ProcessResult result = await Process.run(_ffmpegPath!, <String>[
        '-i',
        inputFilePath,
        '-b:a',
        bitRate,
        '-ar',
        sampleRate,
        '-ac',
        channels == 'Mono' ? '1' : '2',
        '-c:a',
        _getCodec(format),
        outputFilePath,
      ]);

      if (result.exitCode != 0) {
        throw Exception('FFmpeg error: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error executing FFmpeg: $e');
    }
  }

  /// 获取编码器
  static String _getCodec(String format) {
    switch (format) {
      case 'mp3':
      case 'mpeg':
        return 'libmp3lame';
      case 'ogg':
      case 'webm':
        return 'libvorbis';
      case 'aac':
      case 'm4a':
      case 'mp4':
        return 'aac';
      case 'flac':
        return 'flac';
      case 'opus':
        return 'libopus';
      default:
        return 'copy';
    }
  }
}
