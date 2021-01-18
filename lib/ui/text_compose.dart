import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {

  TextComposer(this.sendMessage);
  final Function({String text, File imgFile}) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controllerTextMessage = TextEditingController();
  bool _isComposing = false;

  void _resetText(){
    setState(() {
      _controllerTextMessage.clear();
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.photo_camera),
            onPressed: () async {
              final File imgFile = await ImagePicker.pickImage(source: ImageSource.camera);
              if ( null == imgFile) return;
              widget.sendMessage(imgFile: imgFile);
            },
          ),
          Expanded(
            child: TextField(
              controller: _controllerTextMessage,
              decoration: InputDecoration
                  .collapsed(hintText: "Enviar"),
              onChanged: (text){
                setState(() {
                  _isComposing = text.isNotEmpty;
                });
              },
              onSubmitted: (text){
                widget.sendMessage(text: text);//Quando apertar para enviar(usando submit do teclado qwerty), manda o texto colocado de volta via function usando widget
                _resetText();
              },
            ),
          ),
          IconButton(
              icon: Icon(Icons.send, color: _isComposing ? Colors.green : Colors.grey,),
              onPressed: _isComposing ? (){ // verifica se vai habilitar botão ou não, se tiver preenchimento vai liberar
                widget.sendMessage(text: _controllerTextMessage.text);//Quando apertar para enviar, manda o texto colocado de volta via function usando widget
                _resetText();
              } : null
          ),
        ],
      ),
    );
  }
}
