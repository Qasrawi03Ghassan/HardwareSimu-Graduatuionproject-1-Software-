import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hardwaresimu_software_graduation_project/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

  Future<void> sendMessage(String rID, String message) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: rID,
      message: message,
      timestamp: timestamp,
    );

    List<String> ids = [currentUserId, rID];
    ids.sort();

    String chatRoomId = ids.join();
    await _fireStore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .add(newMessage.toMap());
  }

  Stream<QuerySnapshot> getMessages(String userId, String otherId) {
    List<String> ids = [userId, otherId];
    ids.sort();
    String chatRoomId = ids.join();
    return _fireStore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
