import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart' as http;

class addNew extends StatefulWidget {
  final Map? todo;
  const addNew({super.key, this.todo});

  @override
  State<addNew> createState() => _addNewState();
}

class _addNewState extends State<addNew> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todo;
    if (todo != null) {
      isEdit = true;
      final title = todo['title'];
      final description = todo['description'];
      titleController.text = title;
      descController.text = description;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Center(
        child: Text(isEdit ? "Edit" : "Add new"),
      )),
      body: ListView(
        padding: EdgeInsets.only(top: 50, left: 20, right: 20),
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(255, 210, 87, 251),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromARGB(255, 252, 251, 251),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: Offset(-3, -3))
                ]),
            width: double.infinity,
            height: 100,
            child: Container(
              padding: EdgeInsets.all(15),
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(255, 210, 87, 251),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 77, 72, 72),
                        blurRadius: 10,
                        spreadRadius: 0.2,
                        offset: Offset(3, 3))
                  ]),
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black)),
                child: TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: 'Title'),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Color.fromARGB(255, 210, 87, 251),
                boxShadow: [
                  BoxShadow(
                      color: Color.fromARGB(255, 252, 251, 251),
                      blurRadius: 10,
                      spreadRadius: 0.5,
                      offset: Offset(-3, -3))
                ]),
            width: double.infinity,
            height: 400,
            child: Container(
              padding: EdgeInsets.all(15),
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Color.fromARGB(255, 210, 87, 251),
                  boxShadow: [
                    BoxShadow(
                        color: Color.fromARGB(255, 77, 72, 72),
                        blurRadius: 10,
                        spreadRadius: 0.2,
                        offset: Offset(3, 3))
                  ]),
              child: Container(
                height: 400,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black)),
                child: TextField(
                  controller: descController,
                  decoration: InputDecoration(hintText: 'Desciption'),
                  keyboardType: TextInputType.multiline,
                  maxLines: 50,
                  minLines: 3,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          ElevatedButton(
              onPressed: () {
                isEdit ? update() : submit();
              },
              child: Center(
                child: Text(isEdit ? "Update" : "Submit"),
              ))
        ],
      ),
      backgroundColor: Color.fromARGB(255, 210, 87, 251),
    );
  }

  Future<void> update() async {
    final todo = widget.todo;
    if (todo == null) {
      print('You can not call update without todo data');
      return;
    }
    final id = todo['_id'];
    // final isCompleted = todo['is_Completed'];
    final title = titleController.text;
    final description = descController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": false,
    };

    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.put(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      showSuccessMessage("Updated Successfully");
    } else {
      showFailedMessage("Updation Failed");
    }
  }

  Future<void> submit() async {
    final title = titleController.text;
    final desc = descController.text;
    final body = {"title": title, "description": desc, "is_completed": true};

    final url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(uri, body: jsonEncode(body), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 201) {
      titleController.text = '';
      descController.text = '';
      showSuccessMessage('Creation Success');
    } else {
      showFailedMessage('Creation Failed');
      print(response.body);
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showFailedMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
