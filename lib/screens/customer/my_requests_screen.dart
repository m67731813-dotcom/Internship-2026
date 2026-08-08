import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyRequestsScreen extends StatelessWidget {
  const MyRequestsScreen({super.key});

  Color getStatusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Requests"),
        centerTitle: true,
      ),

      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection("service_requests")
      .snapshots(),
  builder: (context, snapshot) {

    if (snapshot.hasError) {
      return Center(
        child: Text(
          "Error: ${snapshot.error}",
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    print("Number of documents: ${snapshot.data?.docs.length}");

    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Text("No Service Requests Found"),
      );
    }

    return ListView.builder(
      itemCount: snapshot.data!.docs.length,
      itemBuilder: (context, index) {

        final data = snapshot.data!.docs[index];

        print(data.data());

        return Card(
          child: ListTile(
            title: Text(data["title"].toString()),
            subtitle: Text(data["category"].toString()),
          ),
        );
      },
    );
  },
),
    );
  }
}