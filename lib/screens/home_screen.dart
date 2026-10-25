import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_screen.dart';
import 'explore_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Checkpoint 4.3 ข้อ 1: แสดง sampleDestinations ทั้งหมดในแนวนอน (แทนการใช้ take(3)) ──
    final featured = sampleDestinations;

    // ── Checkpoint 4.3 ข้อ 2: Logic การ Sort หา Destination 3 อันดับแรกที่มี rating สูงสุด ──
    final topRatedDestinations = List<Destination>.from(sampleDestinations)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    final top3Rated = topRatedDestinations.take(3).toList();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'สวัสดี, นักเดินทาง! 👋',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                      const Text(
                        'ไปไหนดีวันนี้?',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Featured Section ────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('แนะนำสำหรับคุณ',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      if (GoRouter.maybeOf(context) != null) {
                        context.go('/explore');
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ExploreScreen(),
                          ),
                        );
                      }
                    },
                    child: const Text('ดูทั้งหมด'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ListView แนวนอน (แสดงครบทุก Destination ตาม Checkpoint 4.3 ข้อ 1)
              SizedBox(
                height: 310,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final dest = featured[index];
                    return SizedBox(
                      width: 220,
                      child: DestinationCard(
                        destination: dest,
                        onTap: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.pushNamed(
                              'destination-detail',
                              pathParameters: {'id': dest.id},
                              extra: dest,
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    DestinationDetailScreen(destination: dest),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ── Quick Stats ─────────────────────────────────────
              const Text('สถิติการเดินทาง',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                        icon: Icons.flight,
                        label: 'Trip',
                        value: '5',
                        color: Colors.blue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.place,
                        label: 'Country',
                        value: '3',
                        color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                        icon: Icons.favorite,
                        label: 'Saved',
                        value: '12',
                        color: Colors.pink),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Checkpoint 4.3 ข้อ 2 & 3: Section รีวิวยอดนิยม ───────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'รีวิวยอดนิยม',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Top 3 Rating ⭐',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.amber.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Checkpoint 4.3 ข้อ 3: Comment อธิบาย shrinkWrap และ physics ──
              // ทำไมต้องใส่ shrinkWrap: true และ NeverScrollableScrollPhysics() ใน ListView ที่ซ้อนใน Column ของ SingleChildScrollView:
              // 1. shrinkWrap: true:
              //    โดยปกติ ListView จะพยายามขยายความสูงของตัวเองให้เต็มพื้นที่ไม่จำกัด (infinite vertical height)
              //    แต่เนื่องจาก Column ที่อยู่ใต้ SingleChildScrollView ไม่มีข้อจำกัดด้านความสูง (Unbounded height constraints)
              //    หากไม่ใส่ shrinkWrap: true ตัว Flutter จะโยนข้อผิดพลาด:
              //    "Vertical viewport was given unbounded height." ทันที
              //    การตั้งค่า shrinkWrap: true จะสั่งให้ ListView คำนวณความสูงเท่ากับขนาดรวมของ Children ที่แท้จริงเท่านั้น
              // 2. physics: const NeverScrollableScrollPhysics():
              //    ปิดการตรวจจับ Gesture การ Scroll ของตัว ListView เอง เพื่อป้องกันปัญหา Scroll Conflict / Nested Scrolling Loop
              //    ระหว่าง ListView ด้านในกับ SingleChildScrollView ด้านนอก ทำให้การเลื่อนหน้าจอถูกควบคุมโดย Parent ภายนอกเพียงตัวเดียวอย่างราบรื่น
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: top3Rated.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final dest = top3Rated[index];
                  return Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 1,
                    shadowColor: Colors.black12,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            dest.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image, size: 28),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        dest.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.grey),
                          const SizedBox(width: 2),
                          Text(dest.country,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text(
                            '\$${dest.price}/คืน',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              dest.rating.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        if (GoRouter.maybeOf(context) != null) {
                          context.pushNamed(
                            'destination-detail',
                            pathParameters: {'id': dest.id},
                            extra: dest,
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  DestinationDetailScreen(destination: dest),
                            ),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// การ์ดแสดงสถิติตัวเลขเดียว (Trip / Country / Saved) — แยกเป็น Widget ของตัวเอง
// เพื่อลดการเขียนโค้ดซ้ำ 3 รอบใน Row ด้านบน (DRY: Don't Repeat Yourself)
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
