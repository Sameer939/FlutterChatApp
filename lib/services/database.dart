import 'package:chat_app/helper/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class DatabaseMethods{

  getUserByUsername(String username) async{
    return await FirebaseFirestore.instance.collection("users")
      .where("name", isEqualTo: username)
      .get();
  }
  
  
  getUserByUserId(String userId) async{
    return await FirebaseFirestore.instance.collection("users")
      .where("userId", isEqualTo: userId)
      .get();
  }

  

  getUserByUserEmail(String userEmail) async{
    return await FirebaseFirestore.instance.collection("users")
      .where("email", isEqualTo: userEmail)
      .get();
  }

  getUsers() async{
    return await FirebaseFirestore.instance
      .collection("users").get();
  }
  
  uploadUserInfo(userMap){
    FirebaseFirestore.instance.collection("users")
      .add(userMap);
  }


  createChatRoom(chatRoomId, chatRoomMap){
    FirebaseFirestore.instance.collection("ChatRoom")
      .doc(chatRoomId).set(chatRoomMap).catchError((e){
        print(e.toString());
      });
  }

  getConversationMessage(String chatRoomId) async{
    return FirebaseFirestore.instance.collection("ChatRoom").
    doc(chatRoomId).collection("chats")
    .orderBy("time",descending: true)
    .snapshots();
  }

  addConversationMessage(String chatRoomId, messageMap){
    FirebaseFirestore.instance.collection("ChatRoom").
    doc(chatRoomId).collection("chats")
    .add(messageMap).catchError((e){
      print(e.toString());
    });
    FirebaseFirestore.instance.collection("ChatRoom")
    .doc(chatRoomId).update(
      {
        "time" : DateTime.now().microsecondsSinceEpoch,
      }
    );
  }
  
  // fetching chats with userId!!
  getChatRooms(String userId) async{
    return FirebaseFirestore.instance
    .collection("ChatRoom")
    .where("users",arrayContains: userId)
    .orderBy("time",descending: true)
    .snapshots();
  }
  

  // Functions for Video Call Room
  addUsersToVideoCallList(String roomName,userId) async{
    bool exists = false;
    try{
      await FirebaseFirestore.instance
        .collection('videoCallRoom')
        .doc('$roomName').get().then((value){
          if(value.exists)
            exists = true;
          else 
            exists = false;
        });
    } catch(e){
      print(e.toString());
    }
    if(exists == false){
      List userList = [Constants.myUserId];
      List userNames = [Constants.myName];
      Map<String, dynamic> videoCallRoomInfo = {
        "RoomName" : roomName,
        "userNames" : userNames,
        "users" : userList,
      };
      FirebaseFirestore.instance
      .collection('videoCallRoom')
      .doc(roomName).set(videoCallRoomInfo).catchError((e){
        print("THE EROOR IS ==> " +e.toString());
      });
    }else{
      List userList = [Constants.myUserId];
      List userName = [Constants.myName];
      CollectionReference room = FirebaseFirestore.instance
        .collection('videoCallRoom');
      room.doc('$roomName')
        .update({
          'users' : FieldValue.arrayUnion(userList),
          'userNames' : FieldValue.arrayUnion(userName),
        }).then((value){
          print("It is updating it ---> ");
        }).catchError((e){
          print("THE ERROR IS ==> " + e.toString());
        });
    }
  }

  deleteUserFromVideoCallRoom(String roomName, String userId){
    List removeUserList = [userId];
    List removeUserName = [Constants.myName];
    CollectionReference room = FirebaseFirestore.instance
      .collection('videoCallRoom');
    
    room.doc('$roomName')
      .update({
        'users' : FieldValue.arrayRemove(removeUserList),
        'userNames' : FieldValue.arrayRemove(removeUserName)
      }).then((value) => print("remove Successfull"))
        .catchError((e) => print("The ERROR IS -->" + e.toString())
        );
    room.doc('$roomName')
      .get().then((value){
        if(value['users'].length == 0){
          room.doc('$roomName').delete()
          .then((value){
            print("It is Deleted!!");
          }).catchError((e){
            print("The Error is " + e.toString());
          });
        }
      });
  }


  // Functions for Groups 
  // when video call created check if group already exists
  Future groupExists(String groupName) async{
    bool exists = false;
    try{
      await FirebaseFirestore.instance
        .collection('groupRoom')
        .doc(groupName).get().then((value){
          // print("The Value of group - > ${value.data()}");
          if(value.exists)
            exists = true;
          else
            exists = false;
        });
    } catch(e){
      print(e.toString());
    }
    return exists;
  }

  // if Group doesnt exists create one!
  createGroupChatRoom(groupName, groupRoomMap){
    FirebaseFirestore.instance.collection("groupRoom")
      .doc(groupName).set(groupRoomMap).catchError((e){
        print(e.toString());
      });
  }
  
  // if Exists add the user to the group and the fetch the 
  // messages
  addUserToGroup(String groupName, String userId,String userName){
    List userList = [userId];
    List userNames = [userName];
    CollectionReference room = FirebaseFirestore.instance
      .collection('groupRoom');
      
    room.doc(groupName)
      .update({
        'users' : FieldValue.arrayUnion(userList),
        'userNames' : FieldValue.arrayUnion(userNames)
      }).then((value){
        print("It is updating it ---> ");
      }).catchError((e){
        print("THE ERROR IS ==> " + e.toString());
      });
  }


  getGroupConversationMessage(String groupName) async{
    return FirebaseFirestore.instance.collection("groupRoom").
    doc(groupName).collection("chats")
    .orderBy("time",descending: true)
    .snapshots();
  }

  // for sending message in groups 
  addConversationMessageInGroup(String groupName, messageMap){
    FirebaseFirestore.instance.collection("groupRoom").
    doc(groupName).collection("chats")
    .add(messageMap).catchError((e){
      print("The Error is  ---> " + e.toString());
    });

    // update time with time of latest message 
    FirebaseFirestore.instance.collection("groupRoom")  
    .doc(groupName).update(
      {
        "time" : DateTime.now().microsecondsSinceEpoch,
      }
    );
  }

  getGroupRooms(String userId) async{
    return FirebaseFirestore.instance
    .collection("groupRoom")
    .where("users",arrayContains: userId)
    .orderBy("time",descending: true)
    .snapshots();
  }

  // leave group function
  leaveGroup(String groupName){
    String userId = Constants.myUserId;
    List removeUserList = [userId];
    CollectionReference room = FirebaseFirestore.instance
      .collection('groupRoom');
    
    room.doc(groupName)
      .update({
        'users' : FieldValue.arrayRemove(removeUserList)
      }).then((value) => print("remove Successfull"))
        .catchError((e) => print("The ERROR IS -->" + e.toString())
        );
    // If no users present in the group then delete it!
    room.doc(groupName)
      .get().then((value){
        if(value['users'].length == 0){
          room.doc(groupName).delete()
          .then((value){
            print("It is Deleted!!");
          }).catchError((e){
            print("The Error is " + e.toString());
          });
        }
      });
  }
  


}