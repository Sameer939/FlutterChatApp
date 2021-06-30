
import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class ConversationScreen extends StatefulWidget {
  // const ConversationScreen({ Key? key }) : super(key: key);
  final String chatRoomId;
  ConversationScreen(this.chatRoomId);
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();
  Stream chatMessageStream;


  Widget ChatMessageList(){
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (context, snapshot){
        return snapshot.hasData ? ListView.builder(
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context,index){
            // print("length hai bhai yeh = ${snapshot.data.docs.length}");
            
            return MessageTile(
              snapshot.data.docs[index]["message"],
              Constants.myName == snapshot.data.docs[index]["sendBy"],
              );
          }
        ) :Container() ;
      }

    );
  }
  sendMessage(){
    if(messageController.text.isNotEmpty){ 
       Map<String, dynamic> messageMap = {
      "message" : messageController.text,
      "sendBy" : Constants.myName,
      "time" : DateTime.now().microsecondsSinceEpoch,
    }; 
    databaseMethods.addConversationMessage(widget.chatRoomId, messageMap);
    messageController.text = "";
    }
  }
  @override
  void initState() {
    databaseMethods.getConversationMessage(widget.chatRoomId).then((val){
      setState(() {
        chatMessageStream = val;
      });

    } );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ApplicationToolbar(),
      body: Container(
        child: Stack(
          children: [
            ChatMessageList(),
             Container(
               alignment: Alignment.bottomCenter,
               child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
                color: Color(0x54FFFFFF),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: messageController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                        hintText: "Message...",
                        hintStyle: TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                      ),
             
                    ),
                    GestureDetector(
                      onTap: (){
                        sendMessage();
                      },
                      child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors:[
                              const Color(0x36FFFFFF),
                              const Color(0x0FFFFFFF),
                            ]
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Image.asset("assets/images/send.png",)),
                    ),
                  ],
                ),
              ),
             ),
          ],
        ),
      ),
    );
  }
}


class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  MessageTile(this.message,this.isSendByMe);

  @override
  Widget build(BuildContext context) {

    
    return Container(
      child: Container(
      padding: EdgeInsets.only(
        left: isSendByMe ? 0:  10,
        right: isSendByMe ? 10 : 0),

        margin: EdgeInsets.symmetric(vertical: 8),
        width: MediaQuery.of(context).size.width,
        alignment: isSendByMe ? 
          Alignment.centerRight 
          : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                 colors: isSendByMe ? [
                const Color(0xff007EF4),
                const Color(0xff2A75BC)
              ]
                  : [
                const Color(0x1AFFFFFF),
                const Color(0x1AFFFFFF)
              ],
              ),
              borderRadius: isSendByMe ?
                BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomLeft: Radius.circular(23)
                ): BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                  bottomRight: Radius.circular(23)
                )
            ),
            child: Text(message,style: TextStyle(
                color: Colors.white, fontSize: 16
                 ),
                ),
        ),
      ),
    );
  }
}