import 'package:flutter/material.dart';
import 'bookings_screen.dart';
import 'compare_quotations_screen.dart';
import 'my_requests_screen.dart';
import 'post_request_screen.dart';
import 'profile_screen.dart';
import 'received_quotations_screen.dart';

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  Widget dashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return SizedBox(
      width: 220,
      height: 160,
      child: Card(
        elevation: 5,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => screen,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: color,
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
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
        title: const Text("Customer Dashboard"),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.indigo,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    child: Icon(
                      Icons.person,
                      size: 35,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Welcome",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    "Customer",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [

              dashboardCard(
                context,
                title: "Post Request",
                icon: Icons.add_business,
                color: Colors.blue,
                screen: const PostRequestScreen(),
              ),

              dashboardCard(
                context,
                title: "My Requests",
                icon: Icons.assignment,
                color: Colors.orange,
                screen: const MyRequestsScreen(),
              ),

              dashboardCard(
                context,
                title: "Quotations",
                icon: Icons.request_quote,
                color: Colors.green,
                screen: const ReceivedQuotationsScreen(),
              ),
                            dashboardCard(
                context,
                title: "Compare",
                icon: Icons.compare_arrows,
                color: Colors.purple,
                screen: const CompareQuotationsScreen(
                  requestId: "",
                ),
              ),

              dashboardCard(
                context,
                title: "Chat",
                icon: Icons.chat,
                color: Colors.deepPurple,
                screen: const Scaffold(
                  body: Center(
                    child: Text(
                      "Open Chat from My Bookings",
                    ),
                  ),
                ),
              ),

              dashboardCard(
                context,
                title: "Bookings",
                icon: Icons.calendar_month,
                color: Colors.red,
                screen: const BookingsScreen(),
              ),

              dashboardCard(
                context,
                title: "Payments",
                icon: Icons.payment,
                color: Colors.brown,
                screen: const Scaffold(
                  body: Center(
                    child: Text(
                      "Open Payment from My Bookings",
                    ),
                  ),
                ),
              ),

              dashboardCard(
                context,
                title: "Profile",
                icon: Icons.person,
                color: Colors.indigo,
                screen: const ProfileScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
