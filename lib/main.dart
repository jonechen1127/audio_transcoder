import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Transcoder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AudioTranscoderPage(),
    );
  }
}

class AudioTranscoderPage extends StatefulWidget {
  const AudioTranscoderPage({super.key});

  @override
  State<AudioTranscoderPage> createState() => _AudioTranscoderPageState();
}

class _AudioTranscoderPageState extends State<AudioTranscoderPage> {
  String? inputFilePath;
  String? outputFilePath;
  bool isConverting = false;

  // 音频格式选项，扩展至所有所需格式
  List<String> formats = ['mp3', 'wav', 'flac', 'aac', 'mp4', 'opus', 'mpeg', 'm4a', 'ogg', 'webm'];
  String selectedFormat = 'mp3';

  // 比特率选项
  List<String> bitRates = ['16k', '64k', '128k', '192k', '256k', '320k'];
  String selectedBitRate = '16k';

  // 采样率选项
  List<String> sampleRates = ['16000', '22050', '44100', '48000', '96000'];
  String selectedSampleRate = '16000';

  // 声道选项
  List<String> channels = ['Mono', 'Stereo'];
  String selectedChannels = 'Mono';

  // 选择输入文件
  void _selectInputFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        inputFilePath = result.files.single.path;
      });
    } else {
      debugPrint('User canceled the file picker');
    }
  }

  // 选择输出文件夹
  void _selectOutputFolder() async {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      setState(() {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        outputFilePath = '$directory/output_$timestamp.$selectedFormat'; // 使用选中的格式
      });
    } else {
      debugPrint('User canceled the folder picker');
    }
  }

  // 转换音频
  Future<void> _convertAudio() async {
    if (inputFilePath == null || outputFilePath == null) {
      debugPrint('Please select input and output files.');
      return;
    }

    setState(() {
      isConverting = true;
    });

    try {
      await convertAudio(inputFilePath!, outputFilePath!);

      showSnackBar('Audio conversion completed successfully!');
    } catch (e) {
      showSnackBar('Error during conversion: $e');
    } finally {
      setState(() {
        isConverting = false;
      });
    }
  }

  void showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  // 调用本地安装的 FFmpeg 执行转换
  Future<void> convertAudio(String inputFilePath, String outputFilePath) async {
    try {
      // 设置默认编码器
      String codec = '';

      if (selectedFormat == 'mp3') {
        codec = 'libmp3lame'; // 使用 MP3 编码器
      } else if (selectedFormat == 'ogg') {
        codec = 'libvorbis'; // 使用 Vorbis 编码器
      } else if (selectedFormat == 'aac') {
        codec = 'aac'; // AAC 编码器
      } else if (selectedFormat == 'flac') {
        codec = 'flac'; // FLAC 编码器
      } else if (selectedFormat == 'm4a') {
        codec = 'aac'; // 使用 AAC 编码器为 m4a
      } else if (selectedFormat == 'opus') {
        codec = 'libopus'; // Opus 编码器
      } else if (selectedFormat == 'mp4') {
        codec = 'aac'; // MP4 使用 AAC 编码
      } else if (selectedFormat == 'webm') {
        codec = 'libvorbis'; // WebM 使用 Vorbis 编码
      }

      // 构建 FFmpeg 命令
      final result = await Process.run('ffmpeg', [
        '-i', inputFilePath, // 输入文件
        '-b:a', selectedBitRate, // 比特率
        '-ar', selectedSampleRate, // 采样率
        '-ac', selectedChannels == 'Mono' ? '1' : '2', // 声道数
        '-c:a', codec, // 设置音频编码器
        outputFilePath, // 输出文件路径
      ]);

      if (result.exitCode == 0) {
        debugPrint('Conversion successful: $outputFilePath');
      } else {
        throw Exception('FFmpeg error: ${result.stderr}');
      }
    } catch (e) {
      throw Exception('Error executing FFmpeg: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Transcoder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: isConverting ? null : _selectInputFile,
              child: const Text('Select Input Audio File'),
            ),
            ElevatedButton(
              onPressed: isConverting ? null : _selectOutputFolder,
              child: const Text('Select Output Folder'),
            ),
            // 输出格式选择
            DropdownButton<String>(
              value: selectedFormat,
              onChanged: isConverting
                  ? null
                  : (String? newValue) {
                      setState(() {
                        selectedFormat = newValue!;
                        outputFilePath = outputFilePath?.replaceAll(RegExp(r'\.\w+$'), '.$selectedFormat');
                      });
                    },
              items: formats.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value.toUpperCase()),
                );
              }).toList(),
            ),
            // 比特率选择
            DropdownButton<String>(
              value: selectedBitRate,
              onChanged: isConverting
                  ? null
                  : (String? newValue) {
                      setState(() {
                        selectedBitRate = newValue!;
                      });
                    },
              items: bitRates.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // 采样率选择
            DropdownButton<String>(
              value: selectedSampleRate,
              onChanged: isConverting
                  ? null
                  : (String? newValue) {
                      setState(() {
                        selectedSampleRate = newValue!;
                      });
                    },
              items: sampleRates.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // 声道选择
            DropdownButton<String>(
              value: selectedChannels,
              onChanged: isConverting
                  ? null
                  : (String? newValue) {
                      setState(() {
                        selectedChannels = newValue!;
                      });
                    },
              items: channels.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: isConverting ? null : _convertAudio,
              child: Text(isConverting ? 'Converting...' : 'Convert Audio'),
            ),
            if (inputFilePath != null) ...[
              Text('Selected Input File: $inputFilePath'),
            ],
            if (outputFilePath != null) ...[
              Text('Selected Output File: $outputFilePath'),
            ],
            if (isConverting) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
