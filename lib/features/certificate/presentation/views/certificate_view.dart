import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class CertificateView extends StatelessWidget {
  const CertificateView({
    super.key,
    this.participantName = 'اسم الطالب',
    this.date = '18 نوفمبر 2025',
  });

  final String participantName;
  final String date;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardHeight = math.max(size.height * 0.9, 720.0);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5E8),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: cardHeight),
                child: _CertificateCard(
                  participantName: participantName,
                  date: date,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.participantName, required this.date});

  final String participantName;
  final String date;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF7DD),
                  Color(0xFFFDFBF0),
                  Color(0xFFF8F5E8),
                ],
              ),
            ),
          ),
          const _BlurredCircle(
            top: -40,
            right: -10,
            size: 220,
            color: Color(0xFF80A1BA),
          ),
          const _BlurredCircle(
            bottom: -60,
            left: -40,
            size: 240,
            color: Color(0xFF91C4C3),
          ),
          const _BlurredCircle(
            top: 200,
            left: 20,
            size: 300,
            color: Color(0xFFB4DEBD),
          ),
          const _GeometricPatternOverlay(),
          const CertificateBorder(),
          const Positioned(
            top: 32,
            right: 32,
            child: DecorativePattern(size: 64, color: Color(0xFFB4DEBD)),
          ),
          const Positioned(
            top: 32,
            left: 32,
            child: Opacity(
              opacity: 0.5,
              child: StarBurst(size: 52, color: Color(0xFF91C4C3)),
            ),
          ),
          const Positioned(
            bottom: 32,
            right: 32,
            child: Opacity(
              opacity: 0.5,
              child: StarBurst(size: 52, color: Color(0xFF80A1BA)),
            ),
          ),
          const Positioned(
            bottom: 32,
            left: 32,
            child: Opacity(
              opacity: 0.3,
              child: DecorativePattern(size: 48, color: Color(0xFF91C4C3)),
            ),
          ),
          Positioned(bottom: 48, left: 0, right: 0, child: const _LogoBadge()),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeaderSection(),
                  _NameSection(participantName: participantName),
                  const SizedBox(height: 20),
                  const _DescriptionSection(),
                  const SizedBox(height: 32),
                  _FooterSection(date: date),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF80A1BA), Color(0xFF5A7B94), Color(0xFF80A1BA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds),
          child: Text(
            'شهادة تقدير',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w700,
              fontFamily: 'Amiri',
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
        const _DecorativeUnderline(),
        const SizedBox(height: 50),
        const Text(
          'تُمنح هذه الشهادة لـ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Amiri',
            color: Color(0xFF91C4C3),
          ),
        ),
      ],
    );
  }
}

class _NameSection extends StatelessWidget {
  const _NameSection({required this.participantName});

  final String participantName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            participantName,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Color(0xFF5A7B94),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        const _NameUnderlineDots(),
      ],
    );
  }
}

class _DescriptionSection extends StatelessWidget {
  const _DescriptionSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _AccentLine(),
            SizedBox(width: 8),
            Icon(Icons.star, size: 18, color: Color(0xFF91C4C3)),
            SizedBox(width: 8),
            _AccentLine(),
          ],
        ),
        const SizedBox(height: 12),
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontFamily: 'Cairo',
              color: Color(0xFF80A1BA),
              fontWeight: FontWeight.w600,
            ),
            children: [
              TextSpan(text: 'تقديراً لتميزه في دروس تطبيق '),
              TextSpan(
                text: 'الأمل',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF91C4C3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterSection extends StatelessWidget {
  const _FooterSection({required this.date});

  final String date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(32),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3380A1BA),
                blurRadius: 10,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFFB4DEBD),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF80A1BA),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SignatureArea(),
      ],
    );
  }
}

class _SignatureArea extends StatelessWidget {
  const _SignatureArea();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        SizedBox(height: 16),
        SignatureBlock(name: 'فريق الأمل'),
      ],
    );
  }
}

