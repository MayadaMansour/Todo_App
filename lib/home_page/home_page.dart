
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/share/componants/componant.dart';
import 'package:todo_app/share/cubit/cubit.dart';
import 'package:todo_app/share/cubit/states.dart';


class HomePage extends StatelessWidget {

  var keyScaffold = GlobalKey<ScaffoldState>();
  var keyForm = GlobalKey<FormState>();
  var textController = TextEditingController();
  var timerController = TextEditingController();
  var dayController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..CreateDataBase(),
      child: BlocConsumer<AppCubit, AppStates>(
        listener: (context, state) {
          if(state is InsertDataBaseState){
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return Scaffold(
            key: keyScaffold,
            appBar: AppBar(
              title: Text(
                AppCubit.get(context).title[AppCubit.get(context).currentIndex],
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold),
              ),
            ),
            body: ConditionalBuilder(
              condition: state is! GetDataBaseLoadingState,
              builder: (context) =>AppCubit.get(context).screen[AppCubit.get(context).currentIndex],
              fallback: (context) => Center(child: CircularProgressIndicator()),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(AppCubit.get(context).fabIcon),
              onPressed: () {
                if (AppCubit.get(context).showSheet) {
                  if (keyForm.currentState!.validate()) {
                    AppCubit.get(context).InsertDataBase(title:textController.text , date: dayController.text, time: timerController.text);
                  }
                } else {
                  keyScaffold.currentState!
                      .showBottomSheet(
                          (context) => Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(20),
                                child: Form(
                                  key: keyForm,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      defaultTextFeild(
                                        controller: textController,
                                        type: TextInputType.text,
                                        labelText: 'Task Title',
                                        prefix: Icons.title,
                                        validate: (value) {
                                          if (value!.isEmpty) {
                                            return 'title must not be empty';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      defaultTextFeild(
                                        controller: timerController,
                                        type: TextInputType.datetime,
                                        labelText: 'Task Time',
                                        prefix: Icons.more_time,
                                        onTap: () {
                                          showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          ).then((value) {
                                            timerController.text = value!
                                                .format(context)
                                                .toString();
                                          });
                                        },
                                        validate: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter the Time';
                                          }
                                          return null;
                                        },
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      defaultTextFeild(
                                          controller: dayController,
                                          type: TextInputType.datetime,
                                          prefix: Icons.calendar_today,
                                          labelText: "Task Day",
                                          validate: (value) {
                                            if (value!.isEmpty) {
                                              return 'Please enter the Time';
                                            }
                                            return null;
                                          },
                                          onTap: () {
                                            showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime.now(),
                                                    firstDate: DateTime.now(),
                                                    lastDate: DateTime.parse(
                                                        "2023-08-20"))
                                                .then((value) {
                                              dayController.text = DateFormat()
                                                  .add_yMMMd()
                                                  .format(value!);
                                            });
                                          })
                                    ],
                                  ),
                                ),
                              ),
                          elevation: 15)
                      .closed
                      .then((value) {
                        AppCubit.get(context).bottomSheetState(isShow: false, icon: Icons.edit);
                  });
                  AppCubit.get(context).bottomSheetState(isShow: true, icon: Icons.add);
                }
              },
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: AppCubit.get(context).currentIndex,
              onTap: (index) {
                AppCubit.get(context).changeIndex(index);
              },
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.menu),
                  label: "Tasks",
                ),
                BottomNavigationBarItem(
                    icon: Icon(Icons.done_outline), label: "Done"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.archive_outlined), label: "Archive"),
              ],
            ),
          );
        },
      ),
    );
  }




}
