import 'dart:async';

import 'package:flutter/services.dart';
import 'package:sms_bill_parser/sms_bill_parser.dart';

import '../domain/repositories.dart';

/// Talks to `SmsBridge.kt`. The Kotlin side filters by sender before any
/// message reaches Dart, so only business SMS come through here.
final class PlatformSmsSource implements SmsSource {
  PlatformSmsSource() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'arrived') _arrivals.add(null);
    });
  }

  static const MethodChannel _channel = MethodChannel(
    'dev.chandra.bill_due_reminder/sms',
  );

  final StreamController<void> _arrivals = StreamController<void>.broadcast();

  @override
  Stream<void> get arrivals => _arrivals.stream;

  @override
  Future<SmsAccess> access() async =>
      _access(await _channel.invokeMethod<String>('access'));

  @override
  Future<SmsAccess> requestAccess() async =>
      _access(await _channel.invokeMethod<String>('requestAccess'));

  @override
  Future<List<SmsInput>> readInbox({required DateTime since}) async =>
      _messages(
        await _channel.invokeListMethod<Object?>('readInbox', {
          'since': since.millisecondsSinceEpoch,
        }),
      );

  @override
  Future<List<SmsInput>> takeArrived() async =>
      _messages(await _channel.invokeListMethod<Object?>('takeArrived'));

  @override
  Future<void> openAppSettings() => _channel.invokeMethod<void>('openSettings');

  static SmsAccess _access(String? value) => switch (value) {
    'granted' => SmsAccess.granted,
    'blocked' => SmsAccess.blocked,
    _ => SmsAccess.denied,
  };

  static List<SmsInput> _messages(List<Object?>? raw) => [
    for (final item in raw ?? const <Object?>[])
      if (item is Map<Object?, Object?>)
        SmsInput(
          sender: item['sender']! as String,
          body: item['body']! as String,
          receivedAt: DateTime.fromMillisecondsSinceEpoch(
            item['receivedAt']! as int,
          ),
        ),
  ];
}
