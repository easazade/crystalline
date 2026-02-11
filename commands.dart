#!/usr/bin/env dart

import 'dart:io';

import 'package:args/args.dart';

void main(List<String> arguments) async {
  final bumpCommandParser = ArgParser()
    ..addOption(
      'type',
      abbr: 't',
      allowed: ['major', 'minor', 'patch'],
      help:
          'Version bump type: major, minor, or patch (optional - will prompt if not provided)',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final showCommandParser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final publishCommandParser = ArgParser()
    ..addFlag(
      'dry-run',
      abbr: 'd',
      negatable: false,
      help: 'Run in dry-run mode (passes --dry-run to dart pub publish)',
    )
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final tagCommandParser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  final parser = ArgParser()
    ..addCommand('bump', bumpCommandParser)
    ..addCommand('show', showCommandParser)
    ..addCommand('publish', publishCommandParser)
    ..addCommand('tag', tagCommandParser)
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Show this help message',
    );

  ArgResults results;
  try {
    results = parser.parse(arguments);
  } catch (e) {
    print('Error: ${e.toString()}');
    print('\nUsage: dart commands.dart <command> [options]');
    print('Commands:');
    print('  bump     Bump version for all packages');
    print('  show     Show versions for all packages');
    print('  publish  Publish packages to pub.dev');
    print('  tag      Tag the last commit with the latest unified version');
    print('\nRun "dart commands.dart <command> --help" for more information.');
    exit(1);
  }

  if (results['help'] == true) {
    print(parser.usage);
    print('\nCommands:');
    print('  bump     Bump version for all packages');
    print('  show     Show versions for all packages');
    print('  publish  Publish packages to pub.dev');
    print('  tag      Tag the last commit with the latest unified version');
    exit(0);
  }

  final command = results.command;
  if (command == null) {
    print('Usage: dart commands.dart <command> [options]\n');
    print('Commands:');
    print('  bump     Bump version for all packages');
    print('  show     Show versions for all packages');
    print('  publish  Publish packages to pub.dev');
    print('  tag      Tag the last commit with the latest unified version\n');
    print('Run "dart commands.dart <command> --help" for more information.');
    exit(1);
  }

  if (command['help'] == true) {
    if (command.name == 'bump') {
      print(bumpCommandParser.usage);
    } else if (command.name == 'show') {
      print(showCommandParser.usage);
    } else if (command.name == 'publish') {
      print(publishCommandParser.usage);
    } else if (command.name == 'tag') {
      print(tagCommandParser.usage);
    }
    exit(0);
  }

  if (command.name == 'bump') {
    String bumpType;
    final providedType = command['type'] as String?;
    if (providedType != null) {
      bumpType = providedType;
    } else {
      bumpType = await promptForBumpType();
    }
    await bumpVersions(bumpType);
  } else if (command.name == 'show') {
    await showVersions();
  } else if (command.name == 'publish') {
    final dryRun = command['dry-run'] == true;
    await publishPackages(dryRun);
  } else if (command.name == 'tag') {
    await tagLatestVersion();
  } else {
    print('Unknown command: ${command.name}');
    print('\nAvailable commands: bump, show, publish, tag');
    exit(1);
  }
}

Future<String> promptForBumpType() async {
  print('Select version bump type:');
  print('  1. major');
  print('  2. minor');
  print('  3. patch');
  print('\nEnter your choice (1-3):');

  final input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    print('No selection made. Exiting.');
    exit(0);
  }

  final choice = input.trim();
  switch (choice) {
    case '1':
      return 'major';
    case '2':
      return 'minor';
    case '3':
      return 'patch';
    default:
      // Try to parse as direct name
      final lowerChoice = choice.toLowerCase();
      if (lowerChoice == 'major' ||
          lowerChoice == 'minor' ||
          lowerChoice == 'patch') {
        return lowerChoice;
      }
      print('Invalid choice: $choice');
      print('Please enter 1, 2, 3, or major, minor, patch');
      exit(1);
  }
}

