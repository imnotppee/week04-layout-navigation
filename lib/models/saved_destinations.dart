import 'package:flutter/foundation.dart';

/// Checkpoint 8 จุดที่ 1: Shared State Management ข้ามหน้าจอ
/// ใช้ Singleton ร่วมกับ ChangeNotifier เพื่อจัดการชุด ID ของสถานที่ท่องเที่ยวที่ถูกบันทึก
/// เมื่อมีการกด Favorite ไม่ว่าจะจากหน้า Explore, Home, Detail หรือ Saved
/// ทุกหน้าจอที่ subscribe อยู่จะอัปเดต UI ทันทีโดยไม่ต้องใช้ State Management Library ภายนอก
class SavedDestinationsManager extends ChangeNotifier {
  static final SavedDestinationsManager instance =
      SavedDestinationsManager._internal();

  SavedDestinationsManager._internal();

  // เก็บชุด ID ของ Destination ที่ผู้ใช้กดบันทึก
  final Set<String> _savedIds = {'1', '4'}; // ตัวอย่างเริ่มต้นที่มีการบันทึกไว้ (กรุงเทพฯ, โตเกียว)

  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  bool isSaved(String id) => _savedIds.contains(id);

  void toggleSave(String id) {
    if (_savedIds.contains(id)) {
      _savedIds.remove(id);
    } else {
      _savedIds.add(id);
    }
    notifyListeners();
  }
}

