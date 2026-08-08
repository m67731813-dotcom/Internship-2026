import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  final user = FirebaseAuth.instance.currentUser!;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;

  Future<void> updateProfile() async {

    setState(() {
      loading = true;
    });

    try {

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .update({

        "name": nameController.text.trim(),

        "phone": phoneController.text.trim(),

      });

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
            "Profile Updated Successfully",
          ),

        ),

      );

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(
          content: Text(e.toString()),
        ),

      );

    }

    setState(() {
      loading = false;
    });
  }

  Future<void> logout() async {

    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("My Profile"),

        centerTitle: true,

      ),

      body: StreamBuilder<DocumentSnapshot>(

        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(user.uid)
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child: CircularProgressIndicator(),
            );

          }

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          nameController.text =
              data["name"] ?? "";

          phoneController.text =
              data["phone"] ?? "";

          return SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                CircleAvatar(

                  radius: 55,

                  backgroundColor: Colors.blue,

                  backgroundImage:
                      data["profileImage"] != null &&
                              data["profileImage"] != ""
                          ? NetworkImage(
                              data["profileImage"],
                            )
                          : null,

                  child:
                      data["profileImage"] == ""
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.white,
                            )
                          : null,
                ),

                const SizedBox(height: 25),

                TextField(

                  controller: nameController,

                  decoration:
                      const InputDecoration(

                    labelText: "Name",

                    prefixIcon:
                        Icon(Icons.person),

                    border:
                        OutlineInputBorder(),

                  ),

                ),

                const SizedBox(height: 20),

                TextField(

                  enabled: false,

                  decoration:
                      InputDecoration(

                    labelText: "Email",

                    prefixIcon:
                        const Icon(Icons.email),

                    border:
                        const OutlineInputBorder(),

                    hintText:
                        data["email"] ?? "",

                  ),

                ),

                const SizedBox(height: 20),

                TextField(

                  controller: phoneController,

                  keyboardType:
                      TextInputType.phone,

                  decoration:
                      const InputDecoration(

                    labelText: "Phone",

                    prefixIcon:
                        Icon(Icons.phone),

                    border:
                        OutlineInputBorder(),

                  ),

                ),

                const SizedBox(height: 20),

                ListTile(

                  leading:
                      const Icon(Icons.verified),

                  title:
                      const Text("Verification"),

                  subtitle: Text(

                    data["verified"] == true

                        ? "Verified"

                        : "Not Verified",

                  ),

                ),

                const SizedBox(height: 20),
                                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    icon: loading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      loading
                          ? "Updating..."
                          : "Update Profile",
                    ),
                    onPressed:
                        loading ? null : updateProfile,
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.lock_reset),
                    label: const Text(
                      "Change Password",
                    ),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance
                            .sendPasswordResetEmail(
                          email: user.email!,
                        );

                        if (!mounted) return;

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Password reset email has been sent.",
                            ),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              e.toString(),
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout"),
                    onPressed: logout,
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  "Member since",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  data["createdAt"] != null
                      ? (data["createdAt"] as Timestamp)
                          .toDate()
                          .toString()
                          .split(" ")
                          .first
                      : "",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}