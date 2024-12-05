import 'dart:async';
import 'package:flutter/material.dart';
import 'package:no_phone/Tm.dart';  // タイマーのモードを定義しているファイル
import 'package:no_phone/person.dart'; // TimerSettingsに依存するためインポート
import 'package:no_phone/flower.dart'; // flowerに依存するためインポート

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
  TimerMode mode = TimerMode.countdown; // タイマーのモード
  int hours = 0; // 時間
  int minutes = 0; // 分
  int seconds = 0; // 秒
  Timer? _timer; // Timerオブジェクト
  bool _isRunning = false; // タイマーが動作中かどうかを確認
  int _totalSeconds = 0; // タイマーの総秒数
  int _elapsedSeconds = 0; // 経過した秒数（カウントアップの場合）

  int t = 0;

  final TextEditingController _textController = TextEditingController();

  // タイマーのカウントダウンの更新
  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          if (_totalSeconds % 2 == 0) {
            if (t == 0) {
              t+=1;
              // 何かの条件で変更する場合
            } else {
              t -= 1;
            }


          }

          _totalSeconds--;
          print(_totalSeconds);
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  // カウントアップタイマーの更新
  void _startCountUpTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
      _elapsedSeconds = 0; // カウントアップは常に0からスタート
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++;
        print(_elapsedSeconds);
      });
    });
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
          print(_totalSeconds);
        });
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
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
                  MaterialPageRoute(builder: (context) => const TimerSettings()),
                );
                if (result != null) {
                  setState(() {
                    mode = result['mode']; // モードを設定
                    hours = result['hours']; // 時間を設定
                    minutes = result['minutes']; // 分を設定
                    seconds = result['seconds']; // 秒を設定
                    if (mode == TimerMode.countdown) {
                      _totalSeconds = (hours * 3600) + (minutes * 60) + seconds; // カウントダウン
                    } else if (mode == TimerMode.countup) {
                      _elapsedSeconds = 0; // カウントアップは常に0からスタート
                    } else if (mode == TimerMode.pomodoro) {
                      _totalSeconds = 25 * 60; // ポモドーロは25分
                    }
                  });
                }
              },
              child: Text(
                mode == TimerMode.countup
                    ? _formatTime(_elapsedSeconds) // カウントアップの時間表示
                    : _formatTime(_totalSeconds), // カウントダウンまたはポモドーロの時間表示
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 20),
            const Text('花の名前を入力:'),
            TextField(
              controller: _textController,
              decoration: InputDecoration(hintText: "集中したいテキストを入力"),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // 入力されたテキストを参照
                    String userInput = _textController.text;
                    print("ユーザーの入力: $userInput");
                    print(t);
                    // if (t == 0) {
                    //   // 何かの条件で変更する場合
                    // } else {
                    //   t -= 1;
                    // }

                    // タイマーのモードに応じてスタート処理
                    setState(() {
                      if (mode == TimerMode.countdown) {
                        _startTimer(); // カウントダウンタイマー開始
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
              icon: const Icon(
                Icons.person_outline,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const person()),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.access_alarms,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TimerSettings()),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.eco,
                color: Colors.blue,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Flower(t: t)), // 修正されたクラス名
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}