import 'package:flutter/material.dart';
import '../models/destination.dart';
import '../models/saved_destinations.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback onTap;

  const DestinationCard({
    super.key,
    required this.destination,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // ── 1. Decoration: rounded corner + shadow ──────────────
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        // ── 2. ClipRRect ป้องกัน Image เกิน Rounded Corner ──────
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 3. Stack: Image + Rating Badge ────────────────
              Stack(
                children: [
                  // 3a. รูป Destination
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      destination.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported, size: 48),
                      ),
                    ),
                  ),
                  // ── Checkpoint 3.1 & 3.3 ───────────────────────────
                  // คำอธิบาย Checkpoint 3.3:
                  // ทำไมต้องใช้ Positioned คู่กับ Stack:
                  // Positioned เป็น ParentDataWidget ที่สื่อสารตำแหน่ง (top, bottom, left, right)
                  // กับ RenderStack โดยตรง เพื่อกำหนดพิกัดแน่นอนของ Widget ย่อยบนพื้นที่ของ Stack
                  // หากนำ Positioned ไปใช้นอก Stack (เช่น ใน Column, Row หรือ Container ทั่วไป)
                  // Flutter จะเกิด Runtime Error / AssertionError ("Positioned widgets must be placed directly inside a Stack")
                  // และแอปจะ Crash ทันที เพราะ Parent ตัวอื่นไม่มี RenderStackParentData ที่เข้าใจตำแหน่งสัมพัทธ์นี้
                  //
                  // Checkpoint 3.1: ย้าย Rating Badge ไปที่มุมซ้ายล่าง (bottom: 8, left: 8)
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            destination.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // ── Checkpoint 8 ข้อ 1: ปุ่มบันทึก Favorite (หัวใจ) ─────────────
                  Positioned(
                    top: 8,
                    right: 8,
                    child: ListenableBuilder(
                      listenable: SavedDestinationsManager.instance,
                      builder: (context, _) {
                        final isSaved = SavedDestinationsManager.instance
                            .isSaved(destination.id);
                        return GestureDetector(
                          onTap: () {
                            SavedDestinationsManager.instance
                                .toggleSave(destination.id);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color: isSaved ? Colors.pinkAccent : Colors.white,
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              // ── 4. Info Section ────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ชื่อและราคา
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${destination.price}/คืน',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // แสดงประเทศ
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          destination.country,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: destination.tags
                          .map(
                            (tag) => Chip(
                              label: Text(
                                tag,
                                style: const TextStyle(fontSize: 11),
                              ),
                              labelPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              backgroundColor: Colors.blue.shade50,
                              shape: const StadiumBorder(
                                  side: BorderSide(color: Colors.transparent)),
                              padding: EdgeInsets.zero,
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(height: 4),
                    // ── Checkpoint 3.2 ───────────────────────────────
                    // เพิ่ม Row ใหม่ใต้ Tags แสดงไอคอน Icons.bed พร้อมข้อความ "พร้อมเข้าพัก"
                    // โดยครอบข้อความด้วย Expanded เพื่อกันไม่ให้ล้นถ้าข้อความยาว
                    Row(
                      children: const [
                        Icon(Icons.bed, size: 16, color: Colors.green),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'พร้อมเข้าพัก',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
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

