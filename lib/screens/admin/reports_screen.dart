import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {

  int users = 0;
  int requests = 0;
  int quotations = 0;
  int bookings = 0;
  int reviews = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  Future<void> loadReports() async {

    final userData =
        await FirebaseFirestore.instance
            .collection("users")
            .get();

    final requestData =
        await FirebaseFirestore.instance
            .collection("service_requests")
            .get();

    final quotationData =
        await FirebaseFirestore.instance
            .collection("quotations")
            .get();

    final bookingData =
        await FirebaseFirestore.instance
            .collection("bookings")
            .get();

    final reviewData =
        await FirebaseFirestore.instance
            .collection("reviews")
            .get();

    setState(() {

      users = userData.docs.length;
      requests = requestData.docs.length;
      quotations = quotationData.docs.length;
      bookings = bookingData.docs.length;
      reviews = reviewData.docs.length;

      loading = false;

    });
  }

  Widget reportTile(
    IconData icon,
    String title,
    int value,
    Color color,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Reports"),
        centerTitle: true,
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),

              child: Column(

                children: [

                  reportTile(
                    Icons.people,
                    "Registered Users",
                    users,
                    Colors.blue,
                  ),

                  reportTile(
                    Icons.assignment,
                    "Service Requests",
                    requests,
                    Colors.orange,
                  ),

                  reportTile(
                    Icons.request_quote,
                    "Quotations",
                    quotations,
                    Colors.green,
                  ),

                  reportTile(
                    Icons.work,
                    "Bookings",
                    bookings,
                    Colors.purple,
                  ),

                  reportTile(
                    Icons.star,
                    "Reviews",
                    reviews,
                    Colors.amber,
                  ),

                  const SizedBox(height: 25),

                  ElevatedButton.icon(
                    onPressed: () {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "PDF Export will be added later",
                          ),
                        ),
                      );

                    },

                    icon: const Icon(Icons.picture_as_pdf),

                    label: const Text(
                      "Export Report",
                    ),
                  ),

                ],
              ),
            ),
    );
  }
}