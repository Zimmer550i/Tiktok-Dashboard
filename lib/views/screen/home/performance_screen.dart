// ignore_for_file: unused_element_parameter

import 'package:flutter/material.dart';
import 'package:flutter_extension/controller/performance_controller.dart';
import 'package:flutter_extension/views/base/creator_reward_section.dart';
import 'package:flutter_extension/views/base/reward_calculation.dart';
import 'package:get/get.dart';

class PerformancePage extends StatelessWidget {
  final controller = Get.put(PerformanceController());

  PerformancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 10),

            const _Header(),

            const SizedBox(height: 16),

            CreatorRewardsSection(),

            const SizedBox(height: 16),

            RewardsCard(),

            const SizedBox(height: 16),

            _CreatingVideos(),

            const SizedBox(height: 16),

            const _RewardCriteria(),

            const SizedBox(height: 16),

            _ViewMoreButton(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _RewardCriteria extends StatelessWidget {
  const _RewardCriteria();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Reward criteria",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 18),
          _CriteriaItem(
            title: "Well-crafted",
            icon: Icons.workspace_premium_outlined,
            desc:
                "High-quality 1 min+ videos that show an attention to detail in the creation process.",
          ),
          SizedBox(height: 16),
          _CriteriaItem(
            title: "Engaging",
            icon: Icons.favorite_border,
            desc:
                "Captivating 1 min+ videos that resonate with and inspire viewers.",
          ),
          SizedBox(height: 16),
          _CriteriaItem(
            title: "Specialized",
            icon: Icons.auto_awesome_outlined,
            desc:
                "In-depth 1 min+ videos that focus on a specific theme or expertise.",
          ),
        ],
      ),
    );
  }
}

class _CriteriaItem extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;

  const _CriteriaItem({
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF2C2C2E),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Performance",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2),
              Text(
                "Last update: Feb 15",
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreatingVideos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Creating high-quality videos",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 6),

          Text(
            "Best practices to get the additional reward.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),

          SizedBox(height: 12),

          Row(
            children: [
              _Tag("Well-crafted"),
              SizedBox(width: 8),
              _Tag("Engaging"),
              SizedBox(width: 8),
              _Tag("Specialized"),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              _VideoCard(),
              SizedBox(width: 8),
              _VideoCard(),
              SizedBox(width: 8),
              _VideoCard(),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E).withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final String title;
  final String author;
  final String? assetPath; // optional local asset
  final String? imageUrl; // optional remote image

  const _VideoCard({
    super.key,
    this.title = "TikTok is now\nencouraging creator\n...",
    this.author = "Seth",
    this.assetPath,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // matches 3 items in a row with spacing
    return Expanded(
      child: AspectRatio(
        aspectRatio: 0.82, // tuned to resemble screenshot cards
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Background thumbnail
              Positioned.fill(
                child: _Thumb(assetPath: assetPath, imageUrl: imageUrl),
              ),

              // Bottom dark gradient overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.25),
                        Colors.black.withOpacity(0.75),
                      ],
                      stops: const [0.45, 0.70, 1.0],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        height: 1.15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text(
                          "🎵",
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  final String? assetPath;
  final String? imageUrl;

  const _Thumb({this.assetPath, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (assetPath != null) {
      return Image.asset(assetPath!, fit: BoxFit.cover);
    }

    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    // fallback style similar to screenshot (subtle dark thumbnail)
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A2A2A), Color(0xFF1B1B1B)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.play_circle_fill, color: Colors.white24, size: 28),
      ),
    );
  }
}

class _ViewMoreButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xff2c2c2c),
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: const Text(
        "View more",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 2, dashSpace = 2, startX = 0;
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
