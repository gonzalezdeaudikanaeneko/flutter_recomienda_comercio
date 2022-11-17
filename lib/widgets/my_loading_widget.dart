
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyLoadingWidget extends StatelessWidget{
  String text = '';

  MyLoadingWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 10,),
          Text(text),
        ],
      ),
    );
  }

}