Future<void> showVersions() async {
  final packages = await getPackages();
  if (packages.isEmpty) {
    print('No packages found in packages directory');
    exit(0);
  }

  final packageVersions = <String, String>{};

  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('Warning: ${package.path}/pubspec.yaml not found, skipping');
      continue;
    }

    final content = await pubspecFile.readAsString();
    final version = extractVersion(content);
    if (version != 'unknown') {
      final packageName = package.path.split(Platform.pathSeparator).last;
      packageVersions[packageName] = version;
    }
  }

  if (packageVersions.isEmpty) {
    print('No valid versions found in packages');
    exit(0);
  }

  print('Package versions:');
  packageVersions.forEach((name, version) {
    print('  $name: $version');
  });
}

Future<void> bumpVersions(String bumpType) async {
  final packages = await getPackages();
  if (packages.isEmpty) {
    print('No packages found in packages directory');
    exit(0);
  }

  // First, collect all versions and find the highest one
  print('Collecting current versions...\n');
  final packageVersions = <String, String>{};
  Version? highestVersion;

  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      print('Warning: ${package.path}/pubspec.yaml not found, skipping');
      continue;
    }

    final content = await pubspecFile.readAsString();
    final version = extractVersion(content);
    if (version != 'unknown') {
      final packageName = package.path.split(Platform.pathSeparator).last;
      packageVersions[packageName] = version;

      final versionObj = parseVersion(version);
      if (versionObj != null) {
        if (highestVersion == null ||
            isVersionHigher(versionObj, highestVersion)) {
          highestVersion = versionObj;
        }
      }
    }
  }

  if (highestVersion == null) {
    print('Error: No valid versions found in packages');
    exit(1);
  }

  // Show current versions
  print('Current versions:');
  packageVersions.forEach((name, version) {
    print('  $name: $version');
  });
  print(
      '\nHighest version: ${highestVersion.major}.${highestVersion.minor}.${highestVersion.patch}');

  // Bump the highest version
  final bumpedVersion = bumpVersion(highestVersion, bumpType);
  final newVersionString =
      '${bumpedVersion.major}.${bumpedVersion.minor}.${bumpedVersion.patch}';

  print('Bumping $bumpType version to unified version: $newVersionString\n');

  // Get all local package names for dependency checking
  final localPackageNames = <String>{};
  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (await pubspecFile.exists()) {
      final content = await pubspecFile.readAsString();
      final packageName = extractPackageName(content);
      if (packageName != null) {
        localPackageNames.add(packageName);
      }
    }
  }

  // Update all packages to the unified version
  final updatedPackages = <Directory>[];
  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      continue;
    }

    final content = await pubspecFile.readAsString();
    final oldVersion = extractVersion(content);
    var updatedContent = setVersion(content, newVersionString);

    // Update local dependencies
    final dependencyUpdates = <String>[];
    updatedContent = updateLocalDependencies(
        updatedContent, localPackageNames, newVersionString, dependencyUpdates);

    if (updatedContent != content) {
      await pubspecFile.writeAsString(updatedContent);
      final packageName = package.path.split(Platform.pathSeparator).last;
      print('✓ $packageName: $oldVersion → $newVersionString');
      if (dependencyUpdates.isNotEmpty) {
        for (final depUpdate in dependencyUpdates) {
          print('  → Updated dependency: $depUpdate');
        }
      }
      updatedPackages.add(package);
    }
  }

  // Update CHANGELOG.md for all updated packages
  if (updatedPackages.isNotEmpty) {
    print('\nUpdating CHANGELOG.md files...');

    // Get previous version from first package's changelog
    String? previousVersion;
    List<String> allCommits = [];

    if (updatedPackages.isNotEmpty) {
      final firstPackage = updatedPackages.first;
      final changelogFile = File('${firstPackage.path}/CHANGELOG.md');
      if (await changelogFile.exists()) {
        final changelogContent = await changelogFile.readAsString();
        previousVersion = extractPreviousVersion(changelogContent);
      }

      // Get commits between previous version and HEAD
      if (previousVersion != null) {
        allCommits = await getCommitsBetweenVersions(previousVersion);
        if (allCommits.isNotEmpty) {
          print(
              'Found ${allCommits.length} commit(s) between v$previousVersion and HEAD');
        }
      }
    }

    for (final package in updatedPackages) {
      final packageName = package.path.split(Platform.pathSeparator).last;
      final wasUpdated =
          await updateChangelog(package, newVersionString, allCommits);
      if (wasUpdated) {
        print('✓ Updated CHANGELOG.md for $packageName');
      } else {
        print(
            '⊘ Skipped CHANGELOG.md for $packageName (entry for $newVersionString already exists)');
      }
    }
  }

  // Update README.md with new version
  await updateReadmeVersion(newVersionString);

  print(
      '\nVersion bump completed! All packages now at unified version: $newVersionString');
}

