import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  Color statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.blue;
      case "Completed":
        return Colors.green;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> deleteBooking(
      BuildContext context,
      String bookingId,
  ) async {
    await FirebaseFirestore.instance
        .collection("bookings")
        .doc(bookingId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Booking deleted successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking Management"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .orderBy("createdAt", descending: true)
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

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final booking =
                  snapshot.data!.docs[index];

              final data =
                  booking.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 12),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        data["requestTitle"] ?? "Service",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                          "Customer : ${data["customerName"] ?? ""}"),

                      Text(
                          "Seller : ${data["sellerName"] ?? ""}"),

                      Text(
                          "Price : ₹${data["price"] ?? ""}"),

                      Text(
                          "Booking Date : ${data["bookingDate"] ?? ""}"),

                      const SizedBox(height: 10),

                      Chip(
                        label: Text(
                          data["status"] ?? "",
                        ),
                        backgroundColor: statusColor(
                                data["status"] ?? "")
                            .withOpacity(.2),
                      ),

                      Align(
                        alignment: Alignment.centerRight,

                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          onPressed: () {

                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AlertDialog(
                                title: const Text(
                                    "Delete Booking"),
                                content: const Text(
                                    "Delete this booking?"),
                                actions: [

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context);
                                    },
                                    child:
                                        const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {

                                      Navigator.pop(
                                          context);

                                      deleteBooking(
                                        context,
                                        booking.id,
                                      );

                                    },
                                    child:
                                        const Text("Delete"),
                                  ),

                                ],
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
        },
      ),
    );
  }
}