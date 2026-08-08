import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final sellerId =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Reviews"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("reviews")
            .where("sellerId", isEqualTo: sellerId)
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
                "No Reviews Yet",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          double totalRating = 0;

          for (var doc in snapshot.data!.docs) {

            final data =
                doc.data() as Map<String, dynamic>;

            totalRating +=
                (data["rating"] as num).toDouble();
          }

          double average =
              totalRating /
                  snapshot.data!.docs.length;

          return Column(

            children: [

              Container(
                width: double.infinity,
                color: Colors.indigo,

                padding:
                    const EdgeInsets.all(20),

                child: Column(

                  children: [

                    const Text(
                      "Average Rating",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      average.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 36,
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView.builder(

                  itemCount:
                      snapshot.data!.docs.length,

                  itemBuilder:
                      (context, index) {

                    final review =
                        snapshot.data!.docs[index];

                    final data =
                        review.data()
                            as Map<String, dynamic>;

                    return Card(

                      margin:
                          const EdgeInsets.all(10),

                      child: ListTile(

                        leading: CircleAvatar(
                          child: Text(
                            data["rating"]
                                .toString(),
                          ),
                        ),

                        title:
                            Text(data["review"]),

                        subtitle: Text(
                          "⭐ ${data["rating"]}",
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}