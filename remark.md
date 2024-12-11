# Remark
 
Inno Setup 是一个常用的 Windows 安装程序生成工具，可以帮助你打包应用为一个安装程序，支持多语言、安装路径选择等功能。
* 载并安装 Inno Setup： 下载 Inno Setup 安装包：(Inno Setup)[https://jrsoftware.org/isinfo.php]。
* 准备安装文件： 在执行打包操作前，确保 .exe 文件和其他相关资源（如配置文件、DLL 文件、图标等）已经准备好，并放置在一个文件夹中。
* 创建 Inno Setup 脚本： 打开 Inno Setup，创建一个新的脚本文件。
* 使用 `flutter build windows --release` 命令生成 Windows 应用程序
* 在工程目录`build\windows\x64\runner\Release`下创建 ffmpeg 目录，将ffmpeg.exe复制到此目录，
* 在 Inno Setup 脚本中添加代码，见脚本文件`setup.iss`
`
