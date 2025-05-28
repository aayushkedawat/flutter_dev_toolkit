import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dev_toolkit/core/logger_interface.dart';
import 'package:flutter_dev_toolkit/flutter_dev_toolkit.dart';
import 'package:flutter_dev_toolkit/interceptors/network/dio_interceptor.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _makeDioRequest() async {
    final dio = Dio();
    dio.interceptors.add(DioNetworkInterceptor());

    try {
      await dio.get('https://jsonplaceholder.typicode.com/posts/1');
      FlutterDevToolkit.logger.log('Dio request complete');
    } catch (e) {
      FlutterDevToolkit.logger.log('Dio error: $e', level: LogLevel.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                FlutterDevToolkit.logger.log('User tapped Log button');
              },
              child: const Text('Log a Message'),
            ),
            ElevatedButton(
              onPressed: _makeDioRequest,
              child: const Text('Make Network Request'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/details');
              },
              child: const Text('Go to Details Page'),
            ),
          ],
        ),
      ),
    );
  }
}
