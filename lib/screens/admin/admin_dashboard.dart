import 'package:flutter/material.dart';
import 'users_screen.dart';
import 'requests_screen.dart';
import 'quotations_screen.dart';
import 'bookings_screen.dart';
import 'reviews_screen.dart';
import 'verification_screen.dart';
import 'analytics_screen.dart';
import 'reports_screen.dart';
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.25,
          children: [
            dashboardCard(
              context,
              "Users",
              Icons.people,
              Colors.blue,
              const UsersScreen(),
            ),
            dashboardCard(
              context,
              "Requests",
              Icons.assignment,
              Colors.orange,
              const RequestsScreen(),
            ),
            dashboardCard(
              context,
              "Quotations",
              Icons.request_quote,
              Colors.green,
              const QuotationsScreen(),
            ),
            dashboardCard(
              context,
              "Bookings",
              Icons.work,
              Colors.purple,
              const BookingsScreen(),
            ),
            dashboardCard(
              context,
              "Reviews",
              Icons.star,
              Colors.amber,
              const ReviewsScreen(),
            ),
            dashboardCard(
              context,
              "Verify",
              Icons.verified,
              Colors.teal,
              const VerificationScreen(),
            ),
            dashboardCard(
              context,
              "Analytics",
              Icons.analytics,
              Colors.red,
              const AnalyticsScreen(),
            ),
            dashboardCard(
              context,
              "Reports",
              Icons.bar_chart,
              Colors.indigo,
              const ReportsScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget? screen,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        if (screen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => screen,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$title module coming soon"),
            ),
          );
        }
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
}