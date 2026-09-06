import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_dev_toolkit/core/crash_log_store.dart';
import 'package:flutter_dev_toolkit/core/default_logger.dart';
import 'package:flutter_dev_toolkit/core/dev_toolkit_config.dart';
import 'package:flutter_dev_toolkit/core/logger_interface.dart';
import 'package:flutter_dev_toolkit/core/network_log_store.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/network/network_log.dart';
import 'package:flutter_dev_toolkit/interceptors/route_interceptor.dart';
import 'package:flutter_dev_toolkit/models/built_in_plugin_type.dart';
import 'package:flutter_dev_toolkit/plugins/adapters/bloc_adapter.dart';
import 'package:flutter_dev_toolkit/plugins/state_inspector/bloc_state_tracker.dart';
import 'package:flutter_dev_toolkit/models/crash_entry.dart';
import 'package:flutter_dev_toolkit/models/log_entry.dart';
import 'package:flutter_dev_toolkit/models/log_tag.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DefaultLogger', () {
    test('retains entries up to the constructor cap, dropping the oldest', () {
      final logger = DefaultLogger(maxEntries: 3);

      for (var i = 0; i < 5; i++) {
        logger.log('message $i');
      }

      expect(logger.logEntries.length, 3);
      expect(logger.logEntries.first.message, 'message 2');
      expect(logger.logEntries.last.message, 'message 4');
    });

    test('defaults to a 2000 entry cap', () {
      expect(DefaultLogger().maxEntries, DefaultLogger.defaultMaxEntries);
      expect(DefaultLogger.defaultMaxEntries, 2000);
    });

    test('configure() applies a cap and trims entries already held', () {
      final logger = DefaultLogger();
      for (var i = 0; i < 10; i++) {
        logger.log('message $i');
      }

      logger.configure(maxEntries: 4);

      expect(logger.maxEntries, 4);
      expect(logger.logEntries.length, 4);
      expect(logger.logEntries.first.message, 'message 6');
    });

    test('configure() does not override an explicit constructor cap', () {
      final logger = DefaultLogger(maxEntries: 3);

      logger.configure(maxEntries: 500);

      expect(logger.maxEntries, 3);
    });

    test('counts error-level entries only', () {
      final before = DefaultLogger.errorCount.value;
      final logger = DefaultLogger();

      logger.log('debug');
      logger.log('info', level: LogLevel.info);
      logger.log('warning', level: LogLevel.warning);
      logger.log('boom', level: LogLevel.error);
      logger.log('boom again', level: LogLevel.error);

      expect(DefaultLogger.errorCount.value - before, 2);
    });

    test('clear() empties the buffer and bumps logVersion', () {
      final logger = DefaultLogger();
      logger.log('something');
      final version = DefaultLogger.logVersion.value;

      logger.clear();

      expect(logger.logEntries, isEmpty);
      expect(DefaultLogger.logVersion.value, greaterThan(version));
    });

    test('logEntries is an unmodifiable view', () {
      final logger = DefaultLogger();
      logger.log('something');

      expect(
        () => logger.logEntries.add(LogEntry(message: 'nope')),
        throwsUnsupportedError,
      );
    });

    test('preserves the level and tags it was given', () {
      final logger = DefaultLogger();

      logger.log('tagged', level: LogLevel.warning, tags: {LogTag.network});

      final entry = logger.logEntries.single;
      expect(entry.level, LogLevel.warning);
      expect(entry.tags, {LogTag.network});
    });
  });

  group('FlutterDevToolkit.init', () {
    late FlutterExceptionHandler? savedOnError;

    setUp(() => savedOnError = FlutterError.onError);
    tearDown(() => FlutterError.onError = savedOnError);

    DevToolkitConfig configFor(DefaultLogger logger, {int? maxLogEntries}) {
      return DevToolkitConfig(
        logger: logger,
        // Keep built-in plugins out of these tests: their onInit hooks reach
        // for platform channels that aren't available in a unit test.
        disableBuiltInPlugins: BuiltInPluginType.values,
        maxLogEntries: maxLogEntries ?? 2000,
      );
    }

    test('applies config.maxLogEntries to a DefaultLogger', () {
      final logger = DefaultLogger();

      FlutterDevToolkit.init(config: configFor(logger, maxLogEntries: 5));

      expect(logger.maxEntries, 5);

      for (var i = 0; i < 20; i++) {
        logger.log('message $i');
      }
      expect(logger.logEntries.length, 5);
      expect(logger.logEntries.last.message, 'message 19');
    });

    test('leaves an explicitly configured logger alone', () {
      final logger = DefaultLogger(maxEntries: 3);

      FlutterDevToolkit.init(config: configFor(logger, maxLogEntries: 500));

      expect(logger.maxEntries, 3);
    });

    test('applies config.maxNetworkLogs to the network store', () {
      NetworkLogStore.clear();
      addTearDown(() {
        NetworkLogStore.clear();
        NetworkLogStore.configure(maxLogs: 500);
      });

      FlutterDevToolkit.init(
        config: DevToolkitConfig(
          logger: DefaultLogger(),
          disableBuiltInPlugins: BuiltInPluginType.values,
          maxNetworkLogs: 2,
        ),
      );

      for (var i = 0; i < 4; i++) {
        NetworkLogStore.add(_log(url: 'https://example.test/$i'));
      }

      expect(NetworkLogStore.logs.length, 2);
      expect(NetworkLogStore.logs.first.url, 'https://example.test/2');
    });

    test('exposes the toolkit as enabled and installs the given logger', () {
      final logger = DefaultLogger();

      FlutterDevToolkit.init(config: configFor(logger));

      expect(FlutterDevToolkit.isEnabled, isTrue);
      expect(identical(FlutterDevToolkit.logger, logger), isTrue);
    });
  });

  group('DevToolkitConfig', () {
    test('has conservative defaults', () {
      final config = DevToolkitConfig(logger: DefaultLogger());

      expect(config.enableInRelease, isFalse);
      expect(config.maxLogEntries, 2000);
      expect(config.maxNetworkLogs, 500);
      expect(config.disableBuiltInPlugins, isEmpty);
    });
  });

  group('NetworkLogStore', () {
    setUp(() {
      NetworkLogStore.clear();
      NetworkLogStore.configure(maxLogs: 500);
    });

    tearDown(() {
      NetworkLogStore.clear();
      NetworkLogStore.configure(maxLogs: 500);
    });

    test('drops the oldest log once the cap is reached', () {
      NetworkLogStore.configure(maxLogs: 3);

      for (var i = 0; i < 5; i++) {
        NetworkLogStore.add(_log(url: 'https://example.test/$i'));
      }

      expect(NetworkLogStore.logs.length, 3);
      expect(NetworkLogStore.logs.first.url, 'https://example.test/2');
      expect(NetworkLogStore.logs.last.url, 'https://example.test/4');
    });

    test('logs is an unmodifiable view', () {
      NetworkLogStore.add(_log());

      expect(() => NetworkLogStore.logs.add(_log()), throwsUnsupportedError);
    });

    test('clear() empties the store', () {
      NetworkLogStore.add(_log());

      NetworkLogStore.clear();

      expect(NetworkLogStore.logs, isEmpty);
    });
  });

  group('CrashLogStore', () {
    setUp(CrashLogStore.clear);
    tearDown(CrashLogStore.clear);

    test('records entries and bumps version', () {
      final version = CrashLogStore.version.value;

      CrashLogStore.add(
        CrashEntry(message: 'boom', stackTrace: '#0 main', isFatal: true),
      );

      expect(CrashLogStore.entries.single.message, 'boom');
      expect(CrashLogStore.entries.single.isFatal, isTrue);
      expect(CrashLogStore.version.value, greaterThan(version));
    });

    test('caps retained crashes at 200', () {
      for (var i = 0; i < 205; i++) {
        CrashLogStore.add(CrashEntry(message: 'crash $i', stackTrace: ''));
      }

      expect(CrashLogStore.entries.length, 200);
      expect(CrashLogStore.entries.first.message, 'crash 5');
      expect(CrashLogStore.entries.last.message, 'crash 204');
    });

    test('entries is an unmodifiable view', () {
      expect(
        () => CrashLogStore.entries.add(
          CrashEntry(message: 'nope', stackTrace: ''),
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('CrashEntry.toJson', () {
    test('round-trips through JSON encoding', () {
      final timestamp = DateTime.utc(2026, 3, 28, 12, 30);
      final entry = CrashEntry(
        message: 'boom',
        stackTrace: '#0 main',
        isFatal: true,
        timestamp: timestamp,
      );

      final decoded =
          json.decode(json.encode(entry.toJson())) as Map<String, dynamic>;

      expect(decoded['message'], 'boom');
      expect(decoded['stackTrace'], '#0 main');
      expect(decoded['isFatal'], isTrue);
      expect(decoded['timestamp'], timestamp.toIso8601String());
    });
  });

  group('NetworkLog.toJson', () {
    test('passes an already-decoded body through untouched', () {
      // Dio hands back decoded Maps and Lists, so toJson must not assume a
      // String here — doing so used to throw a TypeError on export.
      final log = _log(responseBody: {'id': 1, 'name': 'widget'});

      expect(log.toJson()['responseBody'], {'id': 1, 'name': 'widget'});
    });

    test('passes a decoded list body through untouched', () {
      final log = _log(responseBody: [1, 2, 3]);

      expect(log.toJson()['responseBody'], [1, 2, 3]);
    });

    test('decodes a JSON string body', () {
      final log = _log(responseBody: '{"id":1}');

      expect(log.toJson()['responseBody'], {'id': 1});
    });

    test('leaves a non-JSON string body as-is', () {
      final log = _log(responseBody: 'not json at all');

      expect(log.toJson()['responseBody'], 'not json at all');
    });

    test('leaves a null body as null', () {
      expect(_log().toJson()['responseBody'], isNull);
    });

    test('reports the duration in milliseconds', () {
      final log = _log(duration: const Duration(milliseconds: 250));

      expect(log.toJson()['duration'], 250);
    });
  });

  group('NetworkLog HAR export', () {
    test('maps request metadata onto the HAR entry', () {
      final log = _log(
        method: 'POST',
        url: 'https://api.example.test/v1/items?page=2&sort=name',
        requestHeaders: {'Accept': 'application/json'},
        requestBody: {'name': 'widget'},
        statusCode: 201,
        duration: const Duration(milliseconds: 120),
        startedAt: DateTime.utc(2026, 3, 28, 12),
      );

      final entry = log.toHarEntry();
      final request = entry['request'] as Map<String, dynamic>;

      expect(entry['time'], 120);
      expect(entry['startedDateTime'], '2026-03-28T12:00:00.000Z');
      expect(request['method'], 'POST');
      expect(
        request['url'],
        'https://api.example.test/v1/items?page=2&sort=name',
      );
      expect(request['headers'], [
        {'name': 'Accept', 'value': 'application/json'},
      ]);
      expect(request['queryString'], [
        {'name': 'page', 'value': '2'},
        {'name': 'sort', 'value': 'name'},
      ]);
      expect((request['postData'] as Map)['text'], '{"name":"widget"}');
    });

    test('omits postData when there is no request body', () {
      expect(_log().toHarEntry()['request']['postData'], isNull);
    });

    test('resolves a status text for known status codes', () {
      expect(
        _log(statusCode: 404).toHarEntry()['response']['statusText'],
        'Not Found',
      );
      expect(
        _log(statusCode: 200).toHarEntry()['response']['statusText'],
        'OK',
      );
      expect(_log(statusCode: 599).toHarEntry()['response']['statusText'], '');
    });

    test('falls back to status 0 when the request never got a response', () {
      expect(_log().toHarEntry()['response']['status'], 0);
    });

    test('toHarDocument emits a parseable HAR 1.2 document', () {
      final document = NetworkLog.toHarDocument([
        _log(url: 'https://example.test/a'),
        _log(url: 'https://example.test/b'),
      ]);

      final decoded = json.decode(document) as Map<String, dynamic>;
      final harLog = decoded['log'] as Map<String, dynamic>;

      expect(harLog['version'], '1.2');
      expect((harLog['creator'] as Map)['name'], 'Flutter Dev Toolkit');
      expect(harLog['entries'], hasLength(2));
      expect(harLog['entries'][0]['request']['url'], 'https://example.test/a');
    });

    test('toHarDocument handles an empty log list', () {
      final decoded =
          json.decode(NetworkLog.toHarDocument([])) as Map<String, dynamic>;

      expect(decoded['log']['entries'], isEmpty);
    });
  });

  group('LogEntry', () {
    test('defaults to a debug level, no tags and a timestamp', () {
      final entry = LogEntry(message: 'hello');

      expect(entry.level, LogLevel.debug);
      expect(entry.tags, isEmpty);
      expect(entry.timestamp, isNotNull);
    });
  });

  group('DevBlocObserver', () {
    setUp(DevBlocObserver.clear);
    tearDown(DevBlocObserver.clear);

    test('records the previous state alongside the new one', () {
      final observer = DevBlocObserver();
      final cubit = _CounterCubit();
      addTearDown(cubit.close);

      observer.onChange(cubit, const Change(currentState: 0, nextState: 1));

      final entry = DevBlocObserver.entries.single;
      expect(entry.blocType, '_CounterCubit');
      expect(entry.currentState, 1);
      expect(entry.previousState, 0);
    });

    test('surfaces the transition through BlocAdapter', () {
      final observer = DevBlocObserver();
      final cubit = _CounterCubit();
      addTearDown(cubit.close);

      observer.onChange(cubit, const Change(currentState: 1, nextState: 2));

      final entry = BlocAdapter().entries.single;
      expect(entry.source, '_CounterCubit');
      expect(entry.value, 2);
      expect(entry.previousState, 1);
    });

    test('caps retained transitions and drops the oldest', () {
      final observer = DevBlocObserver();
      final cubit = _CounterCubit();
      addTearDown(cubit.close);

      for (var i = 0; i < DevBlocObserver.maxEntries + 5; i++) {
        observer.onChange(cubit, Change(currentState: i, nextState: i + 1));
      }

      expect(DevBlocObserver.entries.length, DevBlocObserver.maxEntries);
      expect(DevBlocObserver.entries.first.currentState, 6);
    });

    test('bumps version so the inspector can rebuild live', () {
      final observer = DevBlocObserver();
      final cubit = _CounterCubit();
      addTearDown(cubit.close);
      final before = DevBlocObserver.version.value;

      observer.onChange(cubit, const Change(currentState: 0, nextState: 1));

      expect(DevBlocObserver.version.value, greaterThan(before));
      expect(BlocAdapter().revision, isNotNull);
    });

    test('clear() empties the buffer', () {
      final observer = DevBlocObserver();
      final cubit = _CounterCubit();
      addTearDown(cubit.close);
      observer.onChange(cubit, const Change(currentState: 0, nextState: 1));

      DevBlocObserver.clear();

      expect(DevBlocObserver.entries, isEmpty);
    });

    test('entries is an unmodifiable view', () {
      expect(
        () => DevBlocObserver.entries.add(BlocStateEntry('X', 1)),
        throwsUnsupportedError,
      );
    });
  });

  group('RouteInterceptor.clear', () {
    late RouteInterceptor observer;

    setUp(() {
      FlutterDevToolkit.init(
        config: DevToolkitConfig(
          logger: DefaultLogger(),
          disableBuiltInPlugins: BuiltInPluginType.values,
        ),
      );
      observer = RouteInterceptor.instance as RouteInterceptor;
    });

    test('drops history but keeps routes that are still on the stack', () {
      final a = _route('/a');
      final b = _route('/b');
      observer.didPush(a, null);
      observer.didPush(b, a);
      addTearDown(() {
        observer.didPop(b, a);
        observer.didPop(a, null);
        RouteInterceptor.clear();
      });

      expect(RouteInterceptor.routeHistory, isNotEmpty);

      RouteInterceptor.clear();

      expect(RouteInterceptor.routeHistory, isEmpty);
      // Both screens are still open, so the stack and their entry timestamps
      // must survive for duration tracking to stay correct.
      expect(RouteInterceptor.routeStack, ['/a', '/b']);
      expect(RouteInterceptor.entryTimestamps.keys, containsAll(['/a', '/b']));
    });

    test('does not leak timestamps for routes that were popped', () {
      final a = _route('/gone');
      observer.didPush(a, null);
      observer.didPop(a, null);

      RouteInterceptor.clear();

      expect(RouteInterceptor.entryTimestamps, isNot(contains('/gone')));
      expect(RouteInterceptor.routeStack, isNot(contains('/gone')));
    });

    test('keeps the stack ordered when a route is pushed twice', () {
      // A → B → A. Popping the second A must leave [/a, /b], not [/b, /a].
      final a1 = _route('/a');
      final b = _route('/b');
      final a2 = _route('/a');
      observer.didPush(a1, null);
      observer.didPush(b, a1);
      observer.didPush(a2, b);
      addTearDown(() {
        for (final r in [a2, b, a1]) {
          observer.didPop(r, null);
        }
        RouteInterceptor.clear();
      });

      expect(RouteInterceptor.routeStack, ['/a', '/b', '/a']);

      observer.didPop(a2, b);

      expect(RouteInterceptor.routeStack, ['/a', '/b']);
      // The first /a is still open, so its entry time must survive.
      expect(RouteInterceptor.entryTimestamps, contains('/a'));
    });
  });
}

class _CounterCubit extends Cubit<int> {
  _CounterCubit() : super(0);
}

PageRoute<void> _route(String name) => MaterialPageRoute<void>(
  builder: (_) => const SizedBox.shrink(),
  settings: RouteSettings(name: name),
);

NetworkLog _log({
  String method = 'GET',
  String url = 'https://example.test/resource',
  Map<String, dynamic>? requestHeaders,
  Map<String, dynamic>? requestBody,
  int? statusCode,
  dynamic responseBody,
  Duration duration = const Duration(milliseconds: 10),
  bool isError = false,
  DateTime? startedAt,
}) {
  return NetworkLog(
    method: method,
    url: url,
    requestHeaders: requestHeaders,
    requestBody: requestBody,
    statusCode: statusCode,
    responseBody: responseBody,
    duration: duration,
    isError: isError,
    startedAt: startedAt,
  );
}