Future<void> tagLatestVersion() async {
  final packages = await getPackages();
  if (packages.isEmpty) {
    print('No packages found in packages directory');
    exit(0);
  }

  // Collect all versions and find the highest one
  print('Collecting current versions...\n');
  Version? highestVersion;

  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (!await pubspecFile.exists()) {
      continue;
    }

    final content = await pubspecFile.readAsString();
    final version = extractVersion(content);
    if (version != 'unknown') {
      final versionObj = parseVersion(version);
      if (versionObj != null) {
        if (highestVersion == null ||
            isVersionHigher(versionObj, highestVersion)) {
          highestVersion = versionObj;
        }
      }
    }
  }

  if (highestVersion == null) {
    print('Error: No valid versions found in packages');
    exit(1);
  }

  final versionString =
      '${highestVersion.major}.${highestVersion.minor}.${highestVersion.patch}';
  print('Latest unified version: $versionString\n');

  await createGitTag(versionString);
}

Future<void> createGitTag(String version) async {
  final tagName = 'v$version';
  print('Creating git tag: $tagName...');

  // Check if git is available
  try {
    final gitCheck = await Process.run('git', ['--version']);
    if (gitCheck.exitCode != 0) {
      print('Error: git is not available');
      return;
    }
  } catch (e) {
    print('Error: git is not available: $e');
    return;
  }

  // Check if we're in a git repository
  try {
    final gitDirCheck = await Process.run('git', ['rev-parse', '--git-dir']);
    if (gitDirCheck.exitCode != 0) {
      print('Error: Not in a git repository');
      return;
    }
  } catch (e) {
    print('Error: Not in a git repository: $e');
    return;
  }

  // Check if tag already exists
  try {
    final tagCheck = await Process.run('git', ['tag', '-l', tagName]);
    if (tagCheck.stdout.toString().trim() == tagName) {
      print('Warning: Tag $tagName already exists. Skipping tag creation.');
      return;
    }
  } catch (e) {
    // Continue if check fails
  }

  // Create the tag on the last commit
  try {
    final process = await Process.run('git', ['tag', tagName]);
    if (process.exitCode == 0) {
      print('✓ Successfully created git tag: $tagName');
    } else {
      print('Error: Failed to create git tag (exit code: ${process.exitCode})');
      if (process.stderr != null) {
        print('Error message: ${process.stderr}');
      }
    }
  } catch (e) {
    print('Error: Failed to create git tag: $e');
  }
}

