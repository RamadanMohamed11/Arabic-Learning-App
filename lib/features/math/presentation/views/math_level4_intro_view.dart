import 'package:flutter/material.dart';
import 'package:arabic_learning_app/core/utils/app_colors.dart';
import 'package:arabic_learning_app/features/math/data/math_level4_data.dart';
import 'package:arabic_learning_app/core/audio/app_tts_service.dart';
import 'package:arabic_learning_app/core/utils/animated_route.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'math_level4_half1_activities_view.dart';

class MathLevel4IntroView extends StatefulWidget {
  const MathLevel4IntroView({super.key});

  @override
  State<MathLevel4IntroView> createState() => _MathLevel4IntroViewState();
}

class _MathLevel4IntroViewState extends State<MathLevel4IntroView> {
  late YoutubePlayerController _controller;
  bool _isVideoPlaying = false;
  
  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: kAdditionVideoUrl,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        forceHD: true,
      ),
    )..addListener(_videoListener);

    AppTtsService.instance.speakScreenIntro(
      'قبل أن نبدأ، هيا نتعرف على معني الجمع ونشاهد هذا الفيديو.',
      isMounted: () => mounted,
    );
  }

  void _videoListener() {
    if (_controller.value.isPlaying && !_isVideoPlaying) {
      _isVideoPlaying = true;
      AppTtsService.instance.stop();
    } else if (!_controller.value.isPlaying && _isVideoPlaying) {
      _isVideoPlaying = false;
    }
  }

  @override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    _controller.dispose();
    AppTtsService.instance.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تعريف الجمع',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.level4.first,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFFFF3E0), Colors.white], // Light orange gradient
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  kAdditionIntroText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.8,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: YoutubePlayer(
                  controller: _controller,
                  showVideoProgressIndicator: true,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  _controller.pause();
                  Navigator.pushReplacement(
                    context,
                    AnimatedRoute.fadeScale(
                      const MathLevel4Half1ActivitiesView(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow, size: 30, color: Colors.white),
                label: const Text(
                  'ابدأ التدريبات',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.level4.last,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
