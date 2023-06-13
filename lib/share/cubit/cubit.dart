import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/share/cubit/states.dart';
import 'package:todo_app/ui/archive_task/archive_task_screen.dart';
import 'package:todo_app/ui/done_task/done_task_screen.dart';
import 'package:todo_app/ui/new_task/new_task_screen.dart';



class AppCubit extends Cubit<AppStates> {

  AppCubit() : super(AppInitialState());

  static AppCubit get(BuildContext context) => BlocProvider.of(context) ;

  int currentIndex = 0;
  late Database database;
  List<Map<dynamic,dynamic>> newTasks = [];
  List<Map<dynamic,dynamic>> doneTasks = [];
  List<Map<dynamic,dynamic>> archivedTasks = [];
  bool fbPressed = false;
  IconData mainIcon = Icons.edit;



  List<Widget> screens = [
    NewTasksScreen(),
    ArchivedTasks(),
    DoneTasks(),
  ];

  List<String> titles = ['New Tasks', 'Archived Tasks', 'Done Tasks'];

  void changeIndex(int index){
    currentIndex = index;
    emit(AppChangedBottomNavState());
  }

  void changeBottomSheetState({
    @required bool? isShow,
    @required IconData? icon
  }){
    fbPressed = isShow!;
    mainIcon = icon!;
    emit(AppChangedBottomSheetState());
  }

  // ignore: invalid_required_named_param
  void createDatabase(){
    openDatabase(
      'tasks.db',
      version: 1,
      onCreate: (database, version) {
        database
            .execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)',
        )
            .then((value) {
          print('2.Table is created');
        }).catchError((error) {
          print('The error is $error');
        });
        print('1.Database is created');
      },
      onOpen: (database) {
        print('3.Database is opened');
        getFromDatabase(database);
      },
    ).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

  insertIntoDatabase({
    @required String taskName = " ",
    @required String date = " ",
    @required String time = " ",

  }) async {
    await database.transaction((txn) {
      return txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$taskName", "$date", "$time", "New")'
      ).then((value) {
        print("A new Row is inserted: $value");
        emit(AppInsertDatabaseState());
        getFromDatabase(database);
      }).catchError((error) {
        print('This error is caught will inserting a new row ${error.toString()}');
      });
    });
  }

  void getFromDatabase(Database database){
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element) {
        if(element['status'] == 'New'){
          newTasks.add(element);//used = before because i got all of the list once and equal it
        }else if(element['status'] == 'Done'){
          doneTasks.add(element);
        }else{
          archivedTasks.add(element);
        }
      });
      emit(AppGetDatabaseState());
    });
  }

  void updateDatabase({
    @required String? status,
    @required int? id,
  }) async{
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',//list of values (new values(update values))
        ['$status' , id]
    ).then((value) {
      getFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }

  void deleteData({
    @required int? id,
  }) async{
    database.rawDelete(
      'DELETE FROM tasks WHERE id = ?', [id],
    ).then((value) {
      getFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }
}