Future<bool> updateChangelog(
    Directory package, String newVersion, List<String> allCommits) async {
  final changelogFile = File('${package.path}/CHANGELOG.md');

  String changelogContent;
  if (await changelogFile.exists()) {
    changelogContent = await changelogFile.readAsString();
  } else {
    changelogContent = '';
  }

  // Check if changelog entry for this version already exists
  final versionHeaderRegex =
      RegExp(r'^##\s+' + RegExp.escape(newVersion) + r'\s*$', multiLine: true);
  if (versionHeaderRegex.hasMatch(changelogContent)) {
    // Version entry already exists, skip updating
    return false;
  }

  // Get package name for filtering commits
  final packageName = package.path.split(Platform.pathSeparator).last;

  // Filter commits for this package
  final packageCommits = filterCommitsForPackage(allCommits, packageName);

  // Generate changelog entry
  final newEntry =
      generateChangelogEntry(newVersion, packageCommits, packageName);

  // If changelog is empty, just write the new entry
  if (changelogContent.isEmpty) {
    await changelogFile.writeAsString(newEntry);
    return true;
  }

  // Otherwise, prepend the new entry to the existing content
  final updatedContent = newEntry + changelogContent;
  await changelogFile.writeAsString(updatedContent);
  return true;
}

String? extractPreviousVersion(String changelogContent) {
  // Find the first version header (## X.Y.Z)
  final versionHeaderRegex =
      RegExp(r'^##\s+(\d+\.\d+\.\d+)\s*$', multiLine: true);
  final match = versionHeaderRegex.firstMatch(changelogContent);
  return match?.group(1);
}

Future<List<String>> getCommitsBetweenVersions(String previousVersion) async {
  final tagName = 'v$previousVersion';

  try {
    // Check if git is available
    final gitCheck = await Process.run('git', ['--version']);
    if (gitCheck.exitCode != 0) {
      print('Warning: git is not available, cannot fetch commit messages');
      return [];
    }
  } catch (e) {
    print('Warning: git is not available: $e');
    return [];
  }

  try {
    // Check if tag exists
    final tagCheck = await Process.run('git', ['tag', '-l', tagName]);
    if (tagCheck.stdout.toString().trim().isEmpty) {
      print(
          'Warning: Tag $tagName not found, cannot fetch commits for changelog');
      return [];
    }

    // Get commits between tag and HEAD
    final process = await Process.run('git', [
      'log',
      '--pretty=format:%s',
      '$tagName..HEAD',
    ]);

    if (process.exitCode == 0) {
      final output = process.stdout.toString().trim();
      return output.isEmpty ? [] : output.split('\n');
    }

    return [];
  } catch (e) {
    print('Warning: Failed to get commits: $e');
    return [];
  }
}

String normalizeScope(String scope) {
  // Normalize scope by converting to lowercase and replacing dashes/underscores
  return scope.toLowerCase().replaceAll('-', '_').replaceAll(' ', '_');
}

List<String> filterCommitsForPackage(List<String> commits, String packageName) {
  // Normalize package name for comparison
  final normalizedPackageName = normalizeScope(packageName);

  final filteredCommits = <String>[];

  for (final commit in commits) {
    final parsed = parseConventionalCommit(commit);

    if (parsed == null) {
      // Not a conventional commit, add to all packages
      filteredCommits.add(commit);
      continue;
    }

    // If commit has no scope, add to all packages
    final scope = parsed['scope'];
    if (scope == null || scope.isEmpty) {
      filteredCommits.add(commit);
      continue;
    }

    // Normalize scope for comparison
    final normalizedScope = normalizeScope(scope);

    // If scope matches package, add it
    if (normalizedScope == normalizedPackageName) {
      filteredCommits.add(commit);
    }
  }

  return filteredCommits;
}

Map<String, String?>? parseConventionalCommit(String commitMessage) {
  // Conventional commit format: type(scope): description
  // or: type: description
  // or: type(scope)!: description (breaking change)
  // or: type!: description (breaking change)

  final conventionalCommitRegex = RegExp(
    r'^(\w+)(?:\(([^)]+)\))?(!)?:\s*(.+)$',
  );

  final match = conventionalCommitRegex.firstMatch(commitMessage.trim());
  if (match == null) {
    return null;
  }

  return {
    'type': match.group(1),
    'scope': match.group(2),
    'breaking': match.group(3) != null ? 'true' : null,
    'description': match.group(4),
  };
}

