import 'dart:io' show ProcessInfo;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class PerformanceTab extends StatefulWidget {
  const PerformanceTab({super.key});

  @override
  State<PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<PerformanceTab> {
  double _fps = 0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  int _totalFrames = 0;
  int _jankFrames = 0; // frames exceeding 16 ms build + raster

  int _memoryMb = 0;

  late final void Function(Duration) _frameCallback;
  late final FrameTimingCallback _timingCallback;

  @override
  void initState() {
    super.initState();

    _frameCallback = (Duration _) {
      _frameCount++;
      _totalFrames++;
      final now = DateTime.now();
      final elapsed = now.difference(_lastFpsUpdate);
      if (elapsed.inMilliseconds >= 1000) {
        final fps = _frameCount / elapsed.inSeconds;
        _frameCount = 0;
        _lastFpsUpdate = now;
        _updateMemory();
        if (mounted) setState(() => _fps = fps);
      }
      // Schedule next frame
      SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
    };

    _timingCallback = (List<FrameTiming> timings) {
      for (final t in timings) {
        final totalMs =
            t.buildDuration.inMilliseconds + t.rasterDuration.inMilliseconds;
        if (totalMs > 16) {
          _jankFrames++;
          if (mounted) setState(() {});
        }
      }
    };

    SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
    SchedulerBinding.instance.addTimingsCallback(_timingCallback);
    _updateMemory();
  }

  void _updateMemory() {
    try {
      final mb = (ProcessInfo.currentRss / 1024 / 1024).round();
      if (mounted) setState(() => _memoryMb = mb);
    } catch (_) {
      // ProcessInfo not available on web
    }
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_timingCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jankPct =
        _totalFrames == 0
            ? 0.0
            : (_jankFrames / _totalFrames * 100).clamp(0.0, 100.0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _MetricCard(
          label: 'FPS',
          value: _fps.toStringAsFixed(1),
          icon: Icons.speed,
          color: _fpsColor(_fps),
          subtitle: 'Frames rendered per second',
        ),
        const SizedBox(height: 12),
        _MetricCard(
          label: 'Memory',
          value: _memoryMb > 0 ? '${_memoryMb} MB' : 'N/A',
          icon: Icons.memory,
          color: _memColor(_memoryMb),
          subtitle: 'Current resident set size (RSS)',
        ),
        const SizedBox(height: 12),
        _MetricCard(
          label: 'Jank Frames',
          value: '$_jankFrames / $_totalFrames',
          icon: Icons.warning_amber_outlined,
          color: _jankFrames == 0 ? Colors.green : Colors.orange,
          subtitle:
              '${jankPct.toStringAsFixed(1)}% of frames exceeded 16 ms',
        ),
        const SizedBox(height: 24),
        const Text(
          'A jank frame is any frame whose build + raster time exceeds 16 ms '
          '(the threshold for 60 fps). High jank counts indicate UI thread '
          'bottlenecks.',
          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.6),
        ),
      ],
    );
  }

  Color _fpsColor(double fps) {
    if (fps >= 55) return Colors.green;
    if (fps >= 30) return Colors.orange;
    return Colors.red;
  }

  Color _memColor(int mb) {
    if (mb == 0) return Colors.grey;
    if (mb < 150) return Colors.green;
    if (mb < 300) return Colors.orange;
    return Colors.red;
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
