import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/subscription_controller.dart';

class SubscriptionPage extends StatelessWidget {
  final controller = Get.put(SubscriptionController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Subscription")),
      body: Obx(() {
        if (!controller.isAvailable.value) {
          return Center(child: Text("Store not available"));
        }

        if (controller.products.isEmpty) {
          return Center(child: Text("No subscription found"));
        }

        final product = controller.products.first;

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(product.title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(product.description),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: () => controller.buy(product),
                child: Text("Subscribe Now (${product.price})"),
              ),

              TextButton(
                onPressed: () => controller.restore(),
                child: Text("Restore Purchase"),
              )
            ],
          ),
        );
      }),
    );
  }
}
