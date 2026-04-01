# CLAUDE.md - Burner List App

## プロジェクト概要
「バーナーリスト」メソッドに基づくタスク管理Flutterアプリ。コンロの火口の比喩でタスクの優先度を管理する。

## 技術スタック
- **Flutter** (Dart 3.8.1+)
- **状態管理**: flutter_riverpod (NotifierProvider パターン)
- **永続化**: SharedPreferences (JSON シリアライズ)
- **フォント**: Google Fonts (Outfit)
- **ID生成**: uuid

## プロジェクト構成
```
lib/
├── main.dart                    # エントリポイント、テーマ設定
├── models/task_model.dart       # Task データモデル (toMap/fromJson)
├── providers/
│   ├── task_provider.dart       # タスク状態管理 (TaskNotifier)
│   └── settings_provider.dart   # アプリ設定 (テーマ等)
├── screens/
│   ├── home_screen.dart         # メインタスクボード
│   └── settings_screen.dart     # 設定画面
├── services/
│   └── storage_service.dart     # SharedPreferences ラッパー
└── widgets/
    ├── burner_section.dart      # 単一タスク表示 (Front/Back Burner)
    ├── sink_list.dart           # 複数タスクリスト (Counter Space/Kitchen Sink)
    ├── task_note_dialog.dart    # メモ編集ダイアログ
    └── fresh_start_dialog.dart  # リセットダイアログ
```

## タスクの優先度カテゴリ
- **Front Burner**: 最優先タスク (1件のみ)
- **Back Burner**: 次の優先タスク (1件のみ)
- **Counter Space**: アイデア・保留 (複数可)
- **Kitchen Sink**: バックログ (複数可)

## アーキテクチャ
- Riverpod の `NotifierProvider` で状態管理
- 不変データモデル (copyWith パターン)
- 状態変更時に自動で SharedPreferences へ永続化
- Front/Back Burner へのタスク移動時、既存タスクを自動で降格

## ビルド・実行
```bash
flutter pub get      # 依存関係の取得
flutter run           # アプリ実行
flutter test          # テスト実行
flutter analyze       # 静的解析
```

## コーディング規約
- UI ラベルは日本語
- コミットメッセージは日本語または英語 (feat:, fix: プレフィックス使用)
- Material 3 デザイン、アクセントカラー: オレンジ (0xFFFF5722)
- ConsumerWidget / ConsumerStatefulWidget で Riverpod と連携
