import 'package:flutter/material.dart';
import 'package:todo/Task.dart';

import 'TODOState.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TODO());
  }
}


class TODO extends StatefulWidget {
  @override
  State<TODO> createState() => TODOState();
}

class TODOState extends State<TODO> {
  List<Task> tasks= [];
  List<Task> completedTasks = [];
  final counter = TextEditingController();
  GlobalKey <FormState> _formKey = GlobalKey <FormState>();

@override
void dispose() {
  counter.dispose();
  super.dispose();
}


  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.black;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('TODO APP'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListView.separated(
                itemBuilder: (context, i) {
                  return Container(
                    padding: EdgeInsets.all(20),
                    height: 60,
                    child: Row(
                      children: [
                        Text(tasks[i].task),
                        Spacer(),
                        Checkbox(
                          checkColor: Colors.red,
                          fillColor: MaterialStateProperty.resolveWith(
                              getColor),
                          value: tasks[i].isChecked,
                          onChanged: (bool? value) {
                            setState(() {
                              tasks[i].isChecked = value!;
                              if (tasks[i].isChecked == true) {
                                completedTasks.add(tasks[i]);
                              }
                              else {
                                completedTasks.remove(tasks[i]);
                              }
                            });
                          },
                        )
                      ],
                    ),
                  );
                },
                itemCount: tasks.length,
                shrinkWrap: true,
                separatorBuilder: (BuildContext context, int index) {
                  return Divider();
                },
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (BuildContext context) {
                        return CompletedTasks(completedTasks);
                      }));
                },
                child: Text("Done", style: TextStyle(color: Colors.white, fontSize: 25),),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: counter,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return " Please enter your task";
                          } else {
                            return null;
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter your task',
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: FloatingActionButton(
                          onPressed: addTask,
                          child: const Icon(Icons.add),
                          backgroundColor: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addTask() {
    setState(() {
      if (_formKey.currentState!.validate()) {
        tasks.add(Task(counter.text, false));
        counter.clear();
      }
      else {
        print("not valid");
      }
    });
  }
}
