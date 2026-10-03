class ExportResult {
  const ExportResult({
    required this.success,
    required this.message,
    this.filePath,
    this.recordCount = 0,
  });

  final bool success;
  final String message;
  final String? filePath;
  final int recordCount;
}
