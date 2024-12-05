import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialMode;
    _hours = widget.initialHours;
    _minutes = widget.initialMinutes;
    _seconds = widget.initialSeconds;
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
                    fontSize: 24,
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
                });
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
