import 'dart:io';

import 'package:app7chat/ui/chat_message.dart';
import 'package:app7chat/ui/text_compose.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ChatScreen extends StatefulWidget {

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  FirebaseUser _currentUser;
  bool _isLoadingImage = false;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.onAuthStateChanged.listen((userAuth){
      setState(() {
        _currentUser = userAuth;
      });
    });
  }

  Future<FirebaseUser> _getUser() async {
    if(_currentUser != null) return _currentUser;
    try{
      final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider
          .getCredential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

      final AuthResult authResult = await FirebaseAuth.instance.signInWithCredential(authCredential);

      final FirebaseUser userFirebase = authResult.user;
      return userFirebase;
    }catch (error) {
      print("Error no sign -> $error");
      return null;
    }
  }

  void _sendMessage({String text, File imgFile}) async {

    // final FirebaseUser user = await FirebaseAuth.instance.currentUser();
    final FirebaseUser user = await _getUser();

    if (user == null) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Não foi possível fazer o login. Tente novamente!"),
          backgroundColor: Colors.red,
        )
      );
      return;
    }

    Map<String, dynamic> data = {
      "uid" : user.uid,
      "sendName" : user.displayName,
      "senderPhotoUrl" : user.photoUrl,
      "timeMessage" : Timestamp.now()
    };

    if(null!=imgFile && imgFile.toString().isNotEmpty){
      /*showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: Text("ESPERE!"),
            titleTextStyle: TextStyle(color: Colors.green, fontSize: 20.0),
            content: Container(
              width: 100,
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  Padding(padding: EdgeInsets.only(bottom: 15.0),),
                  Text("A imagem está sendo salva!"),
                ],
              ),
            ),
            contentTextStyle: TextStyle(fontStyle: FontStyle.italic, color: Colors.green),
          );
        },
      );*/
      setState(() {
        _isLoadingImage = true;
      });
      StorageUploadTask task = await FirebaseStorage.instance.ref().child(
          (_currentUser != null ? _currentUser.uid : "000") + DateTime.now().millisecondsSinceEpoch.toString()//Nome do arquivo
      ).putFile(imgFile);//Arquivo q será guardado

      StorageTaskSnapshot taskSnapshot = await task.onComplete;
      String url = await taskSnapshot.ref.getDownloadURL();
      data["imgUrl"] = url;
      // Navigator.pop(context);
      setState(() {
        _isLoadingImage = false;
      });
    }

    if(null != text && text.isNotEmpty) data["text"] = text;

    // Firestore.instance.collection("mensagens").document().setData({});
    Firestore.instance.collection("messages").add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Para gerar alertas em mensagens na parte de baixo da tela
      // resizeToAvoidBottomInset: false, // Impede que o widget altere seu tamanho, quando o teclado aparecer
      appBar: AppBar(
        title: Text(
          _currentUser != null? 'Olá, ${_currentUser.displayName}' : 'Chat App'
        ),
        elevation: 0,
        centerTitle: true,
        actions: <Widget>[
          _currentUser != null ?
              IconButton(
                icon: Icon(Icons.exit_to_app),
                onPressed: (){
                  FirebaseAuth.instance.signOut();
                  googleSignIn.signOut();
                  _scaffoldKey.currentState.showSnackBar(
                    SnackBar(
                      content: Text("Você saiu com sucesso!"),
                    )
                  );
                },
              )
              : Container()
        ],
      ),
      body:Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder(// Sempre que haver uma mudança na variavel que contem os dados, será recarregada a página com os novos dados
                stream: Firestore.instance.collection("messages").orderBy("timeMessage", descending: true).snapshots(),
                builder: (context, snapshot){
                  switch(snapshot.connectionState){
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      List<DocumentSnapshot> documents = snapshot.data.documents;
                      return ListView
                          .builder(// Vai adicionando os dados conforme vai rolando as telas, assimdiminui a quantidade de uma vez na tela
                        itemCount: documents.length,
                        reverse: true,
                        itemBuilder: (context, index){
                          /*return ListTile(
                              title: Text(documents[index].data["text"]),
                            );*/
                          return ChatMessage(
                              documents[index].data,
                              documents[index].data["uid"] == _currentUser?.uid
                          );
                        },
                      );
                  }
                },
              ),
          ),
          _isLoadingImage ? LinearProgressIndicator() : Container(),
          // Duas maneiras de escrever
          // Maneira 1
          /*TextComposer(
          (text){//recebe o retorno que o texto da mensagem que foi enviada via widget
            _sendMessage(text);
          }
          ),*/
          // Maneira 2
          TextComposer(_sendMessage), //recebe o retorno que o texto da mensagem que foi enviada via widget
        ],
      ),
    );
  }
}
