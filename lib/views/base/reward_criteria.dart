import 'package:flutter/material.dart';
import 'package:tiktok_dashboard/controller/performance_controller.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class RewardCriteria extends StatelessWidget {
  const RewardCriteria({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Obx(() {
      final d = controller.data.value;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reward criteria",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ...List.generate(d.criteria.length, (index) {
              final item = d.criteria[index];
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < d.criteria.length - 1 ? 16 : 0,
                ),
                child: _CriteriaItem(
                  index: index,
                  title: item.title,
                  icon: item.icon,
                  desc: item.desc,
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}

class _CriteriaItem extends StatelessWidget {
  final int index;
  final String title;
  final String desc;
  final String icon;

  const _CriteriaItem({
    required this.index,
    required this.title,
    required this.desc,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PerformanceController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => _showIconPicker(context, index, controller),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF2C2C2E),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: SvgPicture.asset(
                "assets/icons/$icon.svg",
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.error, color: Colors.white24, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _edit(
                  context,
                  "Criteria Title",
                  title,
                  (v) => controller.updateCriteriaTitle(index, v),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => _edit(
                  context,
                  "Criteria Description",
                  desc,
                  (v) => controller.updateCriteriaDesc(index, v),
                ),
                child: Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showIconPicker(
    BuildContext context,
    int index,
    PerformanceController controller,
  ) {
    Get.defaultDialog(
      title: "Choose Icon",
      content: Wrap(
        children: ["face", "upload", "upside"].map((i) {
          return IconButton(
            icon: SvgPicture.asset("assets/icons/$i.svg", width: 24),
            onPressed: () {
              controller.updateCriteriaIcon(index, i);
              Get.back();
            },
          );
        }).toList(),
      ),
    );
  }

  void _edit(
    BuildContext context,
    String title,
    String initial,
    Function(String) onSave,
  ) {
    final tController = TextEditingController(text: initial);

    Get.defaultDialog(
      title: title,
      content: TextField(
        controller: tController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(hintText: "Enter value"),
      ),
      confirm: ElevatedButton(
        onPressed: () {
          onSave(tController.text);
          Get.back();
        },
        child: const Text("Save"),
      ),
    );
  }
}
