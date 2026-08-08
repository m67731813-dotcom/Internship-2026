import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyQuotationsScreen extends StatelessWidget {
  const MyQuotationsScreen({super.key});

  Color getStatusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Quotations"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("quotations")
            .where("sellerId", isEqualTo: uid)
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
                "No Quotations Submitted",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {

              final quotation =
                  snapshot.data!.docs[index];

              final data =
                  quotation.data() as Map<String, dynamic>;

              return Card(
                margin:
                    const EdgeInsets.only(bottom: 15),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        data["requestTitle"] ??
                            "Service Request",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Price : ₹${data["price"]}",
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Estimated Time : ${data["estimatedTime"]}",
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "Warranty : ${data["warranty"]}",
                      ),

                      const SizedBox(height: 12),

                      Align(
                        alignment:
                            Alignment.centerRight,
                        child: Chip(
                          backgroundColor:
                              getStatusColor(
                                  data["status"]),
                          label: Text(
                            data["status"],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
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