import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class QuotationsScreen extends StatelessWidget {
  const QuotationsScreen({super.key});

  Future<void> deleteQuotation(
      BuildContext context, String id) async {
    await FirebaseFirestore.instance
        .collection("quotations")
        .doc(id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Quotation Deleted Successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quotation Management"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("quotations")
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
                "No Quotations Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final quote = snapshot.data!.docs[index];
              final data =
                  quote.data() as Map<String, dynamic>;

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
                        data["requestTitle"] ?? "Service Request",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Category : ${data["category"] ?? ""}",
                      ),

                      Text(
                        "Price : ₹${data["price"] ?? 0}",
                      ),

                      Text(
                        "Estimated Time : ${data["estimatedTime"] ?? ""}",
                      ),

                      Text(
                        "Warranty : ${data["warranty"] ?? ""}",
                      ),

                      const SizedBox(height: 10),

                      Text(
                        data["message"] ?? "",
                      ),

                      const SizedBox(height: 12),

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
                              builder: (_) => AlertDialog(
                                title: const Text("Delete Quotation"),
                                content: const Text(
                                  "Are you sure you want to delete this quotation?",
                                ),
                                actions: [

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {

                                      Navigator.pop(context);

                                      deleteQuotation(
                                        context,
                                        quote.id,
                                      );

                                    },
                                    child: const Text("Delete"),
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