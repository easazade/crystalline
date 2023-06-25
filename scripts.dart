import 'dart:io';

Future main(List<String> args) async {
  print('listing all .dart files in this mono-repo '
      'and counts the lines of code in each file');

  final directory = Directory('');

  int lineCount = 0;

  final files = directory
      .listSync(recursive: true)
      .map((systemFile) => File(systemFile.path))
      .where((item) =>
          (item.path.contains('lib') || item.path.contains('test')) &&
          item.path.endsWith('.dart'))
      .toList()
    ..sort((file1, file2) {
      final lines1 = file1.readAsLinesSync();
      final lines2 = file2.readAsLinesSync();

      return lines1.length.compareTo(lines2.length);
    });

  for (var file in files) {
    final lines = await file.readAsLinesSync();

    print('${file.path.split('/').last} = ${lines.length}');

    lineCount = lineCount + lines.length;
  }

  print('-------------------');
  print(lineCount);
}
