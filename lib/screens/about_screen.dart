import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เกี่ยวกับ'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.travel_explore,
                  size: 64,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Travel App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'เวอร์ชัน 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              const Text(
                'แอปพลิเคชันแนะนำสถานที่ท่องเที่ยว พัฒนาด้วย Flutter & Go Router ตามมาตรฐาน Material Design 3',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

