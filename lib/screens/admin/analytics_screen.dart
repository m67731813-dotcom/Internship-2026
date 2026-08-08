import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {

  int totalUsers = 0;
  int totalCustomers = 0;
  int totalSellers = 0;
  int totalRequests = 0;
  int totalQuotations = 0;
  int totalBookings = 0;
  int totalReviews = 0;

  @override
  void initState() {
    super.initState();
    loadAnalytics();
  }

  Future<void> loadAnalytics() async {

    final users =
        await FirebaseFirestore.instance
            .collection("users")
            .get();

    final requests =
        await FirebaseFirestore.instance
            .collection("service_requests")
            .get();

    final quotations =
        await FirebaseFirestore.instance
            .collection("quotations")
            .get();

    final bookings =
        await FirebaseFirestore.instance
            .collection("bookings")
            .get();

    final reviews =
        await FirebaseFirestore.instance
            .collection("reviews")
            .get();

    setState(() {

      totalUsers = users.docs.length;

      totalCustomers = users.docs
          .where((e) => e["role"] == "Customer")
          .length;

      totalSellers = users.docs
          .where((e) => e["role"] == "Seller")
          .length;

      totalRequests = requests.docs.length;

      totalQuotations = quotations.docs.length;

      totalBookings = bookings.docs.length;

      totalReviews = reviews.docs.length;

    });
  }

  Widget analyticsCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            CircleAvatar(
              radius: 22,
              backgroundColor: color,

              child: Icon(
                icon,
                color: Colors.white,
                size: 22,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),

          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Analytics"),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: GridView.count(

          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.15,

          children: [

            analyticsCard(
              "Users",
              totalUsers.toString(),
              Icons.people,
              Colors.blue,
            ),

            analyticsCard(
              "Customers",
              totalCustomers.toString(),
              Icons.person,
              Colors.green,
            ),

            analyticsCard(
              "Sellers",
              totalSellers.toString(),
              Icons.store,
              Colors.orange,
            ),

            analyticsCard(
              "Requests",
              totalRequests.toString(),
              Icons.assignment,
              Colors.red,
            ),

            analyticsCard(
              "Quotations",
              totalQuotations.toString(),
              Icons.request_quote,
              Colors.teal,
            ),

            analyticsCard(
              "Bookings",
              totalBookings.toString(),
              Icons.work,
              Colors.purple,
            ),

            analyticsCard(
              "Reviews",
              totalReviews.toString(),
              Icons.star,
              Colors.amber,
            ),

          ],
        ),
      ),
    );
  }
}