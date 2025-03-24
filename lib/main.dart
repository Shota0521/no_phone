import 'dart:async';
import 'package:flutter/material.dart';
import 'package:no_phone/Tm.dart';  // タイマーのモードを定義しているファイル
import 'package:no_phone/person.dart'; // TimerSettingsに依存するためインポート
import 'package:no_phone/flower.dart'; // flowerに依存するためインポート
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSONデコードに必要

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'no_phone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'no_phone'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimerMode mode = TimerMode.countdown;
  int hours = 0; // 時間
  int minutes = 0; // 分
  int seconds = 0; // 秒
  Timer? _timer;
  bool _isRunning = false;
  int _totalSeconds = 0;
  int _elapsedSeconds = 0;
  int t = 0;
  final TextEditingController _textController = TextEditingController();

  // タグの種類を定義
  final List<String> tags = ['国語', '数学', '英語', '社会', '理科'];
  String? _selectedTag; // 選択されたタグを保持する変数

  @override
  void initState() {
    super.initState();
    _loadSettings(); // 設定をロード
    _incrementAppLaunchCount(); // アプリ起動回数をインクリメント
  }

  // 設定の読み込み
  Future<void> _loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mode = TimerMode.values[prefs.getInt('mode') ?? 0];
      hours = prefs.getInt('hours') ?? 0;
      minutes = prefs.getInt('minutes') ?? 0;
      seconds = prefs.getInt('seconds') ?? 0;
      _selectedTag = prefs.getString('tag') ?? tags[0]; // デフォルトタグを設定
      _textController.text = prefs.getString('focusText') ?? ''; // 集中したいテキストを設定
    });
    // タイマーモードに応じた初期設定
    if (mode == TimerMode.countdown) {
      _totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
    } else if (mode == TimerMode.countup) {
      _elapsedSeconds = 0;
    } else if (mode == TimerMode.pomodoro) {
      _totalSeconds = 25 * 60;
    }
  }

  // 設定の保存
  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mode', mode.index);
    await prefs.setInt('hours', hours);
    await prefs.setInt('minutes', minutes);
    await prefs.setInt('seconds', seconds);
    await prefs.setString('tag', _selectedTag ?? '');
    await prefs.setString('focusText', _textController.text); // 集中したいテキストを保存
  }

  // タイマーのカウントダウンの更新
  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });

    _saveSettings(); // 設定を保存
    _addTimerHistory(); // タイマー履歴を追加
  }

  // タイマーのカウントアップの更新
  void _startCountUpTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _elapsedSeconds = 0; // カウントアップは常に0からスタート
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
      });
    });

    _saveSettings(); // 設定を保存
    _addTimerHistory(); // タイマー履歴を追加
  }

  // ポモドーロタイマーの動作（25分間カウントダウン）
  void _startPomodoroTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _totalSeconds = 25 * 60; // ポモドーロは25分（1500秒）からスタート
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });

    _saveSettings(); // 設定を保存
    _addTimerHistory(); // タイマー履歴を追加
  }

  // 時間のフォーマット（時間, 分, 秒）
  String _formatTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ストップボタンの処理
  void _stopTimer() {
    if (_timer != null) {
      _timer?.cancel();
    }
    setState(() {
      _isRunning = false;
    });
  }

  // リセットボタンの処理
  void _resetTimer() {
    setState(() {
      _isRunning = false;
      if (mode == TimerMode.countdown) {
        _totalSeconds = (hours * 3600) + (minutes * 60) + seconds; // カウントダウンの時間を設定
      } else if (mode == TimerMode.countup) {
        _elapsedSeconds = 0; // カウントアップの秒数をリセット
      } else if (mode == TimerMode.pomodoro) {
        _totalSeconds = 25 * 60; // ポモドーロの時間をリセット（25分）
      }
    });
    _timer?.cancel();
  }

  // アプリ起動回数のインクリメント
  Future<void> _incrementAppLaunchCount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int appLaunchCount = prefs.getInt('appLaunchCount') ?? 0;
    await prefs.setInt('appLaunchCount', appLaunchCount + 1);
  }

  // タイマー履歴の追加
  Future<void> _addTimerHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> timerHistoryList = prefs.getStringList('timerHistoryList') ?? [];

    // 新しいタイマー履歴をJSON形式の文字列として保存
    String newHistory = '{"mode": ${mode.index}, "hours": $hours, "minutes": $minutes, "seconds": $seconds, "tag": "${_selectedTag ?? ""}", "focusText": "${_textController.text}", "startTime": "${DateTime.now().toIso8601String()}"}';
    timerHistoryList.add(newHistory);
    await prefs.setStringList('timerHistoryList', timerHistoryList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // TimerSettings画面を開き、設定を変更する
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimerSettings(
                    // 初期値として現在の設定を渡す
                    initialMode: mode,
                    initialHours: hours,
                    initialMinutes: minutes,
                    initialSeconds: seconds,
                  )),
                );
                if (result != null) {
                  setState(() {
                    mode = result['mode'];
                    hours = result['hours'];
                    minutes = result['minutes'];
                    seconds = result['seconds'];
                    _selectedTag = result['tag']; // 選択されたタグを取得
                    // タイマーモードに応じた初期設定
                    if (mode == TimerMode.countdown) {
                      _totalSeconds = (hours * 3600) + (minutes * 60) + seconds;
                    } else if (mode == TimerMode.countup) {
                      _elapsedSeconds = 0;
                    } else if (mode == TimerMode.pomodoro) {
                      _totalSeconds = 25 * 60;
                    }
                  });
                  _saveSettings(); // 設定を保存
                }
              },
              child: Text(
                mode == TimerMode.countup
                    ? _formatTime(_elapsedSeconds)
                    : _formatTime(_totalSeconds),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            const Text('花の名前を入力:'),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(hintText: "集中したいテキストを入力"),
            ),
            const SizedBox(height: 20),
            // スプリットボタン（ドロップダウンリスト）
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  onSelected: (String value) {
                    setState(() {
                      _selectedTag = value; // 選択されたタグを更新
                    });
                    print('選択されたタグ: $_selectedTag');
                  },
                  itemBuilder: (BuildContext context) {
                    return tags.map((String tag) {
                      return PopupMenuItem<String>(
                        value: tag,
                        child: Text(tag),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    String userInput = _textController.text;
                    print("ユーザーの入力: $userInput");

                    // タイマーのモードに応じてスタート処理
                    setState(() {
                      if (mode == TimerMode.countdown) {
                        _startTimer();
                      } else if (mode == TimerMode.countup) {
                        _startCountUpTimer(); // カウントアップタイマー開始
                      } else if (mode == TimerMode.pomodoro) {
                        _startPomodoroTimer(); // ポモドーロタイマー開始
                      }
                    });
                  },
                  child: const Text('スタート'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _stopTimer,
                  child: const Text('ストップ'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('リセット'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).primaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.person_outline, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const person()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.access_alarms, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimerSettings(
                    // 初期値として現在の設定を渡す
                    initialMode: mode,
                    initialHours: hours,
                    initialMinutes: minutes,
                    initialSeconds: seconds,
                  )),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.eco, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Flower(t: t, selectedTag: _selectedTag ?? '', focusText: _textController.text)), // 選択されたタグと集中したいテキストをflowerに渡す
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
