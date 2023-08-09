import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:todoapp/screens/add.dart';
import 'package:http/http.dart' as http;
import 'package:todoapp/screens/edit.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isLoading = true;
  List items = [];
  @override
  void initState() {
    super.initState();
    fetchTodo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 117, 220, 245),
          title: Center(
            child: Text(
              'Home',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
            ),
          )),
      body: Visibility(
        visible: isLoading,
        child: Center(child: CircularProgressIndicator()),
        replacement: RefreshIndicator(
          onRefresh: fetchTodo,
          child: Visibility(
            visible: items.isNotEmpty,
            replacement: Center(
                child: Text(
              'No Todo Item',
              style: Theme.of(context).textTheme.headline3,
            )),
            child: ListView.builder(
              padding: EdgeInsets.only(top: 20),
              // scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index] as Map;
                final id = item['_id'] as String;
                return Padding(
                  padding: const EdgeInsets.all(15),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            blurStyle: BlurStyle.normal,
                            offset: Offset(-3, -3),
                            color: Color.fromARGB(255, 239, 232, 232),
                            spreadRadius: 0.1,
                            blurRadius: 9,
                          )
                        ]),
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 0.1,
                                blurRadius: 10,
                                color: Color.fromARGB(255, 116, 112, 112),
                                offset: Offset(3, 3))
                          ],
                          color: Color.fromARGB(255, 231, 167, 191),
                          borderRadius: BorderRadius.circular(40)),
                      height: 60,
                      width: double.infinity,
                      // color: Color.fromARGB(255, 230, 57, 115),
                      child: ListTile(
                        leading: CircleAvatar(
                          foregroundColor: Color.fromARGB(255, 237, 210, 223),
                          backgroundColor: Color.fromARGB(255, 219, 115, 150),
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                        ),
                        title: Text(
                          item['title'],
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        // subtitle: Text(item['description']),
                        trailing: PopupMenuButton(
                            padding: EdgeInsets.all(3),
                            color: Color.fromARGB(255, 219, 115, 150),
                            onSelected: (value) {
                              if (value == 'edit') {
                                movetoEditPage(item);
                              } else if (value == 'delete') {
                                deleteBy(id);
                              }
                            },
                            itemBuilder: (context) {
                              return [
                                PopupMenuItem(
                                  child: Text(
                                    'Edit',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),
                                  ),
                                  value: 'edit',
                                ),
                                PopupMenuItem(
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20),
                                  ),
                                  value: 'delete',
                                ),
                              ];
                            }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 40,
          color: Color.fromARGB(255, 252, 149, 187),
        ),
        backgroundColor: Colors.black,
        onPressed: () => movetoAddPage(),
      ),
      backgroundColor: Color.fromARGB(255, 252, 149, 187),
    );
  }

  Future<void> movetoAddPage() async {
    final route = MaterialPageRoute(builder: (context) => addNew());

    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> movetoEditPage(Map item) async {
    final route = MaterialPageRoute(
      builder: (context) => addNew(todo: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTodo();
  }

  Future<void> deleteBy(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      showDeleteMessage('Deletion Completed');
      final filtered = items.where((element) => element['_id'] != id).toList();
      setState(() {
        items = filtered;
      });
    } else {
      showErrorMessage('Deletion Failed');
    }
  }

  Future<void> fetchTodo() async {
    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        items = result;
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color.fromARGB(255, 72, 12, 238),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showDeleteMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Color.fromARGB(255, 178, 50, 204),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
