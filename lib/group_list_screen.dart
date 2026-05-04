import 'package:flutter/material.dart';
import 'database_helper.dart';



class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});
  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  @override
  void initState() {
    super.initState();
    _refreshGroups();
  }

  void _refreshGroups() async {
    var data = await DbHelper.getGroups();
    setState(() {
      groups = data;
    });
  }
  List<String> groups = [];
  final TextEditingController _controller = TextEditingController();

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white12,
        title: const Text(
          'Добавить группу',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: _controller,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              String newItem = _controller.text.trim();

              if (newItem.isNotEmpty) {
                await DbHelper.addGroup(newItem);

                if (!mounted) return;
                _refreshGroups();
                _controller.clear();
              }
              navigator.pop();
            },
            child: const Text('Добавить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, String groupName, Function onDelete) async {

    return showDialog<void>(

      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {

        return AlertDialog(

          backgroundColor: Colors.white12,
          title: const Text('Подтверждение'),
          content: Text('Удалить группу "$groupName" и всех её студентов?'),
          actions: <Widget>[

            TextButton(

              child: const Text('Отмена', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(),
            ),

            TextButton(

              child: const Text('Удалить', style: TextStyle(color: Colors.red)),
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

    final String role = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(

      backgroundColor: Color(0xFF002F35),
      appBar: AppBar(

        backgroundColor: Color(0xFF002F35),
        leading: BackButton(

          onPressed: () {

            Navigator.pop(context);
          },
          color: Colors.white,
        ),

        actions: [

          if (role == 'elder')
            IconButton(

              color: Colors.white,
              icon: const Icon(Icons.add),
              onPressed: _addItem,
            ),
        ],

        title: const Text(

          "Выберите группу",
          style: TextStyle(

            color: Colors.white,
            fontSize: 29,
            fontFamily: "Times New Roman",
          ),
        ),
        elevation: 0.6,
      ),

      body: ListView.builder(

        padding: const EdgeInsets.all(16),
        itemCount: groups.length,
        itemBuilder: (context, index) {

          final String currentGroupName = groups[index];
          return Card(

            color: const Color(0xFFF7B538),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(

              title: Text(

                groups[index],
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),

              trailing: role == 'elder'
                  ? IconButton(

                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {

                  _confirmDelete(context, currentGroupName, () async {
                    await DbHelper.deleteGroup(currentGroupName);
                    _refreshGroups();
                  });
                },
              )
                  : null,
              onTap: () {

                Navigator.pushNamed(context, 'StudentsList',
                  arguments: {
                    'role': role,
                    'groupName': groups[index]
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
