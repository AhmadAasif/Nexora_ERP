import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../theme/app_theme.dart';

class RevenueChart extends StatelessWidget {
  const RevenueChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Revenue overview',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Your business performance this year',
                      style: TextStyle(color: AppTheme.muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F8FC),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Row(
                  children: <Widget>[
                    Text(
                      '2026',
                      style: TextStyle(
                        color: AppTheme.ink,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 7),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Row(
            children: <Widget>[
              _LegendDot(color: AppTheme.primary, label: 'Revenue'),
              SizedBox(width: 18),
              _LegendDot(color: Color(0xFF19B58A), label: 'Expenses'),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 190,
            width: double.infinity,
            child: CustomPaint(
              painter: _RevenueChartPainter(
                revenue: monthlyRevenue,
                expenses: <double>[
                  12, 18, 16, 21, 20, 26, 24, 30, 28, 34, 32, 39,
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: monthLabels.map((label) {
              return Text(
                label,
                style: const TextStyle(color: AppTheme.muted, fontSize: 10),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        children: <Widget>[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(color: AppTheme.muted, fontSize: 11),
          ),
        ],
      );
}

class _RevenueChartPainter extends CustomPainter {
  const _RevenueChartPainter({
    required this.revenue,
    required this.expenses,
  });

  final List<double> revenue;
  final List<double> expenses;

  @override
  void paint(Canvas canvas, Size size) {
    const left = 8.0;
    const right = 8.0;
    const top = 8.0;
    const bottom = 8.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    const maxValue = 100.0;

    final gridPaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = top + (chartHeight / 3) * i;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
    }

    List<Offset> pointsFor(List<double> values) {
      return List<Offset>.generate(values.length, (index) {
        final x = left + (chartWidth / (values.length - 1)) * index;
        final y = top + chartHeight - (values[index] / maxValue) * chartHeight;
        return Offset(x, y);
      });
    }

    Path createPath(List<Offset> points) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        final previous = points[i - 1];
        final current = points[i];
        final middleX = (previous.dx + current.dx) / 2;
        path.cubicTo(
          middleX,
          previous.dy,
          middleX,
          current.dy,
          current.dx,
          current.dy,
        );
      }
      return path;
    }

    final revenuePoints = pointsFor(revenue);
    final expensePoints = pointsFor(expenses);
    final revenuePath = createPath(revenuePoints);
    final expensePath = createPath(expensePoints);

    final fillPath = Path.from(revenuePath)
      ..lineTo(revenuePoints.last.dx, top + chartHeight)
      ..lineTo(revenuePoints.first.dx, top + chartHeight)
      ..close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0x333457D5), Color(0x003457D5)],
      ).createShader(Rect.fromLTWH(left, top, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    final expensePaint = Paint()
      ..color = const Color(0xFF19B58A)
      ..strokeWidth = 2.3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final revenuePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(expensePath, expensePaint);
    canvas.drawPath(revenuePath, revenuePaint);

    final lastPoint = revenuePoints.last;
    canvas.drawCircle(lastPoint, 5, Paint()..color = Colors.white);
    canvas.drawCircle(lastPoint, 3, Paint()..color = AppTheme.primary);
    canvas.drawCircle(
      revenuePoints[8],
      4,
      Paint()..color = AppTheme.primary,
    );
  }

  @override
  bool shouldRepaint(covariant _RevenueChartPainter oldDelegate) {
    return oldDelegate.revenue != revenue ||
        oldDelegate.expenses != expenses;
  }
}
