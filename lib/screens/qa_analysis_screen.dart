import 'package:flutter/material.dart';
import '../models/qa_pair.dart';
import '../services/llm_service.dart';

class QAAnalysisScreen extends StatefulWidget {
  final List<QAPair> qaPairs;

  const QAAnalysisScreen({super.key, required this.qaPairs});

  @override
  State<QAAnalysisScreen> createState() => _QAAnalysisScreenState();
}

class _QAAnalysisScreenState extends State<QAAnalysisScreen> {
  bool _isGenerating = false;

  Future<void> generateDocument() async {
    final selectedPairs = widget.qaPairs.where((qa) => qa.isSelected).toList();
    
    if (selectedPairs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个问答对')),
      );
      return;
    }

    // 检查是否配置了 API Key
    final hasKey = await LLMService.hasApiKey();
    if (!hasKey) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先在设置中配置 DeepSeek API Key')),
        );
      }
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // 准备问答对数据
      final qaPairData = selectedPairs.map((qa) => {
        'question': qa.question,
        'answer': qa.answer,
      }).toList();

      // 调用 LLM 生成文档
      final document = await LLMService.generateDocument(qaPairData);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('生成的 AI 效能分析报告'),
            content: SizedBox(
              width: 700,
              height: 500,
              child: SingleChildScrollView(
                child: SelectableText(document),
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('问答分析'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _isGenerating ? null : generateDocument,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating ? '生成中...' : '究极 Agent 赋能'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: widget.qaPairs.length,
        itemBuilder: (context, index) {
          final qa = widget.qaPairs[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                CheckboxListTile(
                  value: qa.isSelected,
                  onChanged: (value) {
                    setState(() => qa.isSelected = value ?? false);
                  },
                  title: Text(
                    '问答对 ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    qa.question.length > 100
                        ? '${qa.question.substring(0, 100)}...'
                        : qa.question,
                  ),
                ),
                ExpansionTile(
                  title: const Text('查看详情'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '问题:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(qa.question),
                          const Divider(height: 32),
                          const Text(
                            '回答:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(qa.answer),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
