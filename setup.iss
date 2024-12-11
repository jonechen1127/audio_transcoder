#define IconPath "assets\icons\app-icon.ico"  ; 定义图标文件相对路径

[Setup]
AppName=Audio Transcoder
AppVersion=1.0
DefaultDirName={commonpf}\Audio Transcoder
DefaultGroupName=Audio Transcoder
OutputDir=output
OutputBaseFilename=AudioTranscoder_Setup
SetupIconFile=D:\project\audio_transcoder\assets\icons\app-icon.ico
AppPublisher=chenjun

[Files]
; 复制所有程序文件
Source: "D:\project\audio_transcoder\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs
; 复制 README 文件
Source: "D:\readme.txt"; DestDir: "{app}"; Flags: ignoreversion
; 复制图标文件
Source: "D:\project\audio_transcoder\assets\icons\app-icon.ico"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Audio Transcoder"; Filename: "{app}\audio_transcoder.exe"; IconFilename: "{app}\app-icon.ico"
Name: "{commondesktop}\Audio Transcoder"; Filename: "{app}\audio_transcoder.exe"; IconFilename: "{app}\app-icon.ico"
