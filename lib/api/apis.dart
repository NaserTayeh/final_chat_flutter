import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:chat_finaly/model/message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../model/chat_user.dart';

class APIs {
  static FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  static late ChatUser me;
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static User get user => firebaseAuth.currentUser!;
  static Future<bool> userExsist() async {
    return (await firebaseFirestore.collection('users').doc(user.uid).get())
        .exists;
  }

  static Future<bool> addChatUser(String email) async {
    final data = await firebaseFirestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    log('data: ${data.docs}');

    if (data.docs.isNotEmpty && data.docs.first.id != user.uid) {
      //user exists

      log('user exists: ${data.docs.first.data()}');

      firebaseFirestore
          .collection('users')
          .doc(user.uid)
          .collection('my_users')
          .doc(data.docs.first.id)
          .set({});

      return true;
    } else {
      //user doesn't exists

      return false;
    }
  }

  static Future<void> getFirebaseMessagingToken() async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then((t) {
      if (t != null) {
        me.pushToken = t;

        log('Push Token: $t');
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        "data": {"some_data": "User ID: ${me.id}"}
      };

      var res =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                HttpHeaders.contentTypeHeader: 'application/json',
                HttpHeaders.authorizationHeader:
                    'key=AAAA60mZNg0:APA91bE2fOk51Aus8u0tpdj23sery7fxXDPUV0gsYGYwW8hve4nU9dUz5qpRBAIZC-_0_bUQm9Jclat67W_BxdfH0_F7141fM1_8PguXQts9tJbaFTbjsP5xHPwq5ZE8PXUnMxh4fonm'
              },
              body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }

  static Future<void> getSelfInfo() async {
    return await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        getFirebaseMessagingToken();
        await APIs.updateActiveStatus(true);
        log('My Data ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo());
      }
    });
  }

  static Future<void> createUser() async {
    print(firebaseAuth.currentUser);
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey , im new user",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');
    return await firebaseFirestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firebaseFirestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  static String getConversationId(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firebaseFirestore
        .collection('chats/${getConversationId(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .snapshots();
  }

  static Future<void> sendMessage(
      ChatUser chatUser, String msg, Type type) async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    Message message = Message(
        toId: chatUser.id,
        msg: msg,
        read: '',
        type: type,
        fromId: user.uid,
        sent: time);
    final ref = firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/');
    await ref.doc(time).set(message.toJson()).then((value) =>
        sendPushNotification(chatUser, type == Type.text ? msg : 'image'));
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    firebaseFirestore
        .collection('chats/${getConversationId(message.fromId)}/messages/')
        .doc(message.sent)
        .update({'read': DateTime.now().microsecondsSinceEpoch.toString()});
  }

  static Future<void> updateUserInfo() async {
    return await firebaseFirestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  static Future<void> updateProfilePicture(File file) async {
    final ext = file.path.split('.').last;
    log('extensions is ${ext}');
    final ref =
        firebaseStorage.ref().child('profile_pictures/${user.uid}.$ext');
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });
    me.image = await ref.getDownloadURL();
    return await firebaseFirestore.collection('users').doc(user.uid).update({
      'image': me.image,
    });
  }

  static Stream<QuerySnapshot> getLastMessage(ChatUser chatUser) {
    return firebaseFirestore
        .collection('chats/${getConversationId(chatUser.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firebaseFirestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    firebaseFirestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  static Future<void> sendChatImage(ChatUser chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = firebaseStorage.ref().child(
        'images/${getConversationId(chatUser.id)}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  //delete message
  static Future<void> deleteMessage(Message message) async {
    await firebaseFirestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .delete();

    if (message.type == Type.image) {
      await firebaseStorage.refFromURL(message.msg).delete();
    }
  }

  //update message
  static Future<void> updateMessage(Message message, String updateMsg) async {
    await firebaseFirestore
        .collection('chats/${getConversationId(message.toId)}/messages/')
        .doc(message.sent)
        .update({'msg': updateMsg});
  }
}
