import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String bookingId;
  final String customerId;
  final String sellerId;
  final String sellerEmail;

  const ChatScreen({
    super.key,
    required this.bookingId,
    required this.customerId,
    required this.sellerId,
    required this.sellerEmail,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageController =
      TextEditingController();

  final ScrollController scrollController =
      ScrollController();

  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }
  Future<void> sendMessage() async {
  final text = messageController.text.trim();

  if (text.isEmpty) return;

  final now = Timestamp.now();

  await FirebaseFirestore.instance
      .collection("messages")
      .doc(widget.bookingId)
      .set({
    "bookingId": widget.bookingId,
    "customerId": widget.customerId,
    "sellerId": widget.sellerId,
    "lastMessage": text,
    "lastMessageTime": now,
  }, SetOptions(merge: true));

  await FirebaseFirestore.instance
      .collection("messages")
      .doc(widget.bookingId)
      .collection("chats")
      .add({
    "senderId": currentUser.uid,
    "senderEmail": currentUser.email,
    "receiverId": currentUser.uid == widget.customerId
        ? widget.sellerId
        : widget.customerId,
    "message": text,
    "timestamp": now,
    "isRead": false,
  });

  messageController.clear();

  await Future.delayed(
    const Duration(milliseconds: 200),
  );

  if (scrollController.hasClients) {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }
}

  Widget buildMessage(Map<String, dynamic> data) {
    final bool isMe =
        data["senderId"] == currentUser.uid;

    return Align(
      alignment:
          isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin:
            const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),
        constraints:
            const BoxConstraints(maxWidth: 300),
        decoration: BoxDecoration(
          color:
              isMe ? Colors.blue : Colors.grey.shade300,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (!isMe)
              Text(
                data["senderEmail"] ?? "",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),

            Text(
              data["message"] ?? "",
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : Colors.black,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 4),

             Text(
  data["timestamp"] != null
      ? TimeOfDay.fromDateTime(
          (data["timestamp"] as Timestamp).toDate(),
        ).format(context)
      : "",
  style: TextStyle(
    color: isMe ? Colors.white70 : Colors.black54,
    fontSize: 11,
  ),
)
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.sellerEmail),
        centerTitle: true,
      ),

      body: Column(
        children: [

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("messages")
                  .doc(widget.bookingId)
                  .collection("chats")
                  .orderBy("timestamp")
                  .snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Start the conversation...",
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
  if (scrollController.hasClients) {
    scrollController.jumpTo(
      scrollController.position.maxScrollExtent,
    );
  }
});

                return ListView.builder(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.all(15),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder:
                      (context, index) {

                    final data =
                        snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                    return buildMessage(data);
                  },
                );
              },
            ),
          ),

          const Divider(height: 1),

          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [

                Expanded(
                  child: TextField(
                    controller:
                        messageController,
                    decoration:
                        const InputDecoration(
                      hintText:
                          "Type a message...",
                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                CircleAvatar(
                  radius: 25,
                  child: IconButton(
                    icon:
                        const Icon(Icons.send),
                   onPressed: sendMessage,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}