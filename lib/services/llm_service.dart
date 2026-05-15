import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LLMService {
  static const String _apiKeyKey = 'deepseek_api_key';
  static const String _baseUrl = 'https://api.deepseek.com/v1/chat/completions';

  // 保存 API Key
  static Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiKeyKey, apiKey);
  }

  // 获取 API Key
  static Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiKeyKey);
  }

  // 检查是否已配置 API Key
  static Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  // 调用 DeepSeek API 生成文档
  static Future<String> generateDocument(List<Map<String, String>> qaPairs) async {
    final apiKey = await getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('请先配置 DeepSeek API Key');
    }

    // 构建 prompt
    final buffer = StringBuffer();
    buffer.writeln('请根据以下问答对生成一份专业的 AI 效能分析报告（Markdown 格式）：\n');
    
    for (var i = 0; i < qaPairs.length; i++) {
      buffer.writeln('## 问答对 ${i + 1}\n');
      buffer.writeln('**问题：**\n${qaPairs[i]['question']}\n');
      buffer.writeln('**回答：**\n${qaPairs[i]['answer']}\n');
      buffer.writeln('---\n');
    }

    buffer.writeln('\n请生成一份包含以下内容的报告：');
    buffer.writeln('1. 总体概述');
    buffer.writeln('2. 每个问题的详细分析');
    buffer.writeln('3. 关键发现和建议');
    buffer.writeln('4. 总结');

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': '你是一个专业的技术文档撰写助手，擅长分析 AI 对话记录并生成结构化的效能分析报告。'
            },
            {
              'role': 'user',
              'content': buffer.toString(),
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        final errorData = jsonDecode(utf8.decode(response.bodyBytes));
        throw Exception('API 调用失败: ${response.statusCode}\n${errorData['error']?['message'] ?? response.body}');
      }
    } catch (e) {
      throw Exception('生成文档失败: $e');
    }
  }
}
