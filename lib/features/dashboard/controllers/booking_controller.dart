import 'package:get/get.dart';

class BookingController extends GetxController {
  var totalAmount = 0.obs;

  void updateTotalAmount(int amount) {
    print("Controller updating totalAmount to: $amount"); // Debugging
    totalAmount.value = amount; // ✅ Correct way to update Observable
  }
}
