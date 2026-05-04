import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'database_helper.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});
  @override
  State<StudentListScreen> createState() => _Lists();
}

class _Lists extends State<StudentListScreen> {
  late String selectedDate = _formatDate(DateTime.now());
  int selectedLesson = 1;
  String groupName = '';
  List<Map<String, dynamic>> students = [];

  String _formatDate(DateTime date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<void> _loadFromDb() async {
    if (groupName.isEmpty) return;

    final allNames = await DbHelper.getAllStudentNamesInGroup(groupName);

    final statusResults = await DbHelper.loadStudents(groupName, selectedDate, selectedLesson);
    Map<String, String> statuses = {
      for (var item in statusResults)
        item['student_name'].toString(): item['status'].toString()
    };

    setState(() {
      students = allNames.map((name) {
        String currentStatus = statuses[name] ?? '';

        return {
          'name': name,
          'status': currentStatus.isEmpty ? 'Б' : currentStatus
        };
      }).toList();
    });
  }

  Future<void> _importFromExcel() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['xlsx']);
    if (result != null) {
      var bytes = File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);
      for (var table in excel.tables.keys) {
        for (var row in excel.tables[table]!.rows) {
          if (row.isEmpty || row[0] == null) continue;
          String name = row[0]!.value.toString().replaceAll(RegExp(r'.*?\(|\)'), '').trim();
          if (name != "null" && name.isNotEmpty) {
            await DbHelper.saveStudentStatus(groupName, name, '', selectedDate, selectedLesson);
          }
        }
      }
      _loadFromDb();
    }
        }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (builder) => SizedBox(
        height: 380,
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                setState(() => selectedDate = _formatDate(DateTime.now()));
                _loadFromDb();
                Navigator.pop(context);
              },
              child: const Text("Сегодня", style: TextStyle(color: Color(0xFFF7B538))),
            ),
            SizedBox(
              height: 300,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                onDateTimeChanged: (DateTime picked) {
                  setState(() => selectedDate = _formatDate(picked));
                  _loadFromDb();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteStudent(BuildContext context, String studentName, Function onDelete) async {

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {


        return AlertDialog(
          backgroundColor: const Color(0xFF233F43),


          title: const Text('Удаление студента', style: TextStyle(color: Colors.white)),
          content: Text('Вы уверены, что хотите удалить студента " $studentName " из списка?',
              style: const TextStyle(color: Colors.white)),
          actions: <Widget>[

            TextButton(

              child: const Text('Отмена', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),

            TextButton(

              child: const Text('Удалить', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                onDelete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  @override

  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String role = args?['role'] ?? 'student';
    if (groupName.isEmpty) {

      groupName = args?['groupName'] ?? '';
      _loadFromDb();
    }

    return Scaffold(

      backgroundColor: const Color(0xFF002F35),
      appBar: AppBar(

        backgroundColor: Colors.black12,
        title: const Text("Список студентов", style: TextStyle(color: Colors.white, fontSize: 28, fontFamily: "Times New Roman")),
        leading: BackButton(onPressed: () => Navigator.pop(context), color: Colors.white),
        actions: [

          if (role == 'elder') IconButton(icon: const Icon(Icons.download,
              color: Colors.white), onPressed: _importFromExcel),
        ],
      ),

      body: Column(

        children: [

          Padding(

            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(

                  children: [

                    Text("Дата: $selectedDate", style: const TextStyle(color: Colors.white, fontSize: 16)),
                    IconButton(icon: const Icon(Icons.calendar_today, color: Colors.white, size: 20), onPressed: _showDatePicker),
                  ],
                ),
                PopupMenuButton<int>(

                  onSelected: (val) { setState(() => selectedLesson = val); _loadFromDb(); },
                  child: Container(

                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: const Color(0xFFF7B538), borderRadius: BorderRadius.circular(8)),
                    child: Text("$selectedLesson пара", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                  ),
                  itemBuilder: (ctx) => [1,2,3,4,5,6].map((l) => PopupMenuItem(value: l, child: Text("$l пара"))).toList(),
                )
              ],
            ),
          ),

          Expanded(

            child: ListView.builder(

              itemCount: students.length,
              itemBuilder: (context, index) {

                return Card(

                  color: const Color(0xFFF7B538),
                  margin: const EdgeInsets.all(8),
                  child: ListTile(

                    leading: role == 'elder' ? Row(

                      mainAxisSize: MainAxisSize.min,
                      children: [

                        _buildStatusButton(index, "Б", const Color(0xFFA3F81C)),
                        _buildStatusButton(index, "НБ", const Color(0xFFF0485F)),
                        _buildStatusButton(index, "ОП", const Color(0xfffb6100)),
                      ],
                    ) : null,

                    title: Text(students[index]['name'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    subtitle: Text("Статус: ${students[index]['status']}", style: const TextStyle(color: Colors.black)),
                    trailing: role == 'elder' ? IconButton(

                      icon: const Icon(Icons.close, color: Color(0xFFFEFFAF)),
                      onPressed: () {

                        final String currentStudentName = students[index]['name'];
                        _confirmDeleteStudent(context, currentStudentName, () async {

                          await DbHelper.deleteStudent(groupName, currentStudentName);
                          _loadFromDb();
                        });
                      },
                    ) : null,

                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(int idx, String text, Color col) {

    bool isSelected = students[idx]['status'] == text;
    return GestureDetector(

      onTap: () async {

        setState(() => students[idx]['status'] = text);
        await DbHelper.saveStudentStatus(groupName, students[idx]['name'], text, selectedDate, selectedLesson);
      },

      child: Container(

        margin: const EdgeInsets.only(right: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: isSelected ? col : const Color(0xFFFEFFAF), borderRadius: BorderRadius.circular(5)),
        child: Text(text, style: const TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
      ),
    );
  }
}