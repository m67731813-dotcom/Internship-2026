import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewScreen extends StatefulWidget {

  final String bookingId;
  final String sellerId;
  final String customerId;

  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.sellerId,
    required this.customerId,
  });

  @override
  State<ReviewScreen> createState() =>
      _ReviewScreenState();
}

class _ReviewScreenState
    extends State<ReviewScreen> {

  final reviewController =
      TextEditingController();

  double rating = 5;

  Future<void> submitReview() async {

    await FirebaseFirestore.instance
        .collection("reviews")
        .add({

      "bookingId": widget.bookingId,

      "sellerId": widget.sellerId,

      "customerId": widget.customerId,

      "rating": rating,

      "review":
          reviewController.text.trim(),

      "createdAt":
          FieldValue.serverTimestamp(),

    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Rate Seller"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const Text(
              "Rate the Service",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (value) {

                setState(() {
                  rating = value;
                });

              },
            ),

            TextField(
              controller: reviewController,
              maxLines: 4,

              decoration:
                  const InputDecoration(

                labelText: "Review",

                border:
                    OutlineInputBorder(),

              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(

                onPressed: submitReview,

                child: const Text(
                  "Submit Review",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}