import 'package:chat_app/helper/helperfunctions.dart';
import 'package:chat_app/services/auth.dart';
import 'package:chat_app/services/database.dart';
import 'package:chat_app/views/chatroom.dart';
import 'package:chat_app/widgets/widget.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  final Function toggle;
  SignUp(this.toggle);


  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

  bool isLoading = false;
  AuthMethods authMethods = new AuthMethods();
  DatabaseMethods databaseMethods = new DatabaseMethods();
  // HelperFunctions helperFunctions = new HelperFunctions();

  final formKey = GlobalKey<FormState>();
  TextEditingController userNameTextEditingController = new TextEditingController();
  TextEditingController emailTextEditingController = new TextEditingController();
  TextEditingController passwordTextEditingController = new TextEditingController();

  signMeUP() async{ 

      if(formKey.currentState.validate()){
        Map<String, String> userInfoMap = {
              "name" :userNameTextEditingController.text,
              "email" : emailTextEditingController.text,
        };
        setState(() {
          isLoading = true;
        });
        authMethods.registerWithEmailAndPassword(emailTextEditingController.text, 
            passwordTextEditingController.text).then((val){
              // print("$val");
        HelperFunctions.saveUserLoggedInSharedPreference(true);
        HelperFunctions.saveUserEmailSharedPreference(
          emailTextEditingController.text);
        HelperFunctions.saveUserNameSharedPreference(
          userNameTextEditingController.text);
          





            databaseMethods.uploadUserInfo(userInfoMap);

            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => ChatRoom()
                ),
                );
            }
        );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ApplicationToolbar(),
        body: isLoading ? Container(
          child: Center(child: CircularProgressIndicator()),
        ) : SingleChildScrollView(
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
                              return val.isEmpty || val.length <= 3 ?"Please Provide valid Username" : null; 
                            },
                            controller: userNameTextEditingController,
                            style: simpleTextStyle(),
                            decoration: textFieldInputDecoration("username"),
                          ),
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
                        signMeUP();
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
                        child: Text("Sign Up",style: mediumTextStyle(),),
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
                      child: Text("Sign Up with Google",
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
                        Text("Already have an account? ", style: mediumTextStyle(),
                        ),
                        GestureDetector(
                          onTap: (){
                            widget.toggle();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text("Sign in Now", style: TextStyle(
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
