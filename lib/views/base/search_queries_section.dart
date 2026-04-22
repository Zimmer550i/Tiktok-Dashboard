import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tiktok_dashboard/controller/analytics_controller.dart';
import 'package:tiktok_dashboard/model/search_query_model.dart';
import 'package:get/get.dart';

class SearchQueriesSection extends StatelessWidget {
  SearchQueriesSection({super.key});

  final controller = Get.find<AnalyticsController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Obx(() {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Row(
              children: [
                Text(
                  "Search queries",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.info_outline, size: 16, color: Color(0xFF8E8E93)),
              ],
            ),
            const SizedBox(height: 16),

            // Rows
            ...List.generate(controller.searchQueries.length, (i) {
              final item = controller.searchQueries[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _QueryRow(
                  item: item,
                  onSave: () => controller.saveSearchQueries(),
                ),
              );
            }),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _QueryRow extends StatelessWidget {
  final SearchQueryModel item;
  final VoidCallback onSave;

  const _QueryRow({required this.item, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isEditing = item.isEditing.value;

      return GestureDetector(
        onLongPress: () => item.isEditing.value = true,
        child: Column(
          children: [
            Row(
              children: [
                // Title
                Expanded(
                  child: isEditing
                      ? TextFormField(
                          initialValue: item.title.value,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E8E93),
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: "Query text",
                            hintStyle: TextStyle(color: Color(0xFF8E8E93)),
                          ),
                          onChanged: (v) => item.title.value = v,
                          onFieldSubmitted: (_) => _save(),
                        )
                      : Text(
                          item.title.value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8E8E93),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                const SizedBox(width: 8),

                // Percent
                isEditing
                    ? SizedBox(
                        width: 60,
                        child: TextFormField(
                          initialValue: (item.percent.value * 100)
                              .toStringAsFixed(1),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.]'),
                            ),
                          ],
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.end,
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            suffix: Text(
                              "%",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          onChanged: (v) {
                            final parsed = double.tryParse(v);
                            if (parsed != null) {
                              item.percent.value = (parsed / 100).clamp(0, 1);
                            }
                          },
                          onFieldSubmitted: (_) => _save(),
                        ),
                      )
                    : Text(
                        "${(item.percent.value * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),

                if (isEditing) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _save,
                    child: const Icon(
                      Icons.check_circle,
                      color: Color(0xFF60B3FF),
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),

            // Progress bar
            ClipRRect(
              child: LinearProgressIndicator(
                value: item.percent.value,
                minHeight: 6,
                backgroundColor: const Color(0xFF2C2C2E),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF60B3FF)),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _save() {
    item.isEditing.value = false;
    onSave();
  }
}
