import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/destination.dart';
import '../widgets/destination_card.dart';
import 'destination_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _searchQuery = ''; // เก็บคำค้นหาปัจจุบัน อัปเดตทุกครั้งที่พิมพ์ใน TextField
  // ── การทดลองที่ 7.1: Category Filter ────────────────────────────────────
  String _selectedTag = 'ทั้งหมด';
  final List<String> _allTags = [
    'ทั้งหมด',
    'ทะเล',
    'ธรรมชาติ',
    'วัฒนธรรม',
    'อาหาร',
    'ช้อปปิ้ง',
    'วัด',
    'ดำน้ำ',
  ];

  // Getter คำนวณรายการที่ตรงกับทั้งคำค้นหาและ Category Tag ที่เลือก
  List<Destination> get _filteredDestinations {
    return sampleDestinations.where((d) {
      final matchesQuery = _searchQuery.isEmpty ||
          d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.country.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      final matchesTag =
          _selectedTag == 'ทั้งหมด' || d.tags.contains(_selectedTag);

      return matchesQuery && matchesTag;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สำรวจ'),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // ── Search Bar ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              // ทุกครั้งที่พิมพ์ จะเรียก setState เพื่อบันทึกคำค้นหาใหม่
              // แล้วสั่งให้ build() ทำงานใหม่ ซึ่งจะไปเรียก _filteredDestinations ที่กรองด้วยค่าล่าสุด
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'ค้นหา Destination...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── การทดลองที่ 7.1: Category Filter Chips ────────────────────────
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _allTags.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final tag = _allTags[index];
                final isSelected = tag == _selectedTag;
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedTag = tag),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // ── Grid หรือ Empty State ────────────────────────────────
          Expanded(
            child: _filteredDestinations.isEmpty
                ? _buildEmptyState()
                : _buildGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    // ── LayoutBuilder: ปรับ Column Count ตามมาตรฐาน M3 Window Size Classes ──
    return LayoutBuilder(
      builder: (context, constraints) {
        // ── Checkpoint 4.1 ข้อ 2: ดึงค่า screenWidth จาก MediaQuery เทียบกับ constraints.maxWidth ──
        final screenWidth = MediaQuery.of(context).size.width;
        debugPrint(
          'MediaQuery width: $screenWidth, LayoutBuilder maxWidth: ${constraints.maxWidth}',
        );

        // ── Checkpoint 4.1 ข้อ 3: สรุปความแตกต่างระหว่าง MediaQuery และ LayoutBuilder ──
        // 1. MediaQuery.of(context).size.width คือขนาดความกว้าง "ทั้งหมดของหน้าจอ/Window" ของอุปกรณ์ (Global Screen Width)
        //    โดยไม่คำนึงถึงว่า Widget นั้นถูกวางอยู่ใน Widget Parent ขนาดเท่าใด หรือมี Padding/Sidebar/Drawer หรือไม่
        // 2. constraints.maxWidth ของ LayoutBuilder คือขนาดความกว้าง "สูงสุดที่ Widget นั้นได้รับจริงจาก Parent" (Local Width)
        //    ซึ่งหากมี Padding, NavigationRail, หรือ Split-view constraints.maxWidth จะน้อยกว่าความกว้างจอเสมอ
        // 3. หลักการเลือกใช้:
        //    - เลือกใช้ MediaQuery เมื่อต้องการจัดการภาพรวมระดับ App/Screen (เช่น สลับ BottomBar กับ NavigationRail)
        //    - เลือกใช้ LayoutBuilder เมื่อต้องการให้ Widget ย่อยปรับเปลี่ยน Layout ตามพื้นที่ที่ตัวเองได้รับจริง (Component-level Responsive)

        // ── Checkpoint 4.1 ข้อ 1: เพิ่ม Breakpoint ระดับที่ 4 คือ Large (≥ 1200 dp) ให้ crossAxisCount = 5 ──
        int crossAxisCount;
        if (constraints.maxWidth < 600) {
          crossAxisCount = 2; // Compact: Phone
        } else if (constraints.maxWidth < 840) {
          crossAxisCount = 3; // Medium: Tablet Portrait
        } else if (constraints.maxWidth < 1200) {
          crossAxisCount = 4; // Expanded: Tablet Landscape / Desktop
        } else {
          crossAxisCount = 5; // Large: Desktop Large Screen (≥ 1200 dp)
        }

        return Column(
          children: [
            // Checkpoint 4.1 ข้อ 2: แสดงค่าเปรียบเทียบบนหน้าจอชั่วคราว
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Screen Width: ${screenWidth.toStringAsFixed(1)} dp | '
                      'Max Width: ${constraints.maxWidth.toStringAsFixed(1)} dp | '
                      'Columns: $crossAxisCount',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.72, // สัดส่วน Card width/height
                ),
                itemCount: _filteredDestinations.length,
                itemBuilder: (context, index) {
                  final destination = _filteredDestinations[index];
                  return DestinationCard(
                    destination: destination,
                    onTap: () {
                      // เรียกใช้ Named Route แบบมี Type-safe parameters
                      if (GoRouter.maybeOf(context) != null) {
                        context.pushNamed(
                          'destination-detail',
                          pathParameters: {'id': destination.id},
                          extra: destination,
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DestinationDetailScreen(
                              destination: destination,
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'ไม่พบ Destination ที่ค้นหา',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '"$_searchQuery"',
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

