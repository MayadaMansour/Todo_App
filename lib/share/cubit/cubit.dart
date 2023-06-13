import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/share/cubit/states.dart';
import 'package:todo_app/ui/archive_task/archive_task_screen.dart';
import 'package:todo_app/ui/done_task/done_task_screen.dart';
import 'package:todo_app/ui/new_task/new_task_screen.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(InitialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int currentIndex = 0;
  Database? database;
  bool showSheet = false;
  IconData fabIcon = Icons.edit;
  List<Widget> screen = [
    NewTaskScreen(),
    DoneTaskScreen(),
    ArchiveTaskScreen()
  ];
  List<String> title = ["New Tasks", "Done Tasks", "Archived Tasks"];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archiveTasks = [];




  void changeIndex(int index) {
    currentIndex = index;
    emit(ChangeNavBar());
  }

  void bottomSheetState({required bool isShow, required IconData icon}) {
    fabIcon = icon;
    showSheet = isShow;
    emit(BottomSheetState());
  }

  void CreateDataBase() {
    openDatabase("todo.db", version: 1, onCreate: (database, version) {
      database
          .execute(
              "CREATE TABLE tasks (id INTEGER PRIMER KEY,title TEXT,date TEXT,time TEXT,status TEXT)")
          .then((value) {})
          .catchError((error) {});
    }, onOpen: (database) {
      getDataBase(database);
    }).then((value) {
      database = value;
      emit(CreateDataBaseState());
    });
  }



  InsertDataBase({
    required String title,
    required String time,
    required String date,
  }) async {
    await database!.transaction((txn) async {
      txn
          .rawInsert(
        'INSERT INTO tasks(title, date, time, status) VALUES("$title", "$date", "$time", "new")',
      )
          .then((value) {
        print('$value inserted successfully');
        emit(InsertDataBaseState());

        getDataBase(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });

      return null;
    });
  }



  void getDataBase(database)
  {
    newTasks = [];
    doneTasks = [];
    archiveTasks = [];

    emit(GetDataBaseLoadingState());

    database.rawQuery('SELECT * FROM tasks').then((value) {

      value.forEach((element)
      {
        if(element['status'] == 'new')
          newTasks.add(element);
        else if(element['status'] == 'done')
          doneTasks.add(element);
        else archiveTasks.add(element);
      });

      emit(GetDataBaseState());
    });
  }

  void updateDataBase({
    required String status,
    required  int id,
  }) async
  {
    database!.rawUpdate(
      'UPDATE tasks SET status = ? WHERE id = ?',
      ['$status', id],
    ).then((value)
    {
      getDataBase(database);
      emit(UpdateDataBaseState());
    });
  }


  void deleteDataBase({
    required int id,
  }) async
  {
    database!.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value)
    {
      getDataBase(database);
      emit(DeletDataBaseState());
    });
  }


}
