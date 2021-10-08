import 'package:flutter/material.dart';
import 'package:newmap/configMap.dart';

class DividerWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 0.5,
      color: textcolor,
      thickness: .5,
      indent: 20,
      endIndent: 20,
      
    );
  }
}