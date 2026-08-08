import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sellerId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Earnings"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("sellerId", isEqualTo: sellerId)
            .where("status", isEqualTo: "Completed")
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
              snapshot.data!.docs.isNotEmpty == false) {

            return const Center(
              child: Text(
                "No Earnings Yet",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          double total = 0;

          for (var doc in snapshot.data!.docs) {

            final data =
                doc.data() as Map<String, dynamic>;

            total +=
                (data["price"] as num).toDouble();
          }

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                Card(
                  elevation: 5,

                  child: Padding(
                    padding: const EdgeInsets.all(20),

                    child: Column(

                      children: [

                        const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.green,
                          size: 60,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          "Total Earnings",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          "₹${total.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: ListView.builder(
                    itemCount:
                        snapshot.data!.docs.length,

                    itemBuilder: (context, index) {

                      final booking =
                          snapshot.data!.docs[index];

                      final data =
                          booking.data()
                              as Map<String, dynamic>;

                      return Card(

                        margin:
                            const EdgeInsets.only(
                                bottom: 12),

                        child: ListTile(

                          leading: const CircleAvatar(
                            child: Icon(Icons.work),
                          ),

                          title: Text(
                            data["requestTitle"] ??
                                "Service Request",
                          ),

                          subtitle: const Text(
                              "Completed"),

                          trailing: Text(
                            "₹${data["price"]}",
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}