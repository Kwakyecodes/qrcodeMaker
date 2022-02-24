import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';




class Home extends StatefulWidget {
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  final url = TextEditingController();
  // imageUrl is the url that locates the qr code in the api folder
  final imageUrl = "http://10.0.2.2:8000/static/m.jpg";

  // This function checks if access to write storage is granted and then downloads qr code
  _save() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      var response = await Dio().get(
          imageUrl,
          options: Options(responseType: ResponseType.bytes));
      final result = await ImageGallerySaver.saveImage(
          Uint8List.fromList(response.data),
          quality: 60,
          name: "qrcode");
      print(result);
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    url.dispose();
    super.dispose();
  }



  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child:SafeArea (
                child: Column(
                    children: [
                      SizedBox(height: 270),
                      Align(
                          alignment: Alignment.center,
                          child: Container(
                            height:52,
                            width: 355,
                            child: TextField(
                              controller: url,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                              showCursor: false,
                              //cursorColor: Colors.black45,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 16),
                                hintText: 'Type in the url here',
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(
                                const Radius.circular(5)
                              ),
                            ),
                          )
                      ),
                      SizedBox(height: 20),
                      Align(
                          alignment: Alignment.center,
                          child: FloatingActionButton.extended(
                            label: Text('Get QR code'),
                            icon: Icon(Icons.download),
                            backgroundColor: Colors.black54,
                            onPressed: () async{

                              String urlString = url.text;
                              final URL = 'http://10.0.2.2:8000/$urlString/';
                              final response = await http.get(Uri.parse(URL));
                              if (response.statusCode == 200)
                              {
                                _save();
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        content: Text("Qrcode Downloaded. Check gallery."),
                                      );
                                    }
                                );
                              }
                              else
                              {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                    content: Text("Something went wrong. Check url."),
                                    );
                                }
                                );
                              }
                              dispose();
                            },
                          )

                          )
                    ]
                )
            )
        )
    );

  }

}