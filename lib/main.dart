import 'package:app7chat/ui/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(MyApp());

  /*
  // Funções do Firebase database
  //Incluir
  Firestore.instance.collection("mensagens").document("doc1").setData({"texto":"daniel"});
  //Ler
  QuerySnapshot snapshot = await Firestore.instance.collection("mensagens").getDocuments();
  snapshot.documents.forEach((resultado){
    print(resultado.data);
    print(resultado.documentID);
    resultado.reference.updateData({"texto":"daniel meu deus"});
  });
  DocumentSnapshot collectionSnapshot = await Firestore.instance.collection("mensagens").document("doc").get();
  print(documentSnapshot.data);
  //Saber quando uma coleção deve mudança em um dos seus documentos
  Firestore.instance.collection("mensagens").snapshots().listen((dadosMudado){
    print(dadosMudado.documents[0].data);
    dadosMudado.documents.forEach((d){
      print(d.data);
    });
  });
  //Saber quando um documento deve mudança nos dados
  Firestore.instance.collection("mensagens").document("doc").snapshots().listen((resultadoDocumento){
    print(resultadoDocumento);
  });
  */
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        iconTheme: IconThemeData(
          color: Colors.blue
        ),
      ),
      home: ChatScreen(),
    );
  }
}