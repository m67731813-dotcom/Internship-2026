import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;
  final String sellerEmail;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.sellerEmail,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {

  bool loading = false;

  Future<void> makePayment() async {

    setState(() {
      loading = true;
    });

    try {

      await Future.delayed(
        const Duration(seconds: 2),
      );

      await FirebaseFirestore.instance
          .collection("service_requests")
          .doc(widget.bookingId)
          .update({

        "paymentStatus": "Paid",

        "paymentAmount": widget.amount,

        "paymentDate": FieldValue.serverTimestamp(),

      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          backgroundColor: Colors.green,

          content: Text(
            "Payment Successful",
          ),

        ),

      );

      Navigator.pop(context);

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
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

  Widget infoTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Card(

      child: ListTile(

        leading: Icon(icon),

        title: Text(title),

        subtitle: Text(value),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Payment"),

        centerTitle: true,

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            const SizedBox(height: 10),

            const CircleAvatar(

              radius: 45,

              child: Icon(
                Icons.payment,
                size: 45,
              ),

            ),

            const SizedBox(height: 25),

            infoTile(

              Icons.person,

              "Seller",

              widget.sellerEmail,

            ),

            infoTile(

              Icons.currency_rupee,

              "Amount",

              "₹${widget.amount.toStringAsFixed(2)}",

            ),

            infoTile(

              Icons.check_circle,

              "Status",

              "Pending",

            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              height: 55,

              child: ElevatedButton.icon(

                icon: loading

                    ? const SizedBox(

                        height: 22,

                        width: 22,

                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )

                    : const Icon(Icons.lock),

                label: Text(

                  loading

                      ? "Processing..."

                      : "Pay Now",

                ),

                onPressed:

                    loading

                        ? null

                        : makePayment,

              ),

            )
          ],
        ),
      ),
    );
  }
}