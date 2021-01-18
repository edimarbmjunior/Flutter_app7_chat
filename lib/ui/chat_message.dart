import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {

  ChatMessage(this.data, this.mine);

  final Map<String, dynamic> data;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Row(
        children: <Widget>[
          !mine ? // Alinhamento quando o usuario recebeu a mensagem
          Padding(
            padding: EdgeInsets.only(right: 15.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ) : Container(),
          Expanded(
            child: Column(
              crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: <Widget>[
                data["imgUrl"] != null ?
                    Image.network(data['imgUrl'], width: 250, height: 200,)
                      :
                    Text(
                        data["text"],
                        textAlign: mine ? TextAlign.end : TextAlign.start,
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500
                        ),
                      ),
                Text(
                  data["sendName"],
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ),
          mine ? // Alinhamento quando o usuario mandou a mensagem
          Padding(
            padding: EdgeInsets.only(left: 15.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(data["senderPhotoUrl"]),
            ),
          ) : Container(),
        ],
      ),
    );
  }
}
