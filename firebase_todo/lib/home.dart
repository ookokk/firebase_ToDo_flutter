import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Home extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text("Firebase ToDo")),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('todos')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final todos = snapshot.data?.docs;
                      if (todos == null) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (todos.isEmpty) {
                        return const Center(
                          child: Text("No todos added yet"),
                        );
                      }
                      return ListView.builder(
                        itemCount: todos.length,
                        padding: const EdgeInsets.all(8.0),
                        itemBuilder: (BuildContext context, int index) {
                          final todo = todos[index];
                          return Dismissible(
                            key: Key(todo.id),
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              alignment: Alignment.centerLeft,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              FirebaseFirestore.instance
                                  .collection('todos')
                                  .doc(todo.id)
                                  .delete();
                            },
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection('todos')
                                    .doc(todo.id)
                                    .set({
                                  'todo': todo['todo'],
                                  'createdAt': Timestamp.now()
                                });
                              },
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        todo['todo'],
                                        style: const TextStyle(),
                                      ),
                                      const Divider(),
                                      Text(
                                        DateFormat('dd-MM-yyyy   HH:mm:ss')
                                            .format(todo['createdAt'].toDate()),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                _inputFields(),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textInputAction: TextInputAction.send,
                        keyboardType: TextInputType.multiline,
                        onSubmitted: (String value) {},
                        controller: _controller,
                        decoration: InputDecoration(
                            hintText: "Add Todo",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            )),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          FirebaseFirestore.instance.collection('todos').add({
                            'todo': _controller.text,
                            'createdAt': Timestamp.now()
                          });
                          _controller.clear();
                        },
                        icon: const Icon(Icons.send))
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Padding _inputFields() => const Padding(padding: EdgeInsets.all(8.0));
}
