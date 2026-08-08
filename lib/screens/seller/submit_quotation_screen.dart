import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SubmitQuotationScreen extends StatefulWidget {
  final String requestId;
  final Map<String, dynamic> requestData;

  const SubmitQuotationScreen({
    super.key,
    required this.requestId,
    required this.requestData,
  });

  @override
  State<SubmitQuotationScreen> createState() =>
      _SubmitQuotationScreenState();
}

class _SubmitQuotationScreenState
    extends State<SubmitQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  final priceController = TextEditingController();
  final timeController = TextEditingController();
  final warrantyController = TextEditingController();
  final messageController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    priceController.dispose();
    timeController.dispose();
    warrantyController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> submitQuotation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      final seller = FirebaseAuth.instance.currentUser!;

      /// Check whether this seller has already submitted
      /// a quotation for this request.
      final existingQuotation = await FirebaseFirestore.instance
          .collection("quotations")
          .where("requestId", isEqualTo: widget.requestId)
          .where("sellerId", isEqualTo: seller.uid)
          .get();

      if (existingQuotation.docs.isNotEmpty) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.orange,
            content: Text(
              "You have already submitted a quotation for this request.",
            ),
          ),
        );

        setState(() {
          loading = false;
        });

        return;
      }

      await FirebaseFirestore.instance
          .collection("quotations")
          .add({
        "requestId": widget.requestId,
        "requestTitle": widget.requestData["title"] ?? "",
        "category": widget.requestData["category"] ?? "",
        "customerId": widget.requestData["customerId"] ?? "",
        "sellerId": seller.uid,
        "sellerEmail": seller.email,
        "price": double.parse(priceController.text),
        "estimatedTime": timeController.text.trim(),
        "warranty": warrantyController.text.trim(),
        "message": messageController.text.trim(),
        "status": "Pending",
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Quotation submitted successfully.",
          ),
        ),
      );

      Navigator.pop(context);
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
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Quotation"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Quotation Price",
                  prefixIcon: Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter quotation price";
                  }

                  if (double.tryParse(value.trim()) == null) {
                    return "Enter a valid price";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: timeController,
                decoration: const InputDecoration(
                  labelText: "Estimated Completion Time",
                  prefixIcon: Icon(Icons.schedule),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? "Enter estimated time"
                        : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: warrantyController,
                decoration: const InputDecoration(
                  labelText: "Warranty",
                  prefixIcon: Icon(Icons.verified),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? "Enter warranty details"
                        : null,
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Message to Customer",
                  prefixIcon: Icon(Icons.message),
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? "Enter a message"
                        : null,
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    loading
                        ? "Submitting..."
                        : "Submit Quotation",
                  ),
                  onPressed:
                      loading ? null : submitQuotation,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}