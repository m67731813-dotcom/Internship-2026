import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth/login_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() =>
      _SellerProfileScreenState();
}

class _SellerProfileScreenState
    extends State<SellerProfileScreen> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final businessController = TextEditingController();
  final categoryController = TextEditingController();
  final experienceController = TextEditingController();
  final addressController = TextEditingController();

  bool loading = true;
  bool verified = false;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    if (doc.exists) {

      final data = doc.data()!;

      nameController.text = data["name"] ?? "";
      phoneController.text = data["phone"] ?? "";
      businessController.text =
          data["businessName"] ?? "";
      categoryController.text =
          data["serviceCategory"] ?? "";
      experienceController.text =
          data["experience"] ?? "";
      addressController.text =
          data["address"] ?? "";

      verified = data["verified"] ?? false;
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> saveProfile() async {

    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update({

      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "businessName":
          businessController.text.trim(),
      "serviceCategory":
          categoryController.text.trim(),
      "experience":
          experienceController.text.trim(),
      "address":
          addressController.text.trim(),

    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Profile Updated"),
      ),
    );
  }

  Future<void> logout() async {

    await FirebaseAuth.instance.signOut();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(role: "Seller"),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      appBar: AppBar(
        title: const Text("Seller Profile"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.indigo,
                child: Text(
                  nameController.text.isEmpty
                      ? "S"
                      : nameController.text[0]
                          .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Chip(
                backgroundColor: verified
                    ? Colors.green
                    : Colors.orange,
                label: Text(
                  verified
                      ? "Verified Seller"
                      : "Verification Pending",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Owner Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) =>
                    value!.isEmpty
                        ? "Enter Name"
                        : null,
              ),

              const SizedBox(height: 15),

              TextFormField(
                enabled: false,
                initialValue:
                    FirebaseAuth.instance.currentUser!.email,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: businessController,
                decoration: const InputDecoration(
                  labelText: "Business Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: "Service Category",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: experienceController,
                decoration: const InputDecoration(
                  labelText: "Experience",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work),
                ),
              ),

              const SizedBox(height: 15),

              TextFormField(
                controller: addressController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text(
                    "Save Profile",
                  ),
                  onPressed: saveProfile,
                ),
              ),

              const SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  onPressed: logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}