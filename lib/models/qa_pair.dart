class QAPair {
  final String uuid;
  final String question;
  final String answer;
  final Map<String, dynamic> userJson;
  final Map<String, dynamic> assistantJson;
  bool isSelected;

  QAPair({
    required this.uuid,
    required this.question,
    required this.answer,
    required this.userJson,
    required this.assistantJson,
    this.isSelected = false,
  });
}
