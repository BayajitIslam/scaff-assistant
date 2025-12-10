import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scaffassistant/core/const/string_const/image_path.dart';
import 'package:scaffassistant/core/theme/SColor.dart';
import '../controller/subscription_controller.dart';

class SubscriptionPage extends StatelessWidget {
  final controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SColor.primary,
      appBar: AppBar(
        backgroundColor: SColor.primary,
        title: Text("Choose a Subscription", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (!controller.isAvailable.value) {
          return Center(child: Text("Store not available"));
        }

        if (controller.products.isEmpty) {
          return Center(child: Text("No subscription found"));
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Image.asset(
                  ImagePath.logo
                ),
              ),

              SizedBox(
                height: 50,
              ),

              Expanded(
                child: ListView.separated(
                  itemCount: controller.products.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final product = controller.products[index];
                    return Card(
                      color: SColor.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.title,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              product.description,
                              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product.price,
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => controller.buy(product),
                                  child: Text("Subscribe", style: TextStyle(color: Colors.white)),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),



              SizedBox(height: 10),
              TextButton(
                onPressed: () => controller.restore(),
                child: Text(
                  "Restore Purchases",
                  style: TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
              Text('If you have already purchased a subscription, you can restore it here.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  textAlign: TextAlign.center
              ),
              Text(
                "By subscribing, you agree to our Terms of Service and Privacy Policy.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }),
    );
  }
}