String generateChangelogEntry(
    String version, List<String> commits, String packageName) {
  final buffer = StringBuffer();
  buffer.writeln('## $version');
  buffer.writeln();

  // Separate commits with scope and without scope
  final commitsWithoutScope = <String>[];
  final commitsWithScope = <String>[];

  for (final commit in commits) {
    final parsed = parseConventionalCommit(commit);
    if (parsed == null || parsed['scope'] == null || parsed['scope']!.isEmpty) {
      commitsWithoutScope.add(commit);
    } else {
      commitsWithScope.add(commit);
    }
  }

  // Add dependency bump entry for flutter_crystalline and crystalline_builder
  final shouldAddDependencyBump =
      packageName == 'flutter_crystalline' || packageName == 'crystalline_builder';

  // Write commits without scope first
  for (final commit in commitsWithoutScope) {
    final parsed = parseConventionalCommit(commit);
    if (parsed != null) {
      buffer.writeln('- ${parsed['description']}');
    } else {
      buffer.writeln('- $commit');
    }
  }

  // Add dependency bump entry after no-scope commits (if applicable)
  if (shouldAddDependencyBump) {
    buffer.writeln(
        '- Bump [crystalline](https://pub.dev/packages/crystalline) to $version');
  }

  // Write commits with scope at the bottom
  for (final commit in commitsWithScope) {
    final parsed = parseConventionalCommit(commit);
    if (parsed != null) {
      buffer.writeln('- ${parsed['description']}');
    } else {
      buffer.writeln('- $commit');
    }
  }

  // If no commits and no dependency bump, add TODO
  if (commitsWithoutScope.isEmpty &&
      commitsWithScope.isEmpty &&
      !shouldAddDependencyBump) {
    buffer.writeln('@@TODO');
  }

  buffer.writeln();
  return buffer.toString();
}

Future<void> updateReadmeVersion(String newVersion) async {
  final readmeFile = File('README.md');
  if (!await readmeFile.exists()) {
    print('Warning: README.md not found, skipping version update');
    return;
  }

  try {
    String content = await readmeFile.readAsString();

    // Replace version placeholders in the Install section
    // Pattern: ^x.y.z should be replaced with ^newVersion
    final versionPattern = RegExp(r'\^x\.y\.z');

    if (versionPattern.hasMatch(content)) {
      content = content.replaceAll(versionPattern, '^$newVersion');
      await readmeFile.writeAsString(content);
      print('✓ Updated README.md with version $newVersion');
    } else {
      // Also check for other possible patterns like just x.y.z without ^
      final versionPatternNoCaret = RegExp(r':\s*x\.y\.z');
      if (versionPatternNoCaret.hasMatch(content)) {
        content = content.replaceAll(versionPatternNoCaret, ': $newVersion');
        await readmeFile.writeAsString(content);
        print('✓ Updated README.md with version $newVersion');
      }
    }
  } catch (e) {
    print('Warning: Failed to update README.md: $e');
  }
}

Future<List<Directory>> getPackages() async {
  final packagesDir = Directory('packages');
  if (!await packagesDir.exists()) {
    print('Error: packages directory not found');
    exit(1);
  }

  return await packagesDir
      .list()
      .where((entity) => entity is Directory)
      .cast<Directory>()
      .toList();
}

class Version {
  final int major;
  final int minor;
  final int patch;

  Version(this.major, this.minor, this.patch);
}

