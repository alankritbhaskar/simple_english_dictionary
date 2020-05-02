import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
     // title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        primaryColor: Colors.deepPurple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _url="https://owlbot.info/api/v4/dictionary/";
  String _token="7b3af77fd66ce1ed093f1702bc2c12b426e77631";
  TextEditingController _controller=TextEditingController();

  StreamController _streamController;
  Stream _stream;

  Timer _debounce;

  _search() async{
    if(_controller.text==null || _controller.text.length==0){
      _streamController.add(null);
      return;
    }

    _streamController.add("Waiting!!!");

   Response response=await get(_url+ _controller.text.trim(),headers: {"Authorization":
        "Token "+ _token});

    _streamController.add(jsonDecode(response.body));
  }

  @override

  void initState(){
    super.initState();
    _streamController=StreamController();
    _stream=_streamController.stream;
  }
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: FittedBox(fit:BoxFit.fitWidth,
              child: Text('My Dictionary')
          ),
       bottom:
          PreferredSize(

            preferredSize: Size.fromHeight(48.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 12.0,bottom: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.0),
                    ),
                    child: TextFormField(
                      onChanged: (String text){
                       if(_debounce ?.isActive ?? false) _debounce.cancel();
                       _debounce=Timer(const Duration(milliseconds: 1000),(){
                         _search();
                       }
                       );
                      },
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText:("Search the word"),
                        contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                      //  focusedBorder: OutlineInputBorder(
                          //  borderSide: BorderSide(color: Colors.deepPurpleAccent)),

                      ),
                    ),
                  ),
                ),
                IconButton(icon: Icon(
                  Icons.search,
                  color: Colors.white70,
                ),
                  onPressed: (){
                  _search();
                  },
                )
              ],
            ),
          ),
        ),
        body: Container(
          margin: const EdgeInsets.all(8.0),
          child: StreamBuilder(
           stream: _stream,
            builder: (BuildContext ctx, AsyncSnapshot snapshot){
    if(snapshot.data==null){
    return Center(
          child: Text("Hello! Type to begin the search experience",
          style: TextStyle(
                 fontSize: 15.0 ),
      ),
    );
    }
    if(snapshot.data=="Waiting!!!"){
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return ListView.builder(
    itemCount: snapshot.data["definitions"].length,
    itemBuilder: (BuildContext context,int index){
    return ListBody(
    children: <Widget>[
    Container(
    color: Colors.grey[300],
    child: ListTile(
    leading: snapshot.data["definitions"][index]["image_url"]==null ? null : CircleAvatar(
    backgroundImage: NetworkImage(snapshot.data["definitions"][index]["image_url"]),
    ),
    title: Text(_controller.text.trim() + "(" +snapshot.data["definitions"][index]["type"]+")"),
    ),
    ),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(snapshot.data["definitions"][index]["definition"]),
      ),
    ],
    );
    },
    );
    },
    ),
        ),
    );
  }
}