import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chatroom.dart';

class SignIn extends StatefulWidget {
  final Function toggle;
  SignIn(this.toggle);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();
  final formKey = GlobalKey<FormState>();
  QuerySnapshot snapshotUserInfo;

  bool isLoading = false;
  
  signIn(){

    if(formKey.currentState.validate()){
      HelperFunctions
          .saveUserEmailSharedPreference(emailTextEditingController.text);
      
      setState(() {
        isLoading = true;
      });

      databaseMethods.getUserByUserEmail(emailTextEditingController.text)
      .then((val){
        snapshotUserInfo = val;
        HelperFunctions
          .saveUserNameSharedPreference(snapshotUserInfo.docs[0]['name']);
      });
      authMethods
      .signInWithEmailAndPassword(emailTextEditingController.text, 
        passwordTextEditingController.text).then((val){
          if(val != null){
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => ChatRoom()
                ),
              );
          }
        });
    

      }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ApplicationToolbar(),
        body:  SingleChildScrollView(
          child: Container(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      key: formKey,
                      child: Column(
                        children: [
                          TextFormField(
                          validator: (val){
                            return RegExp(
                                        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                    .hasMatch(val)? null: "Please enter correct email";
                          },
                          controller: emailTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("email"),
                        ),
                          TextFormField(
                          obscureText: true,
                          validator: (val){
                            return val.length > 6 ? null : "Please provide password with 6 + characters";
                          },
                          controller: passwordTextEditingController,
                          style: simpleTextStyle(),
                          decoration: textFieldInputDecoration("password"),
                        ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            "Forgot Password?",
                            style: simpleTextStyle(),
                          ),
                        )),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: (){
                        signIn();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(vertical: 20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xff007EF4),
                                const Color(0xff2A75BC)
                              ],
                            )),
                        child: Text("Sign In",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                            )),
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [Colors.white, const Color(0xff2A75BC)],
                          )),
                      child: Text("Sign In with Google",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                          )),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Dont have an account ",
                          style: mediumTextStyle(),
                        ),
                        GestureDetector(
                          onTap: (){
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("Register Now ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  decoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    )
                  ],
                ),
              )),
        ));
  }
}
