import 'package:flutter/material.dart';

import 'available_requests_screen.dart';
import 'my_quotations_screen.dart';
import 'active_jobs_screen.dart';
import 'completed_jobs_screen.dart';
import 'earnings_screen.dart';
import 'reviews_screen.dart';
import 'seller_profile_screen.dart';

class SellerDashboard extends StatelessWidget {
  const SellerDashboard({super.key});

  Widget dashboardItem(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => screen),
        );
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 8,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 3, // 3 cards per row
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.25, // Smaller cards
          children: [

            dashboardItem(
              context,
              "Available\nRequests",
              Icons.assignment,
              Colors.blue,
              const AvailableRequestsScreen(),
            ),

            dashboardItem(
              context,
              "My\nQuotations",
              Icons.price_change,
              Colors.green,
              const MyQuotationsScreen(),
            ),

            dashboardItem(
              context,
              "Active\nJobs",
              Icons.handyman,
              Colors.orange,
              const ActiveJobsScreen(),
            ),

            dashboardItem(
              context,
              "Completed\nJobs",
              Icons.check_circle,
              Colors.purple,
              const CompletedJobsScreen(),
            ),

            dashboardItem(
              context,
              "Earnings",
              Icons.account_balance_wallet,
              Colors.teal,
              const EarningsScreen(),
            ),

            dashboardItem(
              context,
              "Reviews",
              Icons.star,
              Colors.amber,
              const ReviewsScreen(),
            ),

            dashboardItem(
              context,
              "Profile",
              Icons.person,
              Colors.indigo,
              const SellerProfileScreen(),
            ),
          ],
        ),
      ),
    );
  }
}