import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'payment_screen.dart';
import 'review_screen.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case "Booked":
        return Colors.orange;
      case "In Progress":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "N/A";

    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return "${date.day}/${date.month}/${date.year}";
    }

    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Bookings"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("service_requests")
            .where("customerId", isEqualTo: uid)
            .where("status", whereIn: [
              "Booked",
              "In Progress",
              "Completed"
            ])
            .orderBy("bookedAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Bookings Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final bookings = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];

              final data =
                  booking.data() as Map<String, dynamic>;

              final status =
                  data["status"] ?? "Booked";

              return Card(
                elevation: 5,
                margin:
                    const EdgeInsets.only(bottom: 18),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Row(
                        children: [

                          Expanded(
                            child: Text(
                              data["title"] ?? "",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          Chip(
                            backgroundColor:
                                getStatusColor(status),
                            label: Text(
                              status,
                              style:
                                  const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(
                            Icons.category,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data["category"] ?? "",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data["location"] ?? "",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Text(
                        data["description"] ?? "",
                      ),

                      const Divider(height: 25),

                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data["selectedSellerEmail"] ??
                                  "",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${data["selectedPrice"]}",
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data["selectedEstimatedTime"] ??
                                "",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatTimestamp(
                              data["bookedAt"],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [

                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.chat,
                              ),
                              label:
                                  const Text("Chat"),
                             onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        bookingId: booking.id,
        customerId: uid,
        sellerId: data["selectedSellerId"],
        sellerEmail: data["selectedSellerEmail"],
      ),
    ),
  );
},
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.payment,
                              ),
                              label:
                                  const Text("Pay"),
                             onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PaymentScreen(
        bookingId: booking.id,
        amount: (data["selectedPrice"] ?? 0).toDouble(),
        sellerEmail: data["selectedSellerEmail"] ?? "",
      ),
    ),
  );
},
                            ),
                          ),
                        ],
                      ),

                      if (status == "Completed") ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(
                              Icons.star,
                            ),
                            label: const Text(
                              "Give Review",
                            ),
                           onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ReviewScreen(
        bookingId: booking.id,
        sellerId: data["selectedSellerId"],
        customerId: uid,
      ),
    ),
  );
},
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}