Version? parseVersion(String versionString) {
  final versionRegex = RegExp(r'^(\d+)\.(\d+)\.(\d+)');
  final match = versionRegex.firstMatch(versionString);
  if (match == null) return null;

  return Version(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

bool isVersionHigher(Version v1, Version v2) {
  if (v1.major > v2.major) return true;
  if (v1.major < v2.major) return false;
  if (v1.minor > v2.minor) return true;
  if (v1.minor < v2.minor) return false;
  return v1.patch > v2.patch;
}

Version bumpVersion(Version version, String bumpType) {
  switch (bumpType) {
    case 'major':
      return Version(version.major + 1, 0, 0);
    case 'minor':
      return Version(version.major, version.minor + 1, 0);
    case 'patch':
      return Version(version.major, version.minor, version.patch + 1);
    default:
      return version;
  }
}

String setVersion(String pubspecContent, String newVersion) {
  final versionRegex = RegExp(r'^version:\s*(\d+\.\d+\.\d+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    return pubspecContent;
  }

  return pubspecContent.replaceFirst(
    versionRegex,
    'version: $newVersion',
  );
}

String extractVersion(String pubspecContent) {
  final versionRegex = RegExp(r'^version:\s*(\d+\.\d+\.\d+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);
  return match?.group(1) ?? 'unknown';
}

String? extractPackageName(String pubspecContent) {
  final nameRegex = RegExp(r'^name:\s*(\S+)', multiLine: true);
  final match = nameRegex.firstMatch(pubspecContent);
  return match?.group(1);
}

String updateLocalDependencies(String pubspecContent,
    Set<String> localPackageNames, String newVersion, List<String> updates) {
  // Update dependencies section
  pubspecContent = updateDependenciesSection(
      pubspecContent, 'dependencies:', localPackageNames, newVersion, updates);

  // Update dev_dependencies section
  pubspecContent = updateDependenciesSection(pubspecContent,
      'dev_dependencies:', localPackageNames, newVersion, updates);

  return pubspecContent;
}

String updateDependenciesSection(String pubspecContent, String sectionName,
    Set<String> localPackageNames, String newVersion, List<String> updates) {
  final lines = pubspecContent.split('\n');
  final updatedLines = <String>[];
  bool inSection = false;
  int indentLevel = -1;

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    // Check if we're entering the dependencies section
    if (trimmed.toLowerCase().startsWith(sectionName.toLowerCase())) {
      inSection = true;
      indentLevel = line.length - line.trimLeft().length;
      updatedLines.add(line);
      continue;
    }

    // Check if we've left the section (found a top-level key at same or less indentation)
    if (inSection && trimmed.isNotEmpty) {
      final currentIndent = line.length - line.trimLeft().length;
      if (currentIndent <= indentLevel && trimmed.contains(':')) {
        inSection = false;
        indentLevel = -1;
      }
    }

    // If we're in the section, check for local dependencies
    if (inSection && trimmed.isNotEmpty && trimmed.contains(':')) {
      final colonIndex = trimmed.indexOf(':');
      if (colonIndex > 0) {
        final packageName = trimmed.substring(0, colonIndex).trim();
        final afterColon = trimmed.substring(colonIndex + 1).trim();

        // Check if this is a local package and has a simple version constraint
        if (localPackageNames.contains(packageName) &&
            !afterColon.contains('\n') &&
            !afterColon.startsWith('path:') &&
            !afterColon.startsWith('git:') &&
            !afterColon.startsWith('sdk:')) {
          // Check if next line is indented (nested dependency like sdk: flutter)
          bool isNested = false;
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            final nextTrimmed = nextLine.trim();
            if (nextTrimmed.isNotEmpty &&
                nextLine.length - nextLine.trimLeft().length >
                    line.length - line.trimLeft().length) {
              isNested = true;
            }
          }

          if (!isNested) {
            // Update the version constraint
            final indent =
                line.substring(0, line.length - line.trimLeft().length);
            String newConstraint;

            // Handle different version constraint formats
            if (afterColon.isEmpty || afterColon == 'any') {
              newConstraint = '^$newVersion';
            } else if (afterColon.startsWith('^')) {
              newConstraint = '^$newVersion';
            } else if (afterColon.startsWith('>=')) {
              newConstraint = '^$newVersion';
            } else if (RegExp(r'^\d+\.\d+\.\d+').hasMatch(afterColon)) {
              newConstraint = '^$newVersion';
            } else {
              // Unknown format, skip
              updatedLines.add(line);
              continue;
            }

            final oldConstraint = afterColon.isEmpty ? '(none)' : afterColon;
            updates.add('$packageName: $oldConstraint → $newConstraint');
            updatedLines.add('$indent$packageName: $newConstraint');
            continue;
          }
        }
      }
    }

    updatedLines.add(line);
  }

  return updatedLines.join('\n');
}

Future<void> publishPackages(bool dryRun) async {
  // First check: Verify no @@TODO in CHANGELOG files
  print('Checking CHANGELOG files for @@TODO entries...\n');
  final packages = await getPackages();
  final packagesWithTodo = <String>[];

  for (final package in packages) {
    final changelogFile = File('${package.path}/CHANGELOG.md');
    if (await changelogFile.exists()) {
      final content = await changelogFile.readAsString();
      if (content.contains('@@TODO')) {
        final packageName = package.path.split(Platform.pathSeparator).last;
        packagesWithTodo.add(packageName);
      }
    }
  }

  if (packagesWithTodo.isNotEmpty) {
    print('Error: Found @@TODO entries in the following packages:');
    for (final packageName in packagesWithTodo) {
      print('  - $packageName');
    }
    print(
        '\nPlease remove all @@TODO entries from CHANGELOG files before publishing.');
    exit(1);
  }

  print('✓ No @@TODO entries found in CHANGELOG files.\n');

  // Get packages with pubspec.yaml
  final validPackages = <Directory>[];
  for (final package in packages) {
    final pubspecFile = File('${package.path}/pubspec.yaml');
    if (await pubspecFile.exists()) {
      validPackages.add(package);
    }
  }

  if (validPackages.isEmpty) {
    print('No valid packages found to publish');
    exit(0);
  }

  // List packages and ask user to select
  print('Available packages:');
  for (int i = 0; i < validPackages.length; i++) {
    final packageName =
        validPackages[i].path.split(Platform.pathSeparator).last;
    print('  ${i + 1}. $packageName');
  }

  print('\nEnter package numbers to publish (comma-separated, e.g., 1,2,3):');
  final input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    print('No packages selected. Exiting.');
    exit(0);
  }

  // Parse selected package numbers
  final selectedIndices = <int>[];
  final parts = input.split(',');
  for (final part in parts) {
    final trimmed = part.trim();
    final index = int.tryParse(trimmed);
    if (index != null && index >= 1 && index <= validPackages.length) {
      selectedIndices.add(index - 1); // Convert to 0-based index
    } else {
      print('Warning: Invalid package number "$trimmed", skipping.');
    }
  }

  if (selectedIndices.isEmpty) {
    print('No valid packages selected. Exiting.');
    exit(0);
  }

  // Publish selected packages
  final selectedPackages =
      selectedIndices.map((i) => validPackages[i]).toList();
  print('\n${dryRun ? 'Dry-run: ' : ''}Publishing packages...\n');

  for (final package in selectedPackages) {
    final packageName = package.path.split(Platform.pathSeparator).last;
    print('${dryRun ? '[DRY-RUN] ' : ''}Publishing $packageName...');

    final process = await Process.start(
      'dart',
      [
        'pub',
        'publish',
        if (dryRun) '--dry-run',
      ],
      workingDirectory: package.path,
      mode: ProcessStartMode.inheritStdio,
    );

    final exitCode = await process.exitCode;
    if (exitCode != 0) {
      print('\nError: Failed to publish $packageName (exit code: $exitCode)');
      exit(exitCode);
    }
    print(
        '✓ ${dryRun ? '[DRY-RUN] ' : ''}Successfully published $packageName\n');
  }

  print('${dryRun ? 'Dry-run ' : ''}Publish completed!');
}
