import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart') && !f.path.contains('app_theme.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    if (content.contains('AppColors.')) {
      content = content.replaceAll('AppColors.', 'context.colors.');
      // Naive const removal: if a line contains `context.colors.`, remove `const ` from that line.
      final lines = content.split('\n');
      for (int i = 0; i < lines.length; i++) {
        if (lines[i].contains('context.colors.') && lines[i].contains('const ')) {
          lines[i] = lines[i].replaceAll('const ', '');
        }
      }
      file.writeAsStringSync(lines.join('\n'));
    }
  }
}
