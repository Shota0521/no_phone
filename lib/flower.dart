import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Timerを使用するためにインポート

class Flower extends StatefulWidget {
  final int t;

  const Flower({super.key, required this.t});

  @override
  _FlowerState createState() => _FlowerState();
}

class _FlowerState extends State<Flower> {
  late String imagePath;
  late Timer _timer;
  int tValue = 0; // インクリメントする`t`の値

  @override
  void initState() {
    super.initState();

    // `t` に基づいた画像パスを設定
    imagePath = 'images/${widget.t}.png';
    tValue = widget.t; // 初期値として渡された`t`を設定

    // 5秒ごとにtValueをインクリメント
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer t) {
      setState(() {
        tValue++; // 5秒ごとにtValueをインクリメント
        if(tValue>12){
          tValue=0;
        }
        imagePath = 'images/$tValue.png'; // インクリメントされた`tValue`に基づいて画像パスを更新

      });
    });
  }

  @override
  void dispose() {
    // Timerを停止
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイ花畑'),
      ),
      body: Center(
        child: FutureBuilder(
          // 画像が存在するか確認するための非同期処理
          future: _imageExists(imagePath),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError || !snapshot.data!) {
              // 画像が存在しない場合、デフォルト画像を表示
              return Image.asset('images/1.png');
            } else {
              // 画像が存在する場合、指定された画像を表示
              return Image.asset(imagePath);
            }
          },
        ),
      ),
    );
  }

  // 画像ファイルが存在するか確認する非同期メソッド
  Future<bool> _imageExists(String path) async {
    try {
      // 画像が存在するか確認する処理（パスに基づく検証）
      final result = await rootBundle.load(path);
      return true;  // 画像が存在する場合はtrueを返す
    } catch (e) {
      return false;  // 画像が存在しない場合はfalseを返す
    }
  }
}