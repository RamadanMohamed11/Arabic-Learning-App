import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_drawing/path_drawing.dart';
import 'dart:ui';

class AutomatedLetterTraceScreen extends StatefulWidget {
  final String svgAssetPath;
  final int letterIndex;
  final VoidCallback? onComplete;

  const AutomatedLetterTraceScreen({
    super.key,
    required this.svgAssetPath,
    required this.letterIndex,
    this.onComplete,
  });

  @override
  State<AutomatedLetterTraceScreen> createState() =>
      _AutomatedLetterTraceScreenState();
}

class _AutomatedLetterTraceScreenState
    extends State<AutomatedLetterTraceScreen> {
  // Multiple paths (e.g., letter body + dot)
  List<Path> guidePaths = [];
  List<List<Offset>> allPathPoints = [];

  // Current path being traced
  int currentPathIndex = 0;
  List<Offset> userPath = []; // Current drawing
  List<List<Offset>> allUserPaths = []; // All completed user paths
  int nextPointIndex = 0;

  // Completion tracking
  List<bool> pathsCompleted = [];
  bool allCompleted = false;

  bool _isLoading = true;
  bool _showFeedback = false;
  bool _isPerfect = false;
  int _missedPoints = 0;
  int _totalAttempts = 0;

  @override
  void initState() {
    super.initState();
    _loadAndParseSvg();
  }

  Future<void> _loadAndParseSvg() async {
    try {
      final String svgString = await rootBundle.loadString(widget.svgAssetPath);
      print('📄 SVG loaded, length: ${svgString.length}');

      if (svgString.isEmpty) {
        print('❌ SVG is empty!');
        return;
      }

      // Extract ALL paths from the SVG
      final RegExp pathRegExp = RegExp(r'd="([^"]+)"');
      final Iterable<Match> matches = pathRegExp.allMatches(svgString);

      print('🔍 Found ${matches.length} paths in SVG');

      if (matches.isEmpty) {
        print('❌ No paths found!');
        return;
      }

      // Parse each path separately
      List<Path> parsedPaths = [];
      int pathIndex = 0;

      for (final Match match in matches) {
        try {
          final String pathData = match.group(1)!;
          print('📍 Path $pathIndex data length: ${pathData.length}');

          // Validate that path starts with M or m (moveTo command)
          final String trimmedPath = pathData.trim();
          if (!trimmedPath.startsWith('M') && !trimmedPath.startsWith('m')) {
            print('⚠️ Path $pathIndex does not start with moveTo, skipping');
            pathIndex++;
            continue;
          }

          final Path parsedPath = parseSvgPathData(pathData);
          parsedPaths.add(parsedPath);
          pathIndex++;
        } catch (e) {
          print('❌ Error parsing path $pathIndex: $e');
          pathIndex++;
        }
      }

      print('✅ Successfully parsed ${parsedPaths.length} paths');

      if (parsedPaths.isEmpty) {
        print('❌ No valid paths!');
        return;
      }

      // Get bounds of all paths combined for scaling
      final Path combinedPath = Path();
      for (final path in parsedPaths) {
        combinedPath.addPath(path, Offset.zero);
      }
      final Rect bounds = combinedPath.getBounds();
      print(
        '📏 Bounds: ${bounds.left}, ${bounds.top}, ${bounds.right}, ${bounds.bottom}',
      );
      print('📐 Size: ${bounds.width} x ${bounds.height}');

      if (bounds.width == 0 || bounds.height == 0) {
        print('❌ Invalid bounds!');
        return;
      }

      // Calculate scale to fit in a 280x280 area (leaving 20px margin on each side)
      final double targetSize = 280.0;
      final double scaleX = targetSize / bounds.width;
      final double scaleY = targetSize / bounds.height;
      final double scale = scaleX < scaleY ? scaleX : scaleY;

      print('🔢 Scale: $scale');

      // Center the path in the 320x320 canvas
      final double scaledWidth = bounds.width * scale;
      final double scaledHeight = bounds.height * scale;
      final double offsetX = (320 - scaledWidth) / 2 - bounds.left * scale;
      final double offsetY = (320 - scaledHeight) / 2 - bounds.top * scale;

      print('📍 Offset: $offsetX, $offsetY');

      final Matrix4 matrix = Matrix4.identity()
        ..translate(offsetX, offsetY)
        ..scale(scale, scale);

      // Transform and generate points for each path separately
      List<Path> transformedPaths = [];
      List<List<Offset>> allPoints = [];

      for (int i = 0; i < parsedPaths.length; i++) {
        final Path transformedPath = parsedPaths[i].transform(matrix.storage);
        transformedPaths.add(transformedPath);

        // Generate points for this path
        List<Offset> pathPoints = [];
        final PathMetrics pathMetrics = transformedPath.computeMetrics();
        for (final PathMetric pathMetric in pathMetrics) {
          print('📏 Path $i metric length: ${pathMetric.length}');
          for (
            double distance = 0;
            distance < pathMetric.length;
            distance += 15
          ) {
            final Tangent? tangent = pathMetric.getTangentForOffset(distance);
            if (tangent != null) {
              pathPoints.add(tangent.position);
            }
          }
        }
        allPoints.add(pathPoints);
        print('✅ Path $i: Generated ${pathPoints.length} points');
      }

      setState(() {
        guidePaths = transformedPaths;
        allPathPoints = allPoints;
        pathsCompleted = List.filled(parsedPaths.length, false);
        allUserPaths = List.filled(parsedPaths.length, []);
        currentPathIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading SVG: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void resetDrawing() {
    setState(() {
      userPath.clear();
      allUserPaths = List.filled(guidePaths.length, []);
      nextPointIndex = 0;
      currentPathIndex = 0;
      pathsCompleted = List.filled(guidePaths.length, false);
      allCompleted = false;
      _showFeedback = false;
      _missedPoints = 0;
    });
  }

  void onUserDrag(Offset userPosition) {
    if (allCompleted ||
        _isLoading ||
        currentPathIndex >= allPathPoints.length ||
        nextPointIndex >= allPathPoints[currentPathIndex].length) {
      return;
    }

    List<Offset> currentPathPoints = allPathPoints[currentPathIndex];
    Offset targetPoint = currentPathPoints[nextPointIndex];
    double distance = (userPosition - targetPoint).distance;

    if (distance < 35.0) {
      setState(() {
        userPath.add(targetPoint);
        nextPointIndex++;

        // Check if current path is completed
        if (nextPointIndex >= currentPathPoints.length) {
          pathsCompleted[currentPathIndex] = true;
          allUserPaths[currentPathIndex] = List.from(
            userPath,
          ); // Save completed path
          print('✅ Path $currentPathIndex completed!');

          // Move to next path
          currentPathIndex++;

          // Check if all paths are completed
          if (currentPathIndex >= allPathPoints.length) {
            allCompleted = true;
            _totalAttempts++;
            _evaluateDrawing();
          } else {
            // Reset for next path
            userPath.clear();
            nextPointIndex = 0;
            print('👉 Starting path $currentPathIndex');
          }
        }
      });
    }
  }

  void _evaluateDrawing() {
    // Check if all paths were completed successfully
    bool allPathsSuccess = pathsCompleted.every((completed) => completed);

    // Calculate total points across all paths
    int totalPoints = allPathPoints.fold(
      0,
      (sum, points) => sum + points.length,
    );
    double accuracy = (totalPoints - _missedPoints) / totalPoints * 100;

    setState(() {
      _isPerfect = allPathsSuccess && accuracy >= 85;
      _showFeedback = true;
    });

    // Auto-hide feedback after 3 seconds if perfect
    if (_isPerfect) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showFeedback = false;
          });
          // Call onComplete callback if perfect
          widget.onComplete?.call();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'تتبع الحرف',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.teal.shade600)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Instructions
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 2),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            currentPathIndex < allPathPoints.length
                                ? 'تتبع المسار ${currentPathIndex + 1} من ${allPathPoints.length}\nيمكنك رفع إصبعك بين المسارات!'
                                : 'تتبع الحرف باتباع المسار الرمادي.\nيمكنك رفع إصبعك بين المسارات!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.blue.shade900,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Progress Indicator
                  if (allPathPoints.isNotEmpty)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(allPathPoints.length, (index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 40,
                          height: 8,
                          decoration: BoxDecoration(
                            color: pathsCompleted[index]
                                ? Colors.green
                                : index == currentPathIndex
                                ? Colors.teal
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),

                  const SizedBox(height: 20),

                  // Drawing Board
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.teal.shade200, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: GestureDetector(
                        onPanStart: (details) {
                          if (allCompleted ||
                              allPathPoints.isEmpty ||
                              currentPathIndex >= allPathPoints.length) {
                            return;
                          }
                          List<Offset> currentPoints =
                              allPathPoints[currentPathIndex];
                          if (currentPoints.isEmpty) return;

                          // If continuing the same path (already started)
                          if (nextPointIndex > 0 &&
                              nextPointIndex < currentPoints.length) {
                            // Check if near the next point to continue
                            double distanceToNextPoint =
                                (details.localPosition -
                                        currentPoints[nextPointIndex])
                                    .distance;
                            if (distanceToNextPoint < 50.0) {
                              onUserDrag(details.localPosition);
                            }
                          } else if (nextPointIndex == 0) {
                            // Must start from the beginning
                            double distanceToFirstPoint =
                                (details.localPosition - currentPoints[0])
                                    .distance;
                            if (distanceToFirstPoint < 35.0) {
                              onUserDrag(details.localPosition);
                            }
                          }
                        },
                        onPanUpdate: (details) =>
                            onUserDrag(details.localPosition),
                        onPanEnd: (details) {
                          // Do NOT reset - allow user to lift finger and continue
                          // Only reset if they barely started (less than 10% of current path)
                          if (!allCompleted &&
                              currentPathIndex < allPathPoints.length) {
                            List<Offset> currentPoints =
                                allPathPoints[currentPathIndex];
                            // Only reset if user completed less than 10% of current path
                            if (nextPointIndex > 0 &&
                                nextPointIndex < (currentPoints.length * 0.1)) {
                              _missedPoints++;
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                resetDrawing,
                              );
                            }
                            // Otherwise, keep progress and allow them to continue
                          }
                        },
                        child: CustomPaint(
                          size: const Size(320, 320),
                          painter: AutomatedLetterPainter(
                            guidePaths: guidePaths,
                            userDrawnPoints: userPath,
                            allUserPaths: allUserPaths,
                            allCompleted: allCompleted,
                            currentPathIndex: currentPathIndex,
                            nextPointIndex: nextPointIndex,
                            allPathPoints: allPathPoints,
                            pathsCompleted: pathsCompleted,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Feedback Message
                  AnimatedOpacity(
                    opacity: _showFeedback ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isPerfect
                              ? [Colors.green.shade50, Colors.green.shade100]
                              : [Colors.orange.shade50, Colors.orange.shade100],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _isPerfect ? Colors.green : Colors.orange,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _isPerfect ? Icons.star : Icons.refresh,
                            color: _isPerfect ? Colors.green : Colors.orange,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _isPerfect ? '🎉 ممتاز! 🎉' : 'حاول مرة أخرى!',
                            style: TextStyle(
                              color: _isPerfect ? Colors.green : Colors.orange,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isPerfect
                                ? 'عمل رائع! لقد تتبعت الحرف بشكل مثالي!'
                                : 'استمر في التدريب! يمكنك القيام بعمل أفضل!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _isPerfect
                                  ? Colors.green.shade900
                                  : Colors.orange.shade900,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Reset Button
                  ElevatedButton.icon(
                    onPressed: resetDrawing,
                    icon: const Icon(Icons.refresh),
                    label: const Text(
                      'حاول مرة أخرى',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Stats
                  Text(
                    'المحاولات: $_totalAttempts',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AutomatedLetterPainter extends CustomPainter {
  final List<Path> guidePaths;
  final List<Offset> userDrawnPoints;
  final List<List<Offset>> allUserPaths;
  final bool allCompleted;
  final int currentPathIndex;
  final int nextPointIndex;
  final List<List<Offset>> allPathPoints;
  final List<bool> pathsCompleted;

  AutomatedLetterPainter({
    required this.guidePaths,
    required this.userDrawnPoints,
    required this.allUserPaths,
    required this.allCompleted,
    required this.currentPathIndex,
    required this.nextPointIndex,
    required this.allPathPoints,
    required this.pathsCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (guidePaths.isEmpty) return;

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 30.0
      ..style = PaintingStyle.stroke;

    // Draw all guide paths
    for (int i = 0; i < guidePaths.length; i++) {
      if (pathsCompleted[i]) {
        // Draw completed paths in green
        paint.color = Colors.greenAccent;
        canvas.drawPath(guidePaths[i], paint);
      } else if (i == currentPathIndex) {
        // Draw current path in gray
        paint.color = Colors.grey.withOpacity(0.3);
        canvas.drawPath(guidePaths[i], paint);
      } else {
        // Draw future paths in darker gray
        paint.color = Colors.grey.withOpacity(0.15);
        canvas.drawPath(guidePaths[i], paint);
      }
    }

    // Draw all completed user paths in teal
    for (int i = 0; i < allUserPaths.length; i++) {
      if (allUserPaths[i].isNotEmpty && pathsCompleted[i]) {
        final completedPath = Path();
        completedPath.moveTo(
          allUserPaths[i].first.dx,
          allUserPaths[i].first.dy,
        );
        for (int j = 1; j < allUserPaths[i].length; j++) {
          completedPath.lineTo(allUserPaths[i][j].dx, allUserPaths[i][j].dy);
        }
        paint.color = Colors.teal;
        canvas.drawPath(completedPath, paint);
      }
    }

    // Draw all completed paths
    if (allCompleted) {
      paint.color = Colors.greenAccent;
      for (final path in guidePaths) {
        canvas.drawPath(path, paint);
      }

      // Draw sparkles effect on all paths
      final sparklesPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;

      for (final points in allPathPoints) {
        if (points.length >= 5) {
          for (int i = 0; i < 5; i++) {
            final offset = points[i * (points.length ~/ 5)];
            canvas.drawCircle(offset, 3, sparklesPaint);
          }
        }
      }
    }
    // Draw user progress on current path
    else if (currentPathIndex < allPathPoints.length && nextPointIndex > 0) {
      // User has made progress, show what they've drawn so far
      if (userDrawnPoints.isNotEmpty) {
        final userPath = Path();
        userPath.moveTo(userDrawnPoints.first.dx, userDrawnPoints.first.dy);
        for (int i = 1; i < userDrawnPoints.length; i++) {
          userPath.lineTo(userDrawnPoints[i].dx, userDrawnPoints[i].dy);
        }
        paint.color = Colors.teal;
        canvas.drawPath(userPath, paint);
      }

      // Draw next target point (where to continue from)
      List<Offset> currentPoints = allPathPoints[currentPathIndex];
      if (nextPointIndex < currentPoints.length) {
        final targetPaint = Paint()
          ..color = Colors.yellowAccent
          ..style = PaintingStyle.fill;
        canvas.drawCircle(currentPoints[nextPointIndex], 15, targetPaint);

        // Draw pulsing ring to indicate "continue from here"
        final ringPaint = Paint()
          ..color = Colors.yellowAccent.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(currentPoints[nextPointIndex], 25, ringPaint);
      }
    }
    // Draw starting point indicator for current path
    else if (currentPathIndex < allPathPoints.length &&
        allPathPoints[currentPathIndex].isNotEmpty) {
      List<Offset> currentPoints = allPathPoints[currentPathIndex];
      final startPaint = Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.fill;
      canvas.drawCircle(currentPoints[0], 15, startPaint);

      // Draw pulsing ring around start point
      final ringPaint = Paint()
        ..color = Colors.greenAccent.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(currentPoints[0], 25, ringPaint);

      // Draw path number indicator
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'المسار ${currentPathIndex + 1}/${guidePaths.length}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.rtl,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, size.height - 30));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
