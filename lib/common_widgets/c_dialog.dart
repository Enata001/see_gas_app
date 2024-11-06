import 'package:flutter/material.dart';
import 'c_scaffold_message.dart';

customDialog({required BuildContext context, required Function callback, required String title, required String message}){
  showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => CScaffoldMessage(
      title: title,
      message: message,
      callback: callback,
    ),
  );
}