import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../models/saved_destinations.dart';
import '../widgets/destination_card.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('บันทึกไว้'),
        centerTitle: false,
      ),
      // ── Checkpoint 8 คอมเมนต์จุดที่ 1: Reactive State Subscription ──
      // ใช้ ListenableBuilder เชื่อมต่อกับ SavedDestinationsManager.instance ที่เป็น Singleton
      // เมื่อใดก็ตามที่ผู้ใช้กด Favorite จากหน้าอื่น (Explore, Detail, หรือในการ์ดเอง)
      // ListenableBuilder จะสั่ง trigger การ rebuild เฉพาะส่วนแสดงผลของหน้านี้โดยอัตโนมัติ
      // ทำให้ข้อมูลอัปเดตสอดคล้องกันตลอดเวลาโดยไม่ต้องใช้ Third-party State Library
      body: ListenableBuilder(
        listenable: SavedDestinationsManager.instance,
        builder: (context, _) {
          final savedIds = SavedDestinationsManager.instance.savedIds;
          final savedDestinations = sampleDestinations
              .where((d) => savedIds.contains(d.id))
              .toList();

          if (savedDestinations.isEmpty) {
            return _buildEmptyState();
          }

          return _buildSavedGrid(savedDestinations);
        },
      ),
    );
  }

  // ── Checkpoint 8 คอมเมนต์จุดที่ 2: Responsive Grid ตาม M3 Window Size Classes ──
  // ใช้ LayoutBuilder รับ BoxConstraints เพื่อปรับจำนวนคอลัมน์ (crossAxisCount)
  // ให้สอดคล้องกับขนาดหน้าจอจริง (Compact: 2, Medium: 3, Expanded: 4, Large: 5)
  // พร้อมใช้ childAspectRatio: 0.72 ป้องกันการบีบหรือยืดของการ์ดในแต่ละขนาดหน้าจอ
  Widget _buildSavedGrid(List<Destination> destinations) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        } else {
          crossAxisCount = 5; // Large: Large Screen
        }

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.72,
          ),
          itemCount: destinations.length,
          itemBuilder: (context, index) {
            final destination = destinations[index];
            return DestinationCard(
              destination: destination,
              // ── Checkpoint 8 คอมเมนต์จุดที่ 3: Named Route Navigation พร้อม Fallback Extra ──
              // สั่งนำทางไปยังหน้ารายละเอียดผ่าน context.pushNamed โดยส่งทั้ง pathParameters สำหรับ Deep Link/Web
              // และส่ง Object เต็มผ่าน extra เพื่อให้หน้า Detail นำไป Render ได้ทันทีแบบ Zero-latency
              onTap: () {
                context.pushNamed(
                  'destination-detail',
                  pathParameters: {'id': destination.id},
                  extra: destination,
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 72, color: Colors.pink.shade200),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีรายการที่บันทึก',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'กดไอคอนหัวใจที่สถานที่ท่องเที่ยวที่ชื่นชอบ\nเพื่อบันทึกไว้ดูภายหลัง',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
