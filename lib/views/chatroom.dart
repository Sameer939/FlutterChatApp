import 'package:chat_app/helper/constants.dart';
import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/helper/recieverDetails.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/conversation_screen.dart';
import 'package:chat_app/views/search.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/utils/Utils.dart';

class ChatRoom extends StatefulWidget {

  @override
  _ChatRoomState createState() => _ChatRoomState();
}
// Global Variable
Stream chatRoomsStream;

class _ChatRoomState extends State<ChatRoom> {
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();




  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async{
    Constants.myEmail = await HelperFunctions.getUserEmailSharedPreference();
    Constants.myName = await HelperFunctions.getUserNameSharedPreference();
    Constants.myUserId = Utils
      .createUserId(Constants.myEmail);
    print(Constants.myEmail.toString());
    print(Constants.myUserId);
    databaseMethods.getChatRooms(Constants.myUserId)
    .then((value){
      setState(() {
        chatRoomsStream = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChatListContainer(Constants.myUserId),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.search),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => SearchScreen(),
             ));
        } ,
      ),
      
    );
  }
}

class ChatListContainer extends StatefulWidget {
  // const ChatListContainer({ Key? key }) : super(key: key);
  final String currentUserId;

  ChatListContainer(this.currentUserId);

  @override
  _ChatListContainerState createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder(
        stream: chatRoomsStream,
        builder: (context, snapshot){
          return snapshot.hasData ? ListView.builder(
            itemCount: snapshot.data.docs.length,
            itemBuilder: (context, index){
              int time = snapshot.data.docs[index]['time'];
              String chatRoomId =  snapshot.data
                .docs[index]['chatroomId'].toString();
              
              RecieverDetails.recieverUserId = chatRoomId
                .replaceAll("_","")
                .replaceAll(Constants.myUserId,"");

              RecieverDetails.recieverUserName = 
                snapshot.data.docs[index]['userNames'][0] != Constants.myName 
                  ? snapshot.data.docs[index]['userNames'][0] 
                  : snapshot.data.docs[index]['userNames'][1];
              
              return ChatRoomsTile(
                RecieverDetails.recieverUserName,
                chatRoomId,
                time,
              );
            }
          ) : Container();
        },
    )
      
    );
  }
}











class ChatRoomsTile extends StatelessWidget {
  final String userName;
  final String chatRoomId;
  final int time;
  ChatRoomsTile(this.userName,this.chatRoomId, this.time);
  
  timeData(int time){
    return  DateTime
    .fromMicrosecondsSinceEpoch(time)
    .toString()
    .substring(11,16);
  }
  
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ConversationScreen(chatRoomId,userName)
          ));
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24,vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              color: Colors.black,
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(40),
                    ),
                  child: Text("${userName.substring(0,1).toUpperCase()}",
                  style: mediumTextStyle()),
                ),
                SizedBox(width: 8,),
                Text(userName, style: mediumTextStyle(),),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 16),
                  child: Text(timeData(time), style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),)),
              ],
              ),
          ),
          Divider(
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}