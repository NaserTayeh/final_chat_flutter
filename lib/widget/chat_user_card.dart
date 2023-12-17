import 'package:chat_finaly/api/apis.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../model/chat_user.dart';
import '../model/message.dart';
import '../screens/chat_screen.dart';
import 'dialog/profile_dialog.dart';

//card to represent a single user in home screen
class ChatUserCard extends StatefulWidget {
  final ChatUser user;

  const ChatUserCard({
    super.key,
    required this.user,
  });

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _message;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(
                  user: widget.user,
                ),
              ));
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.user),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            // if (data != null && data.first.exists) {
            //   _message =
            //       Message.fromJson(data.first.data() as Map<String, dynamic>);
            // }
            final list = data
                    ?.map((e) =>
                        Message.fromJson(e.data() as Map<String, dynamic>))
                    .toList() ??
                [];
            if (list.isNotEmpty) {
              _message = list[0];
            }
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0.5,
              // color: Colors.blue.shade100,
              margin: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * .04,
                  vertical: 4),
              child: ListTile(
                // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                leading: InkWell(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (_) => ProfileDialog(user: widget.user));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.height * 0.3),
                    child: CachedNetworkImage(
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.height * 0.077,
                      height: MediaQuery.of(context).size.height * 0.077,
                      imageUrl: widget.user.image,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          CircleAvatar(child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                    _message != null
                        ? _message!.type == Type.image
                            ? 'image'
                            : _message!.msg
                        : widget.user.about,
                    maxLines: 1),

                trailing: _message == null
                    ? null //show nothing when no message is sent
                    : _message!.read.isEmpty &&
                            _message!.fromId != APIs.user.uid
                        ?
                        //show for unread message
                        Container(
                            width: 15,
                            height: 15,
                            decoration: BoxDecoration(
                                color: Colors.greenAccent.shade400,
                                borderRadius: BorderRadius.circular(10)),
                          )
                        :
                        //message sent time
                        Text(
                            MyDateUtil.getLastMessageTime(
                                context: context, time: _message!.sent),
                            style: const TextStyle(color: Colors.black54),
                          ),
              ),
            );
          },
        ));

    //  Card(
    //   margin: EdgeInsets.symmetric(
    //       horizontal: MediaQuery.of(context).size.width * .04, vertical: 4),
    //   elevation: 0.5,
    //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    //   child: InkWell(
    //       onTap: () {
    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //                 builder: (_) => ChatScreen(user: widget.user)));
    //       },
    //       child: StreamBuilder(
    //         stream: APIs.getLastMessage(widget.user),
    //         builder: (context, snapshot) {
    //           final data = snapshot.data?.docs;
    //           final list =
    //               data?.map((e) => Message.fromJson(e.data())).toList() ?? [];
    //           if (list.isNotEmpty) _message = list[0];

    //           return ListTile(
    //             //user profile picture
    //             leading: InkWell(
    //               onTap: () {
    //                 showDialog(
    //                     context: context,
    //                     builder: (_) => ProfileDialog(user: widget.user));
    //               },
    //               child: ClipRRect(
    //                 borderRadius: BorderRadius.circular(mq.height * .03),
    //                 child: CachedNetworkImage(
    //                   width: mq.height * .055,
    //                   height: mq.height * .055,
    //                   imageUrl: widget.user.image,
    //                   errorWidget: (context, url, error) => const CircleAvatar(
    //                       child: Icon(CupertinoIcons.person)),
    //                 ),
    //               ),
    //             ),

    //             //user name
    //             title: Text(widget.user.name),

    //             //last message
    //             subtitle: Text(
    //                 _message != null
    //                     ? _message!.type == Type.image
    //                         ? 'image'
    //                         : _message!.msg
    //                     : widget.user.about,
    //                 maxLines: 1),

    //             //last message time
    //             trailing: _message == null
    //                 ? null //show nothing when no message is sent
    //                 : _message!.read.isEmpty &&
    //                         _message!.fromId != APIs.user.uid
    //                     ?
    //                     //show for unread message
    //                     Container(
    //                         width: 15,
    //                         height: 15,
    //                         decoration: BoxDecoration(
    //                             color: Colors.greenAccent.shade400,
    //                             borderRadius: BorderRadius.circular(10)),
    //                       )
    //                     :
    //                     //message sent time
    //                     Text(
    //                         MyDateUtil.getLastMessageTime(
    //                             context: context, time: _message!.sent),
    //                         style: const TextStyle(color: Colors.black54),
    //                       ),
    //           );
    //         },
    //       )),
    // );
  }
}