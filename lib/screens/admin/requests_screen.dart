import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  Color statusColor(String status) {
    switch (status) {
      case "Pending":
        return Colors.orange;
      case "Accepted":
        return Colors.green;
      case "Completed":
        return Colors.blue;
      case "Cancelled":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> deleteRequest(
      BuildContext context, String id) async {
    await FirebaseFirestore.instance
        .collection("service_requests")
        .doc(id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request Deleted"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service Requests"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("service_requests")
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
                "No Requests Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {
              final request =
                  snapshot.data!.docs[index];

              final data =
                  request.data()
                      as Map<String, dynamic>;

              return Card(
                elevation: 4,
                margin:
                    const EdgeInsets.only(bottom: 12),

                child: Padding(
                  padding: const EdgeInsets.all(15),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        data["title"] ?? "",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                          "Category : ${data["category"]}"),

                      Text(
                          "Budget : ₹${data["budget"]}"),

                      Text(
                          "Location : ${data["location"]}"),

                      const SizedBox(height: 10),

                      Chip(
                        label: Text(
                          data["status"],
                        ),
                        backgroundColor:
                            statusColor(
                                    data["status"])
                                .withOpacity(.2),
                      ),

                      Align(
                        alignment:
                            Alignment.centerRight,

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
                                    "Delete Request"),
                                content: const Text(
                                    "Are you sure you want to delete this request?"),
                                actions: [

                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context);
                                    },
                                    child: const Text(
                                        "Cancel"),
                                  ),

                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(
                                          context);

                                      deleteRequest(
                                        context,
                                        request.id,
                                      );
                                    },
                                    child: const Text(
                                        "Delete"),
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