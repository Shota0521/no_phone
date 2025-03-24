import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TimerMode {
  countdown,
  countup,
  pomodoro
}

class TimerSettings extends StatefulWidget {
  final TimerMode initialMode;
  final int initialHours;
  final int initialMinutes;
  final int initialSeconds;

  const TimerSettings({
    super.key,
    this.initialMode = TimerMode.countdown,
    this.initialHours = 0,
    this.initialMinutes = 0,
    this.initialSeconds = 0,
  });

  @override
  State<TimerSettings> createState() => _TimerSettingsState();
}

class _TimerSettingsState extends State<TimerSettings> {
  late TimerMode _selectedMode;
  late int _hours;
  late int _minutes;
  late int _seconds;
  late String _selectedTag; // 選択されたタグを保持する変数

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
    _selectedTag = ''; // 初期タグを設定（必要に応じて変更可能）
  }

  // 設定の保存
  Future<void> _saveSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('mode', _selectedMode.index);
    await prefs.setInt('hours', _hours);
    await prefs.setInt('minutes', _minutes);
    await prefs.setInt('seconds', _seconds);
    await prefs.setString('tag', _selectedTag); // 選択されたタグを保存
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('タイマー設定'),
      ),
      body: Column(
        children: [
          // タイマーモード選択
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SegmentedButton<TimerMode>(
              segments: const [
                ButtonSegment(
                  value: TimerMode.countdown,
                  label: Text('カウントダウン'),
                ),
                ButtonSegment(
                  value: TimerMode.countup,
                  label: Text('カウントアップ'),
                ),
                ButtonSegment(
                  value: TimerMode.pomodoro,
                  label: Text('ポモドーロ'),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (Set<TimerMode> newSelection) {
                setState(() {
                  _selectedMode = newSelection.first;
                });
              },
            ),
          ),

          // 時間設定
          Expanded(
            child: CupertinoTheme(
              data: const CupertinoThemeData(
                textTheme: CupertinoTextThemeData(
                  pickerTextStyle: TextStyle(
                    color: Colors.black, fontSize: 24,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          _hours = value;
                        });
                      },
                      children: List<Widget>.generate(24, (int index) {
                        return Center(child: Text('${index}時間'));
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          _minutes = value;
                        });
                      },
                      children: List<Widget>.generate(60, (int index) {
                        return Center(child: Text('${index}分'));
                      }),
                    ),
                  ),
                  Expanded(
                    child: CupertinoPicker(
                      itemExtent: 32,
                      onSelectedItemChanged: (int value) {
                        setState(() {
                          _seconds = value;
                        });
                      },
                      children: List<Widget>.generate(60, (int index) {
                        return Center(child: Text('${index}秒'));
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // タグの選択 (追加)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: PopupMenuButton<String>(
              onSelected: (String value) {
                setState(() {
                  _selectedTag = value; // 選択されたタグを更新
                });
              },
              itemBuilder: (BuildContext context) {
                return ['国語', '数学', '英語', '社会', '理科'].map((String tag) {
                  return PopupMenuItem<String>(
                    value: tag,
                    child: Text(tag),
                  );
                }).toList();
              },
              child: Row(
                children: const [
                  Icon(Icons.label),
                  SizedBox(width: 8),
                  Text('タグを選択'),
                ],
              ),
            ),
          ),
          // 設定ボタン
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // 設定した時間を返す
                Navigator.pop(context, {
                  'mode': _selectedMode,
                  'hours': _hours,
                  'minutes': _minutes,
                  'seconds': _seconds,
                  'tag': _selectedTag,
                });
                _saveSettings(); // 設定を保存
              },
              child: const Text('設定を保存'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
