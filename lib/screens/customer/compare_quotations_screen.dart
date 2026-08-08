import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CompareQuotationsScreen extends StatefulWidget {
  final String requestId;

  const CompareQuotationsScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<CompareQuotationsScreen> createState() =>
      _CompareQuotationsScreenState();
}

class _CompareQuotationsScreenState
    extends State<CompareQuotationsScreen> {
  bool booking = false;

  Future<void> bookSeller(
      String quotationId,
      Map<String, dynamic> quotation,
      ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Booking"),
        content: const Text(
          "Do you want to book this seller?\n\nThis action cannot be changed.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Book"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      booking = true;
    });

    try {
      final requestRef = FirebaseFirestore.instance
          .collection("service_requests")
          .doc(widget.requestId);

      final requestSnapshot = await requestRef.get();

      if (!requestSnapshot.exists) {
        throw Exception("Request not found.");
      }

      final requestData =
      requestSnapshot.data() as Map<String, dynamic>;

      if (requestData["status"] == "Booked") {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "This request has already been booked."),
            ),
          );
        }

        setState(() {
          booking = false;
        });

        return;
      }

      await requestRef.update({
        "status": "Booked",
        "selectedQuotationId": quotationId,
        "selectedSellerId": quotation["sellerId"],
        "selectedSellerEmail": quotation["sellerEmail"],
        "selectedPrice": quotation["price"],
        "selectedEstimatedTime":
        quotation["estimatedTime"],
        "selectedWarranty": quotation["warranty"],
        "bookedAt": FieldValue.serverTimestamp(),
      });

      final quotations = await FirebaseFirestore.instance
          .collection("quotations")
          .where("requestId",
          isEqualTo: widget.requestId)
          .get();

      for (var doc in quotations.docs) {
        if (doc.id == quotationId) {
          await doc.reference.update({
            "status": "Accepted",
          });
        } else {
          await doc.reference.update({
            "status": "Rejected",
          });
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content:
          Text("Seller booked successfully."),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        booking = false;
      });
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Rejected":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Compare Quotations"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("quotations")
            .where("requestId",
            isEqualTo: widget.requestId)
            .orderBy("price")
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child:
              Text(snapshot.error.toString()),
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
                "No quotations received yet.",
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final quotations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: quotations.length,
            itemBuilder: (context, index) {
              final quotation = quotations[index];

              final data =
              quotation.data() as Map<String, dynamic>;

              final status =
                  data["status"] ?? "Pending";

              return Card(
                margin: const EdgeInsets.only(
                    bottom: 18),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              data["sellerEmail"] ??
                                  "",
                              style:
                              const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight
                                    .bold,
                              ),
                            ),
                          ),
                          Chip(
                            backgroundColor:
                            statusColor(
                                status),
                            label: Text(
                              status,
                              style:
                              const TextStyle(
                                color: Colors
                                    .white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      Text(
                        "Category : ${data["category"]}",
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Price : ₹${data["price"]}",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Estimated Time : ${data["estimatedTime"]}",
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "Warranty : ${data["warranty"]}",
                      ),

                      const Divider(height: 25),

                      const Text(
                        "Seller Message",
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(data["message"]),

                      const SizedBox(height: 20),

                      if (status == "Pending")
                        SizedBox(
                          width: double.infinity,
                          child:
                          ElevatedButton.icon(
                            icon: booking
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth:
                                2,
                                color: Colors
                                    .white,
                              ),
                            )
                                : const Icon(
                                Icons.check_circle),
                            label: Text(
                              booking
                                  ? "Booking..."
                                  : "Book Seller",
                            ),
                            onPressed: booking
                                ? null
                                : () => bookSeller(
                              quotation.id,
                              data,
                            ),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          child:
                          ElevatedButton(
                            onPressed: null,
                            child: Text(status),
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