import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'Tm.dart'; // タイマーのモードを定義しているファイル

class person extends StatefulWidget {
  const person({super.key});

  @override
  _personState createState() => _personState();
}

class _personState extends State<person> {
  late List<Map<String, dynamic>> _timerHistoryList; // タイマー履歴リストを保持する変数
  int _appLaunchCount = 0; // アプリ起動回数を保持する変数
  int _startButtonPressCount = 0; // タイマースタートボタンの押下回数を保持する変数

  @override
  void initState() {
    super.initState();
    _loadTimerHistoryList(); // タイマー履歴リストをロード
    _loadCounts(); // アプリ起動回数とタイマースタートボタン押下回数をロード
  }

  // タイマー履歴リストの読み込み
  Future<void> _loadTimerHistoryList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? historyList = prefs.getStringList('timerHistoryList') ?? [];
    setState(() {
      _timerHistoryList = historyList.map((history) => jsonDecode(history) as Map<String, dynamic>).toList();
    });
  }

  // アプリ起動回数とタイマースタートボタン押下回数の読み込み
  Future<void> _loadCounts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _appLaunchCount = prefs.getInt('appLaunchCount') ?? 0;
      _startButtonPressCount = prefs.getInt('startButtonPressCount') ?? 0;
    });
  }

  // 時間のフォーマット（時間, 分, 秒）
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

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
                          Text('アプリ起動日数: $_appLaunchCount日'),
                          Text('タイマー実行回数: $_startButtonPressCount回'),
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
                        onPressed: () async {
                          // ユーザー名を保存する処理を実装
                          final SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.setString('username', newUsername);
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('タイマー履歴'),
            subtitle: const Text('過去のタイマー履歴'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // タイマー履歴画面への遷移処理
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimerHistoryScreen(timerHistoryList: _timerHistoryList)),
              );
            },
          ),
        ],
      ),
    );
  }
}

// タイマー履歴詳細を表示する画面
class TimerHistoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> timerHistoryList;

  const TimerHistoryScreen({super.key, required this.timerHistoryList});

  // 時間のフォーマット（時間, 分, 秒）
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タイマー履歴'),
      ),
      body: ListView.builder(
        itemCount: timerHistoryList.length,
        itemBuilder: (context, index) {
          final history = timerHistoryList[index];
          final mode = TimerMode.values[history['mode'] as int];
          final focusText = history['focusText'] as String;
          final tag = history['tag'] as String;
          final hours = history['hours'] as int;
          final minutes = history['minutes'] as int;
          final seconds = history['seconds'] as int;
          final totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
          final startTime = DateTime.parse(history['startTime'] as String);

          return ListTile(
            leading: const Icon(Icons.timer),
            title: Text(focusText),
            subtitle: Text('タグ: $tag, スタート時間: ${startTime.toString()}'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('タイマー詳細'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('選択テキスト: $focusText'),
                          const SizedBox(height: 10),
                          Text('タグ: $tag'),
                          const SizedBox(height: 10),
                          Text('タイマーモード: ${mode.toString().split('.').last}'),
                          const SizedBox(height: 10),
                          Text('時間: ${_formatTime(totalSeconds)}'),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('閉じる'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
