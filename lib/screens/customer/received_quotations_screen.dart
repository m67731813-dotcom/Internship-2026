import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'compare_quotations_screen.dart';

class ReceivedQuotationsScreen extends StatelessWidget {
  const ReceivedQuotationsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Received Quotations"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("service_requests")
            .where("customerId", isEqualTo: uid)
            .snapshots(),

        builder: (context, requestSnapshot) {

          if (requestSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!requestSnapshot.hasData ||
              requestSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No Requests Found"),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: requestSnapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final request =
                  requestSnapshot.data!.docs[index];

              final data =
                  request.data()
                      as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        data["title"] ?? "",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(data["category"] ?? ""),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(

                          icon: const Icon(Icons.compare),

                          label: const Text(
                            "Compare Quotations",
                          ),

                          onPressed: () {

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CompareQuotationsScreen(
                                  requestId: request.id,
                                ),
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