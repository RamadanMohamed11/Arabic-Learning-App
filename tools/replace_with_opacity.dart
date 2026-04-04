import 'dart:io';

void main() {
  final directory = Directory('lib');
  int replacedCount = 0;
  
  if (!directory.existsSync()) {
    // ignore: avoid_print
    print('Usage: dart replace_with_opacity.dart <directory_path>');
    return;
  }

  final files = directory.listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    
    // We want to replace .withOpacity(x) with .withValues(alpha: x)
    // To handle nested parentheses, we won't use a simple regex. 
    // Instead we do a simple string matching loop.
    int idx = 0;
    bool modified = false;
    final buffer = StringBuffer();
    
    while (idx < content.length) {
      final opacityIdx = content.indexOf('.withOpacity(', idx);
      if (opacityIdx == -1) {
        buffer.write(content.substring(idx));
        break;
      }
      
      buffer.write(content.substring(idx, opacityIdx));
      buffer.write('.withValues(alpha: ');
      
      int parenCount = 1;
      int curr = opacityIdx + '.withOpacity('.length;
      int startArg = curr;
      
      while (curr < content.length && parenCount > 0) {
        if (content[curr] == '(') parenCount++;
        if (content[curr] == ')') parenCount--;
        curr++;
      }
      
      final arg = content.substring(startArg, curr - 1);
      buffer.write(arg);
      buffer.write(')');
      
      idx = curr;
      modified = true;
      replacedCount++;
    }
    
    if (modified) {
      file.writeAsStringSync(buffer.toString());
    }
  }
  
  // ignore: avoid_print
  print('Replaced $replacedCount instances of withOpacity');
}

