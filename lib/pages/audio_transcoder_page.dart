import 'dart:io';

import 'package:audio_transcoder/constants/audio_const.dart';
import 'package:audio_transcoder/utils/ffmpeg_util.dart';
import 'package:audio_transcoder/widgets/custom_elevated_button.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

class AudioTranscoderPage extends StatefulWidget {
  const AudioTranscoderPage({super.key});

  @override
  State<AudioTranscoderPage> createState() => _AudioTranscoderPageState();
}

class _AudioTranscoderPageState extends State<AudioTranscoderPage> {
  String? inputFilePath;
  String? outputFilePath;
  bool isConverting = false;

  String selectedFormat = AudioConst.formats.first;

  String selectedBitRate = AudioConst.bitRates[2];

  String selectedSampleRate = AudioConst.sampleRates[2];

  String selectedChannels = AudioConst.channels.last;

  // 存储已转换的文件信息
  final List<Map<String, dynamic>> convertedFiles = <Map<String, dynamic>>[];
  final Set<int> selectedIndices = <int>{};

  /// 选择输入音频文件
  void _selectInputFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      setState(() {
        inputFilePath = result.files.single.path;
      });
    }
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectedIndices.length == convertedFiles.length) {
        selectedIndices.clear();
      } else {
        selectedIndices.clear();
        for (int i = 0; i < convertedFiles.length; i++) {
          selectedIndices.add(i);
        }
      }
    });
  }

  Future<void> _downloadSelectedFiles() async {
    if (selectedIndices.isEmpty) {
      showSnackBar('请先选择要下载的文件');
      return;
    }

    final String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      for (int index in selectedIndices) {
        final String tempFilePath = convertedFiles[index]['path'];
        final String fileName = path.basename(tempFilePath);
        final File sourceFile = File(tempFilePath);

        if (await sourceFile.exists()) {
          await sourceFile.copy('$directory/$fileName');
          await sourceFile.delete();
        }
      }

      showSnackBar('选中文件已保存到 $directory');
      setState(() {
        // 移除已下载的文件
        selectedIndices.clear();
        convertedFiles.removeWhere((Map<String, dynamic> file) => !File(file['path']).existsSync());
      });
    }
  }

  /// 执行音频转换
  Future<void> _convertAudio() async {
    if (inputFilePath == null) {
      showSnackBar('请选择输入文件');
      return;
    }

    if (FFmpegUtil.ffmpegPath == null) {
      showSnackBar('FFmpeg未正确初始化');
      return;
    }

    setState(() => isConverting = true);
    try {
      final String tempOutputFilePath = await _generateTempOutputPath(); // 获取临时路径

      // 调用转换函数
      await convertAudio(inputFilePath!, tempOutputFilePath);

      // 在转换完成后，保存临时输出路径，待下载时使用
      setState(() {
        outputFilePath = tempOutputFilePath;
      });

      showSnackBar('音频转换完成！');
      _addConvertedFile(tempOutputFilePath);
    } catch (e) {
      showSnackBar('转换时出错：$e');
    } finally {
      setState(() => isConverting = false);
    }
  }

  Future<String> _generateTempOutputPath() async {
    // 获取临时目录
    final Directory tempDir = Directory.systemTemp;
    final String timestamp = DateFormat('yyyyMMdd').format(DateTime.now());
    final String millisecondsTimestamp = DateTime.now().millisecondsSinceEpoch.toString();
    return path.join(tempDir.path, 'output_${timestamp}_$millisecondsTimestamp.${selectedFormat.toLowerCase()}');
  }

  /// 添加转换后的文件到列表
  void _addConvertedFile(String filePath) {
    final File file = File(filePath);
    if (file.existsSync()) {
      setState(() {
        convertedFiles.add(<String, dynamic>{
          'path': filePath,
          'name': path.basename(filePath),
          'size': _formatFileSize(file.lengthSync()),
        });
      });
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    const List<String> units = <String>['B', 'KB', 'MB', 'GB'];
    int unitIndex = 0;
    double size = bytes.toDouble();
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }

  /// 显示提示信息
  void showSnackBar(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  /// 使用 FFmpeg 转换音频
  Future<void> convertAudio(String inputFilePath, String outputFilePath) async {
    await FFmpegUtil.convertAudio(
      inputFilePath,
      outputFilePath,
      selectedBitRate,
      selectedSampleRate,
      selectedChannels,
      selectedFormat,
    );
  }

  /// 下载文件
  Future<void> _downloadFile(String tempFilePath) async {
    // 用户选择保存路径
    final String? directory = await FilePicker.platform.getDirectoryPath();
    if (directory != null) {
      // 构造目标文件路径
      final String fileName = path.basename(tempFilePath);
      final File sourceFile = File(tempFilePath);

      // 检查源文件是否存在
      if (await sourceFile.exists()) {
        final File destinationFile = File('$directory/$fileName');

        // 复制文件
        await sourceFile.copy(destinationFile.path);
        // 删除临时文件
        await sourceFile.delete();
        showSnackBar('文件已保存到 $directory');
      } else {
        showSnackBar('临时文件已删除，无法下载');
      }
    }
  }

  /// 删除文件
  void _deleteFile(int index) {
    setState(() {
      convertedFiles.removeAt(index);
    });
  }

  @override
  void dispose() {
    // 在页面销毁时删除临时文件
    if (outputFilePath != null) {
      final File tempFile = File(outputFilePath!);
      if (tempFile.existsSync()) {
        tempFile.delete();
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Container(
          alignment: Alignment.center,
          child: const Text(
            '音频转换工具',
            style: TextStyle(fontSize: 30),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomElevatedButton(
                borderRadius: const BorderRadius.all(Radius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                text: '选择输入音频文件',
                onPressed: isConverting
                    ? null
                    : () {
                        _selectInputFile();
                      },
                backgroundColor: const Color(0xFF1B1B1B),
                textColor: Colors.white,
                isDisabled: isConverting,
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildDropdown('输出格式:', selectedFormat, AudioConst.formats, (String? val) {
                  setState(() {
                    selectedFormat = val!;
                    if (outputFilePath != null) {
                      outputFilePath = outputFilePath!.replaceAll(RegExp(r'\.\w+$'), '.$selectedFormat');
                    }
                  });
                }),
                _buildDropdown(
                  '比特率:',
                  selectedBitRate,
                  AudioConst.bitRates,
                  (String? val) => setState(() => selectedBitRate = val!),
                ),
                _buildDropdown(
                  '采样率:',
                  selectedSampleRate,
                  AudioConst.sampleRates,
                  (String? val) => setState(() => selectedSampleRate = val!),
                ),
                _buildDropdown(
                  '声道:',
                  selectedChannels,
                  AudioConst.channels,
                  (String? val) => setState(() => selectedChannels = val!),
                ),
                CustomElevatedButton(
                  text: isConverting ? '正在转换...' : '转换音频',
                  onPressed: isConverting
                      ? null
                      : () {
                          _convertAudio();
                        },
                  backgroundColor: const Color(0xFF149753),
                  // 按钮背景色
                  textColor: Colors.white,
                  // 按钮文本颜色
                  isDisabled: isConverting, // 是否禁用按钮
                ),
              ],
            ),
            if (convertedFiles.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // 全选/取消全选按钮
                  InkWell(
                    onTap: _toggleSelectAll,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        SizedBox(width: 4),
                        Icon(Icons.select_all, size: 24),
                        SizedBox(width: 4),
                        Text('全选/取消', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                  // 批量下载按钮
                  InkWell(
                    onTap: _downloadSelectedFiles,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.download, size: 24),
                        SizedBox(width: 4),
                        Text('批量下载', style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            const Divider(),
            ListView.builder(
              shrinkWrap: true,
              itemCount: convertedFiles.length,
              itemBuilder: (BuildContext context, int index) {
                final Map<String, dynamic> file = convertedFiles[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Transform.scale(
                    scale: .8,
                    child: Checkbox(
                      value: selectedIndices.contains(index),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedIndices.add(index);
                          } else {
                            selectedIndices.remove(index);
                          }
                        });
                      },
                    ),
                  ),
                  title: Text('${file['name']} (${file['size']})'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () => _downloadFile(file['path']), // 点击下载按钮时下载文件
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteFile(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 构建通用下拉选择控件
  Widget _buildDropdown(String label, String selectedValue, List<String> options, void Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10),
      child: Row(
        children: <Widget>[
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: selectedValue,
            underline: const SizedBox(),
            onChanged: isConverting ? null : onChanged,
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value.toUpperCase(),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
