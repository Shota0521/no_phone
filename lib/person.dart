import 'package:flutter/material.dart';

class person extends StatelessWidget {
  const person({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('アカウント'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('アカウント名'),
            subtitle: const Text('未設定'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  String newUsername = '';
                  return AlertDialog(
                    title: const Text('アカウント設定'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration: const InputDecoration(
                              labelText: 'ユーザー名',
                              hintText: '新しいユーザー名を入力',
                            ),
                            onChanged: (value) {
                              newUsername = value;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text('アプリ起動日数: 0日'),
                          const Text('タイマー実行回数: 0回'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('キャンセル'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('保存'),
                        onPressed: () {
                          // TODO: ユーザー名を保存する処理を実装
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('タイマー設定'),
            subtitle: const Text('デフォルト'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // タイマー設定画面への遷移処理
            },
          ),
        ],
      ),
    );
  }
}