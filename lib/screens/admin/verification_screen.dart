import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  Future<void> updateStatus(
    BuildContext context,
    String userId,
    bool verified,
  ) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .update({
      "verified": verified,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          verified
              ? "Seller Approved"
              : "Seller Rejected",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Seller Verification"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("users")
            .where("role", isEqualTo: "Seller")
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
                "No Sellers Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final seller =
                  snapshot.data!.docs[index];

              final data =
                  seller.data()
                      as Map<String, dynamic>;

              final verified =
                  data["verified"] ?? false;

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
                        data["name"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        data["email"] ?? "",
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          Chip(
                            backgroundColor: verified
                                ? Colors.green.shade100
                                : Colors.orange.shade100,

                            label: Text(
                              verified
                                  ? "Verified"
                                  : "Pending",
                            ),
                          ),

                          const Spacer(),

                          ElevatedButton.icon(
                            onPressed: () {
                              updateStatus(
                                context,
                                seller.id,
                                true,
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text("Approve"),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () {
                              updateStatus(
                                context,
                                seller.id,
                                false,
                              );
                            },
                            icon: const Icon(Icons.close),
                            label: const Text("Reject"),
                          ),
                        ],
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