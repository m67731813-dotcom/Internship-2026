import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'submit_quotation_screen.dart';

class AvailableRequestsScreen extends StatelessWidget {
  const AvailableRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Available Requests"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("service_requests")
            .where("status", isEqualTo: "Pending")
            .orderBy("createdAt", descending: true)
            .snapshots(),

        builder: (context, snapshot) {

          if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error.toString()),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No Requests Available",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final request = snapshot.data!.docs[index];

              final data = request.data() as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      Text(
                        data["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Chip(
                        label: Text(data["category"] ?? ""),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        data["description"] ?? "",
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          const Icon(Icons.currency_rupee),

                          Text(
                            "${data["budget"]}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          const Icon(Icons.location_on),

                          Expanded(
                            child: Text(
                              data["location"] ?? "",
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.price_change),

                          label: const Text("Submit Quotation"),

                          onPressed: () {

                            Navigator.push(
                              context,

                              MaterialPageRoute(

                                builder: (_) =>
                                    SubmitQuotationScreen(
                                      requestId: request.id,
                                      requestData: data,
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