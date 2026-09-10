import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/dev_console_theme.dart';
import 'package:flutter/scheduler.dart';

import '../../interceptors/performance/cold_start_timer.dart';
import '../../interceptors/performance/frame_drop_detector.dart';
import '../../interceptors/performance/memory_probe.dart';
import '../../interceptors/performance/performance_history.dart';

/// The Performance tab's UI: live FPS/memory/startup/jank metric cards plus
/// their rolling history sparklines and a recent-jank-frames list.
class PerformanceTab extends StatefulWidget {
  const PerformanceTab({super.key});

  @override
  State<PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<PerformanceTab> {
  double _fps = 0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  int _memoryMb = 0;

  bool _disposed = false;
  late final void Function(Duration) _frameCallback;

  @override
  void initState() {
    super.initState();

    _frameCallback = (Duration _) {
      // The callback re-arms itself, so it must stop once the tab is gone —
      // otherwise it keeps the engine producing frames for the life of the app.
      if (_disposed) return;

      _frameCount++;
      final now = DateTime.now();
      final elapsed = now.difference(_lastFpsUpdate);
      if (elapsed.inMilliseconds >= 1000) {
        final fps = _frameCount * 1000 / elapsed.inMilliseconds;
        _frameCount = 0;
        _lastFpsUpdate = now;
        _updateMemory();
        PerformanceHistory.record(fps: fps, memoryMb: currentMemoryMb());
        if (mounted) setState(() => _fps = fps);
      }

      SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
    };

    SchedulerBinding.instance.scheduleFrameCallback(_frameCallback);
    _updateMemory();
  }

  void _updateMemory() {
    final mb = currentMemoryMb();
    if (mb != null && mounted) setState(() => _memoryMb = mb);
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        FrameDropDetector.version,
        ColdStartTimer.version,
        PerformanceHistory.version,
      ]),
      builder: (context, _) {
        final totalFrames = FrameDropDetector.totalFrames;
        final jankFrames = FrameDropDetector.jankFrameCount;
        final jankPct =
            totalFrames == 0
                ? 0.0
                : (jankFrames / totalFrames * 100).clamp(0.0, 100.0);
        final coldStart = ColdStartTimer.coldStart;

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
              value: _memoryMb > 0 ? '$_memoryMb MB' : 'N/A',
              icon: Icons.memory,
              color: _memColor(_memoryMb),
              subtitle: 'Current resident set size (RSS)',
            ),
            const SizedBox(height: 12),
            _MetricCard(
              label: 'Startup',
              value: coldStart == null ? '—' : '${coldStart.inMilliseconds} ms',
              icon: Icons.rocket_launch_outlined,
              color: _startupColor(coldStart),
              subtitle: 'Toolkit init to first rendered frame',
            ),
            const SizedBox(height: 12),
            _MetricCard(
              label: 'Jank Frames',
              value: '$jankFrames / $totalFrames',
              icon: Icons.warning_amber_outlined,
              color: jankFrames == 0 ? Colors.green : Colors.orange,
              subtitle:
                  '${jankPct.toStringAsFixed(1)}% of frames exceeded '
                  '${FrameDropDetector.budget.inMilliseconds} ms',
            ),
            const SizedBox(height: 24),
            if (PerformanceHistory.samples.length >= 2) ...[
              _HistorySection(
                title: 'FPS (LAST ${PerformanceHistory.samples.length}S)',
                color: Colors.blue,
                values: PerformanceHistory.samples.map((s) => s.fps).toList(),
              ),
              const SizedBox(height: 16),
              if (PerformanceHistory.samples.any((s) => s.memoryMb != null))
                _HistorySection(
                  title:
                      'MEMORY MB (LAST ${PerformanceHistory.samples.length}S)',
                  color: Colors.purple,
                  values:
                      PerformanceHistory.samples
                          .where((s) => s.memoryMb != null)
                          .map((s) => s.memoryMb!.toDouble())
                          .toList(),
                ),
              const SizedBox(height: 24),
            ],
            if (FrameDropDetector.jankFrames.isNotEmpty) ...[
              Text(
                'RECENT JANK FRAMES',
                style: TextStyle(
                  color: palette.subtle,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              ...FrameDropDetector.jankFrames.reversed
                  .take(10)
                  .map((frame) => _JankRow(frame: frame)),
              const SizedBox(height: 24),
            ],
            Text(
              'A jank frame is any frame whose build + raster time exceeds '
              '${FrameDropDetector.budget.inMilliseconds} ms (the threshold '
              'for 60 fps). High jank counts indicate UI thread bottlenecks.',
              style: TextStyle(
                color: palette.subtle,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ],
        );
      },
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

  Color _startupColor(Duration? coldStart) {
    if (coldStart == null) return Colors.grey;
    if (coldStart.inMilliseconds < 500) return Colors.green;
    if (coldStart.inMilliseconds < 1500) return Colors.orange;
    return Colors.red;
  }
}

class _HistorySection extends StatelessWidget {
  const _HistorySection({
    required this.title,
    required this.color,
    required this.values,
  });

  final String title;
  final Color color;
  final List<double> values;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: palette.subtle,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              values.last.toStringAsFixed(0),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _Sparkline(values: values, color: color),
      ],
    );
  }
}

/// A minimal line chart with no charting dependency — this package stays at
/// zero third-party UI deps by design.
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.values, required this.color});

  final List<double> values;
  final Color color;

  static const double _height = 48;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({required this.values, required this.color});

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxV = values.reduce(math.max);
    final minV = values.reduce(math.min);
    // A flat series (e.g. a constant 60fps) would divide by zero; fall back to
    // drawing a flat line across the middle instead.
    final range = (maxV - minV) < 1e-6 ? 1.0 : (maxV - minV);
    final dx = size.width / (values.length - 1);

    double yFor(double v) => size.height - ((v - minV) / range) * size.height;

    final linePath = Path();
    final fillPath = Path()..moveTo(0, size.height);

    for (var i = 0; i < values.length; i++) {
      final x = i * dx;
      final y = yFor(values[i]);
      if (i == 0) {
        linePath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
      }
      fillPath.lineTo(x, y);
    }
    fillPath
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withAlpha(70), color.withAlpha(0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      !identical(oldDelegate.values, values) || oldDelegate.color != color;
}

class _JankRow extends StatelessWidget {
  const _JankRow({required this.frame});

  final JankFrame frame;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${frame.total.inMilliseconds} ms',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Text(
            'build ${frame.build.inMilliseconds} ms · '
            'raster ${frame.raster.inMilliseconds} ms',
            style: TextStyle(color: palette.faint, fontSize: 11),
          ),
        ],
      ),
    );
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
        color: palette.surface,
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
                  style: TextStyle(
                    color: palette.subtle,
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
                  style: TextStyle(color: palette.faint, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
