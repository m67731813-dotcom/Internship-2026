import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final searchController = TextEditingController();

  String searchText = "";

  Color roleColor(String role) {
    switch (role) {
      case "Customer":
        return Colors.blue;

      case "Seller":
        return Colors.green;

      case "Admin":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  IconData roleIcon(String role) {
    switch (role) {
      case "Customer":
        return Icons.person;

      case "Seller":
        return Icons.store;

      case "Admin":
        return Icons.admin_panel_settings;

      default:
        return Icons.person_outline;
    }
  }

  Future<void> deleteUser(String id) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User deleted successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Management"),
        centerTitle: true,
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(15),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search user...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .orderBy("name")
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

                var users = snapshot.data!.docs.where((doc) {

                  final data =
                      doc.data() as Map<String, dynamic>;

                  final name =
                      (data["name"] ?? "")
                          .toString()
                          .toLowerCase();

                  final email =
                      (data["email"] ?? "")
                          .toString()
                          .toLowerCase();

                  return name.contains(searchText) ||
                      email.contains(searchText);

                }).toList();

                if (users.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Users Found",
                      style: TextStyle(fontSize: 18),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: users.length,

                  itemBuilder: (context, index) {

                    final user = users[index];

                    final data =
                        user.data() as Map<String, dynamic>;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 12),

                      child: ListTile(

                        leading: CircleAvatar(
                          backgroundColor:
                              roleColor(data["role"]),

                          child: Icon(
                            roleIcon(data["role"]),
                            color: Colors.white,
                          ),
                        ),

                        title: Text(
                          data["name"] ?? "",
                        ),

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            Text(
                              data["email"] ?? "",
                            ),

                            const SizedBox(height: 5),

                            Chip(
                              label: Text(
                                data["role"] ?? "",
                              ),
                              backgroundColor:
                                  roleColor(data["role"])
                                      .withOpacity(.2),
                            ),
                          ],
                        ),

                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),

                          onPressed: () {

                            showDialog(
                              context: context,
                              builder: (_) {

                                return AlertDialog(

                                  title:
                                      const Text(
                                    "Delete User?",
                                  ),

                                  content:
                                      const Text(
                                    "Are you sure?",
                                  ),

                                  actions: [

                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                            context);
                                      },
                                      child:
                                          const Text(
                                              "Cancel"),
                                    ),

                                    ElevatedButton(
                                      onPressed: () {

                                        Navigator.pop(
                                            context);

                                        deleteUser(
                                            user.id);

                                      },
                                      child:
                                          const Text(
                                              "Delete"),
                                    ),
                                  ],
                                );
                              },
                            );

                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}