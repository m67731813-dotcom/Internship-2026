import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PostRequestScreen extends StatefulWidget {
  const PostRequestScreen({super.key});

  @override
  State<PostRequestScreen> createState() => _PostRequestScreenState();
}

class _PostRequestScreenState extends State<PostRequestScreen> {

  final _formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final budgetController = TextEditingController();
  final locationController = TextEditingController();

  bool loading = false;

  String category = "Plumbing";

  final List<String> categories = [
    "Plumbing",
    "Electrical",
    "Cleaning",
    "Painting",
    "Carpentry",
    "AC Repair",
    "Computer Repair",
    "Home Appliance",
    "Gardening",
    "Pest Control",
    "Other"
  ];

  Future<void> submitRequest() async {

    if (!_formKey.currentState!.validate()) return;

    try {

      setState(() {
        loading = true;
      });

      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance
          .collection("service_requests")
          .add({

        "customerId": uid,

        "title": titleController.text.trim(),

        "category": category,

        "description": descriptionController.text.trim(),

        "budget": double.parse(
          budgetController.text.trim(),
        ),

        "location": locationController.text.trim(),

        "status": "Pending",

        "createdAt": Timestamp.now(),
      });

      Fluttertoast.showToast(
        msg: "Service Request Posted Successfully",
      );

      if (!mounted) return;

      Navigator.pop(context);

    } catch (e) {

      Fluttertoast.showToast(
        msg: e.toString(),
      );

    }

    setState(() {
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Post Service Request"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              DropdownButtonFormField<String>(

                value: category,

                decoration: const InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),

                items: categories.map((e) {

                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );

                }).toList(),

                onChanged: (value) {

                  setState(() {
                    category = value!;
                  });

                },
              ),

              const SizedBox(height: 20),

              TextFormField(

                controller: titleController,

                decoration: const InputDecoration(
                  labelText: "Service Title",
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                    value!.isEmpty ? "Enter title" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(

                controller: descriptionController,

                maxLines: 4,

                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                    value!.isEmpty ? "Enter description" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(

                controller: budgetController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: "Budget",
                  prefixText: "\$ ",
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                    value!.isEmpty ? "Enter budget" : null,
              ),

              const SizedBox(height: 20),

              TextFormField(

                controller: locationController,

                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),

                validator: (value) =>
                    value!.isEmpty ? "Enter location" : null,
              ),

              const SizedBox(height: 30),

              SizedBox(

                width: double.infinity,
                height: 55,

                child: ElevatedButton(

                  onPressed: loading ? null : submitRequest,

                  child: loading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          "POST REQUEST",
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}