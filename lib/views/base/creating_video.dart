import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:tiktok_dashboard/controller/performance_controller.dart';
import 'package:tiktok_dashboard/model/performance_model.dart';
import 'package:get/get.dart';

class CreatingVideos extends StatelessWidget {
  const CreatingVideos({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Obx(() {
      final d = controller.data.value;

      return Container(
        clipBehavior: Clip.antiAlias, // Ensure children stay inside
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Creating high-quality videos",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Best practices to get the additional reward.",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Tag(
                  "Well-crafted",
                  isSelected: d.selectedVideoTagIndex == 0,
                  onTap: () => controller.setSelectedVideoTag(0),
                ),
                _Tag(
                  "Engaging",
                  isSelected: d.selectedVideoTagIndex == 1,
                  onTap: () => controller.setSelectedVideoTag(1),
                ),
                _Tag(
                  "Specialized",
                  isSelected: d.selectedVideoTagIndex == 2,
                  onTap: () => controller.setSelectedVideoTag(2),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: List.generate(d.videoCards.length, (index) {
                  final card = d.videoCards[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < d.videoCards.length - 1 ? 10 : 0,
                    ),
                    child: SizedBox(
                      width: 135, // Adjusted for better fit
                      child: _VideoCard(index: index, card: card),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tag(this.text, {required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2C2C2E).withValues(alpha: 0.8)
              : null,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: Colors.white24, width: 0.5)
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final int index;
  final VideoCardModel card;

  const _VideoCard({required this.index, required this.card});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return AspectRatio(
      aspectRatio: 0.72, // Balanced for horizontal scrolling
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Stack(
          children: [
            // Background thumbnail
            Positioned.fill(child: _Thumb(imageUrl: card.imageUrl)),

            // Bottom dark gradient overlay
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _showEditOptions(context, index, card, controller),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.01),
                        Colors.black.withValues(alpha: 0.95),
                      ],
                      stops: const [0.4, 0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Positioned(
              left: 10,
              right: 10,
              bottom: 12,
              child: IgnorePointer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      card.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.1,
                        fontWeight: FontWeight.w700, // Bolder
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Circular Avatar
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white24,
                              width: 0.5,
                            ),
                          ),
                          child: ClipOval(
                            child: _Thumb(
                              imageUrl: card.authorImageUrl,
                              isAvatar: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            card.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOptions(
    BuildContext context,
    int index,
    VideoCardModel card,
    PerformanceController controller,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Edit Video Card",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildEditTile(
              "Edit Title",
              Icons.title,
              () => _edit(
                context,
                "Video Title",
                card.title,
                (v) => controller.updateVideoCardTitle(index, v),
              ),
            ),
            _buildEditTile(
              "Edit Author Name",
              Icons.person,
              () => _edit(
                context,
                "Video Author",
                card.author,
                (v) => controller.updateVideoCardAuthor(index, v),
              ),
            ),
            _buildEditTile(
              "Pick Thumbnail Image",
              Icons.photo_library,
              () => controller.pickImage(index),
            ),
            _buildEditTile(
              "Pick Author Avatar Image",
              Icons.face,
              () => controller.pickAuthorImage(index),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Get.back();
        onTap();
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  final String imageUrl;
  final bool isAvatar;

  const _Thumb({required this.imageUrl, this.isAvatar = false});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        );
      } else if (imageUrl.startsWith('/')) {
        // Handle local file path (from Image Picker)
        final file = io.File(imageUrl);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        }
      }
      // Fallback for asset or unknown
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallback(),
      );
    }

    return _fallback();
  }

  Widget _fallback() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF333333), Color(0xFF111111)],
        ),
      ),
      child: isAvatar
          ? const SizedBox() // Explicitly empty for avatars
          : const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white24,
                size: 24,
              ),
            ),
    );
  }
}

void _edit(
  BuildContext context,
  String title,
  String initial,
  Function(String) onSave,
) {
  final controller = TextEditingController(text: initial);

  Get.defaultDialog(
    backgroundColor: const Color(0xFF2C2C2E),
    titleStyle: const TextStyle(color: Colors.white),
    title: title,
    content: TextField(
      controller: controller,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Enter $title",
        hintStyle: const TextStyle(color: Colors.white30),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white24),
        ),
      ),
    ),
    confirm: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      onPressed: () {
        onSave(controller.text);
        Get.back();
      },
      child: const Text("Save"),
    ),
    cancel: TextButton(
      onPressed: () => Get.back(),
      child: const Text("Cancel", style: TextStyle(color: Colors.white70)),
    ),
  );
}
