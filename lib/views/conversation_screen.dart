import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/utils/universal_variables.dart';
import 'package:clipboard/clipboard.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';


class ConversationScreen extends StatefulWidget {
  // const ConversationScreen({ Key? key }) : super(key: key);
  final String chatRoomId;
  final String recieverUserName;
  ConversationScreen(this.chatRoomId, this.recieverUserName);
  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController messageController = new TextEditingController();
  Stream chatMessageStream;
  bool isWriting = false;
  bool showEmojiPicker = false;
  FocusNode textFieldFocus = new FocusNode();
  
  Widget chatMessageList(){
    return Container(
      child: StreamBuilder(
        stream: chatMessageStream,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
            reverse: true,
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context,index){
              String message = snapshot.data.docs[index]["message"];

              return MessageTile(
                message,
                Constants.myName == snapshot.data.docs[index]["sendBy"],
                snapshot.data.docs[index]["time"],
                );
            }
          ) :Container() ;
        }

      ),
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

  showKeyboard() => textFieldFocus.requestFocus();
  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer(){
    setState(() {
      showEmojiPicker = false;
    });
  }

  // Close the Emoji Container if it is already OPEN
  toggleEmojiContainer(){
      setState(() {
        showEmojiPicker = !showEmojiPicker;
      });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
          Container(
            child: Text(widget.recieverUserName,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.more_horiz),
              iconSize: 30.0,
              color: Colors.white,
              onPressed: (){

              },
            )
          ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          child: Column(
            children: [
              Flexible(
                child: chatMessageList() ,
              ),
              chatControls(),
              showEmojiPicker ? Container(child: emojiContainer(),) 
              : Container(),
            ],
          ),
        ),
      ),
    );
  }

  emojiContainer(){
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        messageController.text 
          = messageController.text + emoji.emoji;
      },
      recommendKeywords: ["face","happy","party","sad"],
      numRecommended: 20,
    );
  }

  
  // For sending message in convo Screen 
  Widget chatControls(){
    
   return Container(
      alignment: Alignment.bottomCenter,
      child: Container(
  
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                  controller: messageController,
                  focusNode: textFieldFocus,
                  onTap: () => hideEmojiContainer() ,
                  textCapitalization : TextCapitalization.sentences, 
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Type a message",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(50.0),
                      ),
                      borderSide: BorderSide.none,
                      ),
                    contentPadding: 
                      EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                      filled: true,
                      fillColor: UniversalVariables.separatorColor,
                      suffixIcon: IconButton(
                        splashColor: Colors.white,
                        highlightColor: Colors.white,
                        onPressed: () {
                          if(!showEmojiPicker){
                            hideKeyboard();
                          }
                          else {
                            showKeyboard();
                          }
                          toggleEmojiContainer();
                        },
                        icon: Icon(Icons.face , color: Colors.white,),
                      )
                ),
              ),
            ),
            Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      color: UniversalVariables.blueColor,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 22,
                      color: Colors.white,
                    ),
                    onPressed: () => sendMessage(),
                  )
              )
          ],
        ),
      ),
    );


  }


}


class MessageTile extends StatelessWidget {
  final String message;
  final bool isSendByMe;
  final int sentTime;
  MessageTile(this.message,this.isSendByMe,this.sentTime);

  timeData(int time){
    return  DateTime
    .fromMicrosecondsSinceEpoch(sentTime)
    .toString()
    .substring(11,16);
  }

  @override
  Widget build(BuildContext context) {

    
    return GestureDetector(
      onLongPress: () async{
        await FlutterClipboard.copy(message);
        ScaffoldMessenger.of(context)
        .showSnackBar(
        SnackBar(content: Text("Copied to ClipBoard"))
        );
      },
      child: Container(
        child: Container(
          padding: EdgeInsets.only(
            left: isSendByMe ? 0:  10,
            right: isSendByMe ? 10 : 0
          ),
    
          margin: EdgeInsets.symmetric(vertical: 8),
          width: MediaQuery.of(context).size.width,
          alignment: isSendByMe ? 
            Alignment.centerRight 
            : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ) ,
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
              child: Column(
                crossAxisAlignment :CrossAxisAlignment.end,
                children: [
                    Text(message,style: TextStyle(
                        color: Colors.white, fontSize: 16
                       ),
                      ),
                  SizedBox(height: 6.0,),
                    Text(timeData(sentTime),style: TextStyle(
                        color: Colors.white, fontSize: 11
                      ),
                    ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}