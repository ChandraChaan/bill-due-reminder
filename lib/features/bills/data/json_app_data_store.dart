import 'dart:convert';
import 'dart:io';

import '../domain/app_data.dart';
import '../domain/repositories.dart';

/// Keeps [AppData] in one JSON file in the app's private storage.
///
/// Writes go to a temporary file that is then renamed over the old one, so a
/// crash mid-write never leaves a half-written file behind.
final class JsonAppDataStore implements AppDataStore {
  JsonAppDataStore(this._directory);

  final Future<Directory> Function() _directory;

  Future<File> _file() async =>
      File('${(await _directory()).path}/dueday.json');

  @override
  Future<AppData> load() async {
    final file = await _file();
    if (!file.existsSync()) return AppData.empty();
    final text = await file.readAsString();
    return AppData.fromJson(jsonDecode(text) as Map<String, Object?>);
  }

  @override
  Future<void> save(AppData data) async {
    final file = await _file();
    final temp = File('${file.path}.tmp');
    await temp.writeAsString(jsonEncode(data.toJson()), flush: true);
    await temp.rename(file.path);
  }

  @override
  Future<void> deleteAll() async {
    final file = await _file();
    if (file.existsSync()) await file.delete();
  }
}
