import 'dart:io';

import 'package:audio_transcoder/utils/ffmpeg_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
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
    return const MaterialApp(
      home: AudioTranscoderPage(),
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

  List<String> formats = ['mp3', 'wav', 'flac', 'aac', 'mp4', 'opus', 'mpeg', 'm4a', 'ogg', 'webm'];
  String selectedFormat = 'mp3';

  List<String> bitRates = ['16k', '64k', '128k', '192k', '256k', '320k'];
  String selectedBitRate = '16k';

  List<String> sampleRates = ['16000', '22050', '44100', '48000', '96000'];
  String selectedSampleRate = '16000';

  List<String> channels = ['Mono', 'Stereo'];
  String selectedChannels = 'Mono';

  void _selectInputFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        inputFilePath = result.files.single.path;
      });
    }
  }

  void _selectOutputFolder() async {
    String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      setState(() {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        outputFilePath = '$directory/output_$timestamp.$selectedFormat';
      });
    }
  }

  Future<void> _convertAudio() async {
    if (inputFilePath == null || outputFilePath == null) {
      showSnackBar('Please select input and output files');
      return;
    }

    if (FFmpegUtil.ffmpegPath == null) {
      showSnackBar('FFmpeg not properly initialized');

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

  Future<void> convertAudio(String inputFilePath, String outputFilePath) async {
    try {
      String codec = '';

      // 设置编码器
      switch (selectedFormat) {
        case 'mp3':
          codec = 'libmp3lame';
          break;
        case 'ogg':
          codec = 'libvorbis';
          break;
        case 'aac':
        case 'm4a':
        case 'mp4':
          codec = 'aac';
          break;
        case 'flac':
          codec = 'flac';
          break;
        case 'opus':
          codec = 'libopus';
          break;
        case 'webm':
          codec = 'libvorbis';
          break;
        default:
          codec = 'copy';
      }

      // 构建 FFmpeg 命令
      final result = await Process.run(FFmpegUtil.ffmpegPath!, [
        '-i',
        inputFilePath,
        '-b:a',
        selectedBitRate,
        '-ar',
        selectedSampleRate,
        '-ac',
        selectedChannels == 'Mono' ? '1' : '2',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('音频转换工具'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: isConverting ? null : _selectInputFile,
                  child: const Text('Select Input Audio File'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: isConverting ? null : _selectOutputFolder,
                  child: const Text('Select Output Folder'),
                ),
                const SizedBox(height: 20),

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
                const SizedBox(height: 10),

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
                const SizedBox(height: 10),

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
                const SizedBox(height: 10),

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
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isConverting ? null : _convertAudio,
                  child: Text(isConverting ? 'Converting...' : 'Convert Audio'),
                ),
                const SizedBox(height: 20),

                if (inputFilePath != null) Text('Selected Input File: ${path.basename(inputFilePath!)}'),
                if (outputFilePath != null) Text('Selected Output File: ${path.basename(outputFilePath!)}'),
                if (isConverting)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
