  import 'package:flutter/material.dart';

  import 'package:cursive_app/students_list_screen.dart';
  import 'package:cursive_app/group_list_screen.dart';


  void main() => runApp(const MyApp());

  class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        theme: ThemeData(brightness: Brightness.dark,),

        routes: {
          'GroupList': (context) => const GroupListScreen(),
          'StudentsList': (context) => const StudentListScreen(),
        },
        debugShowCheckedModeBanner: false,

        home: const HomeScreen(),
      );
    }
  }

  class HomeScreen extends StatelessWidget {
    const HomeScreen({super.key});
    @override
    Widget build(BuildContext context) {
      return Scaffold(backgroundColor: Color(0xFF002F35),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  alignment: const Alignment(0, -0.6),
                  child: const Text(
                    "Учет посещаемости",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                alignment: const Alignment(0, -0.7),
                child: const Text(
                  "Выберите роль",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          'GroupList',
                          arguments: 'elder',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF7B538),
                      ),
                      child: const Text(
                        "Староста",
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          'GroupList',
                          arguments: 'student',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:const Color(0xFFF7B538),
                      ),
                      child: const Text(
                        "Студент",
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
