import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ActiveJobsScreen extends StatelessWidget {
  const ActiveJobsScreen({super.key});

  Future<void> completeJob(
      BuildContext context,
      String bookingId) async {

    try {

      await FirebaseFirestore.instance
          .collection("bookings")
          .doc(bookingId)
          .update({
        "status": "Completed",
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Job marked as Completed"),
        ),
      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

    }
  }

  @override
  Widget build(BuildContext context) {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(

      appBar: AppBar(
        title: const Text("Active Jobs"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection("bookings")
            .where("sellerId", isEqualTo: uid)
            .where("status", isEqualTo: "Active")
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
                "No Active Jobs",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(

            padding: const EdgeInsets.all(15),

            itemCount: snapshot.data!.docs.length,

            itemBuilder: (context, index) {

              final booking =
                  snapshot.data!.docs[index];

              final data =
                  booking.data() as Map<String, dynamic>;

              return Card(

                elevation: 5,

                margin:
                    const EdgeInsets.only(bottom: 15),

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
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Price : ₹${data["price"]}",
                      ),

                      const SizedBox(height: 10),

                      Text(
                        "Status : ${data["status"]}",
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(

                          icon:
                              const Icon(Icons.check),

                          label: const Text(
                            "Mark Completed",
                          ),

                          onPressed: () {

                            completeJob(
                              context,
                              booking.id,
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