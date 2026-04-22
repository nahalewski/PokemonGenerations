class AiAutomationActionResult {
  const AiAutomationActionResult({
    required this.success,
    required this.title,
    required this.summary,
    this.preview,
    this.savedPaths = const [],
    this.metadata = const {},
  });

  final bool success;
  final String title;
  final String summary;
  final String? preview;
  final List<String> savedPaths;
  final Map<String, dynamic> metadata;

  factory AiAutomationActionResult.fromJson(Map<String, dynamic> json) {
    return AiAutomationActionResult(
      success: json['success'] == true,
      title: json['title']?.toString() ?? 'Automation Result',
      summary: json['summary']?.toString() ?? '',
      preview: json['preview']?.toString(),
      savedPaths: (json['savedPaths'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      metadata:
          (json['metadata'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value),
          ) ??
          const {},
    );
  }
}
