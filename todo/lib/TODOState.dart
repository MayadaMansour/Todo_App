import 'package:flutter/material.dart';

import 'Task.dart';

class CompletedTasks extends StatefulWidget {
  List<Task> list;

  CompletedTasks(this.list) {}

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  @override
  Widget build(BuildContext context) {
    TextStyle style = TextStyle(color: Colors.black, fontSize: 15);
    return Scaffold(
        appBar:
            AppBar(backgroundColor: Colors.indigo, title: Text("Done")),
        body: Center(
            child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ListView.separated(
                  itemBuilder: (context, i) {
                    return Container(
                      padding: EdgeInsets.all(10),
                      height: 50,
                      //color: Colors.indigo[300],
                      child: Text(widget.list[i].task, style: style),
                    );
                  },
                  itemCount: widget.list.length,
                  shrinkWrap: true,
                  separatorBuilder: (BuildContext context, int index) {
                    return Divider();
                  },
                )
              ]),
        )));
  }
}