class CertificateBorder extends StatelessWidget {
  const CertificateBorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _CertificateBorderPainter()),
      ),
    );
  }
}

class _CertificateBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final outerRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(32),
    );
    final innerRect = outerRect.deflate(12);

    final outerPaint = Paint()
      ..color = const Color(0xFFB4DEBD).withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(outerRect, outerPaint);
    canvas.drawRRect(innerRect, innerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DecorativePattern extends StatelessWidget {
  const DecorativePattern({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PatternPainter(color: color)),
    );
  }
}

class _PatternPainter extends CustomPainter {
  const _PatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = size.center(Offset.zero);
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, size.width * 0.15 * i, paint);
    }
    final diagonal = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, 0)
      ..moveTo(size.width * 0.2, size.height)
      ..lineTo(size.width, size.height * 0.2);
    canvas.drawPath(diagonal, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StarBurst extends StatelessWidget {
  const StarBurst({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _StarBurstPainter(color: color)),
    );
  }
}

class _StarBurstPainter extends CustomPainter {
  const _StarBurstPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path();
    final center = size.center(Offset.zero);
    final rays = 12;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < rays; i++) {
      final angle = (math.pi * 2 / rays) * i;
      final nextAngle = angle + (math.pi * 2 / rays) / 2;

      final outerPoint = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );
      final innerPoint = Offset(
        center.dx + innerRadius * math.cos(nextAngle),
        center.dy + innerRadius * math.sin(nextAngle),
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class SignatureBlock extends StatelessWidget {
  const SignatureBlock({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: 200, height: 2, color: const Color(0xFFB4DEBD)),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontFamily: 'Amiri',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A7B94),
          ),
        ),
      ],
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  const _BlurredCircle({
    this.left,
    this.top,
    this.right,
    this.bottom,
    required this.size,
    required this.color,
  });

  final double? left;
  final double? top;
  final double? right;
  final double? bottom;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.6), color.withOpacity(0.2)],
            ),
          ),
        ),
      ),
    );
  }
}

class _GeometricPatternOverlay extends StatelessWidget {
  const _GeometricPatternOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _GeometricPatternPainter()),
      ),
    );
  }
}

class _GeometricPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    final circlePaint = Paint()
      ..color = const Color(0xFF80A1BA).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..color = const Color(0xFF91C4C3).withOpacity(0.08)
      ..strokeWidth = 0.6;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x + spacing / 2, y + spacing / 2),
          1.5,
          circlePaint,
        );
        canvas.drawLine(
          Offset(x, y),
          Offset(x + spacing, y + spacing),
          linePaint,
        );
        canvas.drawLine(
          Offset(x + spacing, y),
          Offset(x, y + spacing),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _DecorativeUnderline extends StatelessWidget {
  const _DecorativeUnderline();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _GradientLine(width: 32, reverse: true),
        _Dot(color: const Color(0xFFB4DEBD)),
        _GradientLine(width: 70),
        _Dot(color: const Color(0xFFB4DEBD)),
        _GradientLine(width: 32, reverse: true),
      ],
    );
  }
}

class _GradientLine extends StatelessWidget {
  const _GradientLine({required this.width, this.reverse = false});

  final double width;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
          end: reverse ? Alignment.centerLeft : Alignment.centerRight,
          colors: const [Colors.transparent, Color(0xFFB4DEBD)],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

class _NameUnderlineDots extends StatelessWidget {
  const _NameUnderlineDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFB4DEBD),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFB4DEBD),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF91C4C3),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFB4DEBD),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Color(0xFFB4DEBD),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AccentLine extends StatelessWidget {
  const _AccentLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 2,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Color(0xFF91C4C3)],
        ),
      ),
    );
  }
}

class _LogoBadge extends StatelessWidget {
  const _LogoBadge();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x3380A1BA),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
              border: Border.all(color: const Color(0xFFB4DEBD), width: 3),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.school,
                  color: Color(0xFF80A1BA),
                  size: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
