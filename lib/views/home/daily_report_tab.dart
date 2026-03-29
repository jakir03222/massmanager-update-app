import 'package:flutter/material.dart';
import '../../controllers/mess_controller.dart';

class DailyReportTab extends StatelessWidget {
  final MessController messController;
  const DailyReportTab({super.key, required this.messController});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: messController,
      builder: (context, _) {
        final members = messController.members;
        final meals = messController.meals;
        final bazars = messController.bazars;

        num totalMeals = 0;
        for (var m in meals) {
          totalMeals += m.mealCount;
        }

        num totalBazar = 0;
        for (var b in bazars) {
          totalBazar += b.amount;
        }

        double mealRate = totalMeals > 0 ? totalBazar / totalMeals : 0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Mess Report'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Summary Card
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text('Overall Summary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Meals:', style: TextStyle(fontSize: 16)),
                            Text('$totalMeals', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Bazar:', style: TextStyle(fontSize: 16)),
                            Text('৳$totalBazar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Meal Rate:', style: TextStyle(fontSize: 16)),
                            Text('৳${mealRate.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Member-wise Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Expanded(
                  child: members.isEmpty
                      ? const Center(child: Text('No members found.'))
                      : ListView.builder(
                          itemCount: members.length,
                          itemBuilder: (context, index) {
                            final member = members[index];
                            
                            // Calculate member specific data
                            num memberMeals = 0;
                            for (var m in meals.where((m) => m.memberName == member.name)) {
                              memberMeals += m.mealCount;
                            }
                            
                            num memberPaid = 0;
                            for (var b in bazars.where((b) => b.buyerName == member.name)) {
                              memberPaid += b.amount;
                            }
                            
                            double memberCost = memberMeals * mealRate;
                            double balance = memberPaid - memberCost;

                            bool isPositive = balance >= 0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(member.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Meals: $memberMeals'),
                                        Text('Cost: ৳${memberCost.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Paid: ৳$memberPaid'),
                                        Text(
                                          'Balance: ${isPositive ? "+" : ""}৳${balance.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isPositive ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      isPositive ? '(Will receive)' : '(Needs to pay)',
                                      style: TextStyle(fontSize: 12, color: isPositive ? Colors.green : Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
