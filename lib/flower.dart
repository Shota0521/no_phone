import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Timerを使用するためにインポート
import 'package:shared_preferences/shared_preferences.dart';

class Flower extends StatefulWidget {
  final int t;
  final String selectedTag; // 選択されたタグを保持するための変数

  const Flower({super.key, required this.t, required this.selectedTag, required String focusText}); // selectedTagを追加

  @override
  _FlowerState createState() => _FlowerState();
}

class _FlowerState extends State<Flower> {
  late String imagePath;
  late Timer _timer;
  int tValue = 0;

  @override
  void initState() {
    super.initState();

    // SharedPreferencesからtValueを読み込む
    _loadTValue().then((value) {
      setState(() {
        tValue = value;
        imagePath = _getImagePath(tValue); // 画像パスを設定
      });
    });

    // 1時間ごとに画像を変更
    _timer = Timer.periodic(const Duration(seconds: 3600), (Timer t) {
      if (tValue < 6) { // tValueが6未満の場合のみ画像を変更
        setState(() {
          tValue++; // tValueを増やす
          imagePath = _getImagePath(tValue); // 新しい画像パスを取得
          _saveTValue(); // 状態を保存
        });
      } else {
        _timer.cancel(); // tValueが6になったらタイマーを停止
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // SharedPreferencesからtValueを読み込むメソッド
  Future<int> _loadTValue() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('tValue') ?? widget.t; // 保存されていない場合は初期値を使用
  }

  // SharedPreferencesにtValueを保存するメソッド
  Future<void> _saveTValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tValue', tValue);
  }

  String _getImagePath(int value) {
    // 選択されたタグに基づいて画像パスを設定
    String prefix;
    switch (widget.selectedTag) {
      case '国語':
        prefix = 'a';
        break;
      case '数学':
        prefix = 'b';
        break;
      case '英語':
        prefix = 'e';
        break;
      case '社会':
        prefix = 'h';
        break;
      case '理科':
        prefix = 'k';
        break;
      default:
        prefix = '1'; // デフォルトの場合
    }
    return 'images/$prefix$value.jpg'; // 連番の画像パス
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ花畑'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _timer.cancel(); // 戻る前にタイマーを停止
            _saveTValue(); // 状態を保存
            Navigator.of(context).pop(); // メイン画面に戻る
          },
        ),
      ),
      body: Center(
        child: Image.asset(imagePath), // 画像を表示
      ),
    );
  }
}
