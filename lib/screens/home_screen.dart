import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/qa_pair.dart';
import 'qa_analysis_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedPath = r'C:\Users\Administrator\.claude\projects';
  List<String> directories = [];
  List<String> jsonlFiles = [];
  List<Map<String, dynamic>> userMessages = [];
  List<Map<String, dynamic>> allMessages = [];
  Set<String> selectedUuids = {};
  String? selectedDirectory;
  String? selectedFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadDirectories();
  }

  Future<void> loadDirectories() async {
    setState(() => isLoading = true);
    
    try {
      final directory = Directory(selectedPath);
      if (await directory.exists()) {
        final dirs = directory
            .listSync()
            .whereType<Directory>()
            .map((dir) => dir.path.split('\\').last)
            .toList();
        
        setState(() {
          directories = dirs;
          isLoading = false;
        });
      } else {
        setState(() {
          directories = [];
          isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('根目录不存在')),
          );
        }
      }
    } catch (e) {
      setState(() {
        directories = [];
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('读取失败: $e')),
        );
      }
    }
  }

  Future<void> loadFiles(String dirName) async {
    setState(() {
      isLoading = true;
      selectedDirectory = dirName;
      jsonlFiles = [];
      userMessages = [];
      allMessages = [];
      selectedUuids = {};
      selectedFile = null;
    });

    try {
      final directory = Directory('$selectedPath\\$dirName');
      if (await directory.exists()) {
        final files = directory
            .listSync()
            .whereType<File>()
            .where((file) => file.path.endsWith('.jsonl'))
            .map((file) => file.path.split('\\').last)
            .toList();
        
        setState(() {
          jsonlFiles = files;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        jsonlFiles = [];
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('读取文件失败: $e')),
        );
      }
    }
  }

  Future<void> selectDirectory() async {
    String? path = await FilePicker.platform.getDirectoryPath();
    if (path != null) {
      setState(() {
        selectedPath = path;
        selectedDirectory = null;
        jsonlFiles = [];
        userMessages = [];
      });
      loadDirectories();
    }
  }

  Future<void> parseJsonlFile(String fileName) async {
    setState(() {
      isLoading = true;
      selectedFile = fileName;
      userMessages = [];
      allMessages = [];
      selectedUuids = {};
    });

    try {
      final file = File('$selectedPath\\$selectedDirectory\\$fileName');
      final lines = await file.readAsLines();
      
      for (var line in lines) {
        if (line.trim().isEmpty) continue;
        
        try {
          final json = jsonDecode(line);
          allMessages.add(json);
          
          if (json['message'] != null) {
            final message = json['message'];
            
            if (message['role'] == 'user' && 
                message['content'] is List &&
                (message['content'] as List).isNotEmpty) {
              
              final content = message['content'] as List;
              if (content[0] is Map && content[0]['type'] == 'text') {
                userMessages.add(json);
              }
            }
          }
        } catch (e) {
          debugPrint('解析行失败: $e');
        }
      }
      
      setState(() => isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('找到 ${userMessages.length} 条用户消息')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('解析失败: $e')),
        );
      }
    }
  }

  void analyzeSelected() {
    if (selectedUuids.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个问题')),
      );
      return;
    }

    final qaPairs = <QAPair>[];
    
    for (var userMsg in userMessages) {
      final uuid = userMsg['uuid'];
      if (!selectedUuids.contains(uuid)) continue;
      
      final content = userMsg['message']['content'];
      String question = '';
      if (content is List) {
        question = content
            .where((c) => c['type'] == 'text')
            .map((c) => c['text'])
            .join('\n');
      } else if (content is String) {
        question = content;
      }
      
      final currentIndex = allMessages.indexWhere((msg) => msg['uuid'] == uuid);
      
      int nextUserIndex = allMessages.length;
      for (int i = currentIndex + 1; i < allMessages.length; i++) {
        final msg = allMessages[i];
        if (msg['message'] != null && 
            msg['message']['role'] == 'user' &&
            msg['message']['content'] is List) {
          final msgContent = msg['message']['content'] as List;
          if (msgContent.isNotEmpty && 
              msgContent[0] is Map && 
              msgContent[0]['type'] == 'text') {
            nextUserIndex = i;
            break;
          }
        }
      }
      
      final answerParts = <String>[];
      final relatedMessages = <Map<String, dynamic>>[];
      final chainUuids = <String>{uuid};
      
      bool foundNew = true;
      while (foundNew) {
        foundNew = false;
        for (int i = currentIndex + 1; i < nextUserIndex; i++) {
          final msg = allMessages[i];
          final msgUuid = msg['uuid'];
          final parentUuid = msg['parentUuid'];
          
          if (parentUuid != null && 
              chainUuids.contains(parentUuid) && 
              !chainUuids.contains(msgUuid)) {
            chainUuids.add(msgUuid);
            relatedMessages.add(msg);
            foundNew = true;
            
            if (msg['message'] != null && msg['message']['content'] != null) {
              final msgContent = msg['message']['content'];
              if (msgContent is List) {
                for (var item in msgContent) {
                  if (item['type'] == 'text' && item['text'] != null) {
                    answerParts.add('[文本] ${item['text']}');
                  } else if (item['type'] == 'thinking' && item['thinking'] != null) {
                    answerParts.add('[思考] ${item['thinking']}');
                  }
                }
              } else if (msgContent is String) {
                answerParts.add(msgContent);
              }
            }
          }
        }
      }
      
      final answer = answerParts.isEmpty ? '未找到回答' : answerParts.join('\n\n');
      
      qaPairs.add(QAPair(
        uuid: uuid,
        question: question,
        answer: answer,
        userJson: userMsg,
        assistantJson: relatedMessages.isNotEmpty ? relatedMessages.first : {},
      ));
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QAAnalysisScreen(qaPairs: qaPairs),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 效能数据读取'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: '设置',
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部工具栏
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey.shade100,
            child: Row(
              children: [
                const Text('根目录: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Text(
                    selectedPath,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: selectDirectory,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('选择'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: loadDirectories,
                  icon: const Icon(Icons.refresh),
                  tooltip: '刷新',
                ),
              ],
            ),
          ),
          // 三栏布局
          Expanded(
            child: Row(
              children: [
                // 左侧：目录树
                SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.blue.shade50,
                        child: const Row(
                          children: [
                            Icon(Icons.folder, size: 18),
                            SizedBox(width: 8),
                            Text(
                              '项目目录',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: directories.isEmpty
                            ? const Center(child: Text('无子目录'))
                            : ListView.builder(
                                itemCount: directories.length,
                                itemBuilder: (context, index) {
                                  final dirName = directories[index];
                                  final isSelected = dirName == selectedDirectory;
                                  return ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.folder,
                                      color: isSelected ? Colors.blue : Colors.grey,
                                    ),
                                    title: Text(
                                      dirName,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.blue : Colors.black,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onTap: () => loadFiles(dirName),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // 中间：JSONL 文件列表
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.green.shade50,
                        child: const Row(
                          children: [
                            Icon(Icons.description, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'JSONL 文件',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: jsonlFiles.isEmpty
                            ? const Center(child: Text('请选择项目目录'))
                            : ListView.builder(
                                itemCount: jsonlFiles.length,
                                itemBuilder: (context, index) {
                                  final fileName = jsonlFiles[index];
                                  final isSelected = fileName == selectedFile;
                                  return ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.insert_drive_file,
                                      color: isSelected ? Colors.green : Colors.grey,
                                      size: 20,
                                    ),
                                    title: Text(
                                      fileName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? Colors.green : Colors.black,
                                      ),
                                    ),
                                    selected: isSelected,
                                    onTap: () => parseJsonlFile(fileName),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // 右侧：用户消息列表
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.orange.shade50,
                        child: Row(
                          children: [
                            const Icon(Icons.chat, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '用户消息 (${userMessages.length})',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            if (userMessages.isNotEmpty)
                              ElevatedButton.icon(
                                onPressed: analyzeSelected,
                                icon: const Icon(Icons.analytics, size: 18),
                                label: Text('确认分析 (已选 ${selectedUuids.length})'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : userMessages.isEmpty
                                ? const Center(child: Text('请选择 JSONL 文件'))
                                : ListView.builder(
                                    padding: const EdgeInsets.all(8),
                                    itemCount: userMessages.length,
                                    itemBuilder: (context, index) {
                                      final message = userMessages[index];
                                      final uuid = message['uuid'];
                                      final content = message['message']['content'] as List;
                                      final textContent = content
                                          .where((c) => c['type'] == 'text')
                                          .map((c) => c['text'])
                                          .join('\n');
                                      
                                      return Card(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        child: CheckboxListTile(
                                          value: selectedUuids.contains(uuid),
                                          onChanged: (checked) {
                                            setState(() {
                                              if (checked == true) {
                                                selectedUuids.add(uuid);
                                              } else {
                                                selectedUuids.remove(uuid);
                                              }
                                            });
                                          },
                                          title: Text(
                                            '消息 ${index + 1}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          subtitle: Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(
                                              textContent.length > 100
                                                  ? '${textContent.substring(0, 100)}...'
                                                  : textContent,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          secondary: IconButton(
                                            icon: const Icon(Icons.info_outline, size: 20),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('完整内容'),
                                                  content: SizedBox(
                                                    width: 500,
                                                    child: SingleChildScrollView(
                                                      child: SelectableText(textContent),
                                                    ),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () => Navigator.pop(context),
                                                      child: const Text('关闭'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
