import 'dart:io';
import 'dart:convert';

void main() {
  final libDir = Directory('lib');

  if (!libDir.existsSync()) {
    print('❌ lib/ directory not found.');
    exit(1);
  }

  final dependencyMap = <String, List<String>>{};

  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final path = entity.path.replaceAll('\\', '/');
      final content = entity.readAsLinesSync();

      final imports = <String>[];

      for (final line in content) {
        if (line.trim().startsWith('import')) {
          // ✅ This is the key fix:
          final match = RegExp("import\\s+['\"](.+)['\"]").firstMatch(line);
          final importPath = match?.group(1);

          if (importPath != null &&
              !importPath.startsWith('dart:') &&
              !importPath.startsWith('package:')) {
            imports.add(importPath);
          }
        }
      }

      dependencyMap[path] = imports;
    }
  }

  final outputFile = File('web/dependencies.json');
  outputFile.createSync(recursive: true);
  outputFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert(dependencyMap),
  );

  print('✅ Dependencies written to web/dependencies.json');
}
