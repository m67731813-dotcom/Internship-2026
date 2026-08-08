import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  Future<void> deleteReview(
      BuildContext context,
      String reviewId,
  ) async {
    await FirebaseFirestore.instance
        .collection("reviews")
        .doc(reviewId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Review deleted successfully"),
      ),
    );
  }

  Widget buildStars(num rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating
              ? Icons.star
              : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Management"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("reviews")
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
                "No Reviews Found",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final review =
                  snapshot.data!.docs[index];

              final data =
                  review.data() as Map<String, dynamic>;

              final rating =
                  data["rating"] ?? 0;

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
                        data["customerName"] ??
                            "Customer",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      buildStars(rating),

                      const SizedBox(height: 10),

                      Text(
                        data["comment"] ??
                            "No Comment",
                      ),

                      const SizedBox(height: 12),

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
                                    "Delete Review"),
                                content: const Text(
                                    "Delete this review?"),

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

                                      deleteReview(
                                        context,
                                        review.id,
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