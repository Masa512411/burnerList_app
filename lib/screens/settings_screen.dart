import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:burner_list/providers/settings_provider.dart';
import 'package:burner_list/providers/task_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        children: [
          // ----- テーマ -----
          _SectionHeader(label: 'テーマ'),
          _ThemeOptionTile(
            label: 'システム設定に従う',
            icon: Icons.brightness_auto,
            mode: ThemeMode.system,
            current: settings.themeMode,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ThemeMode.system),
          ),
          _ThemeOptionTile(
            label: 'ライト',
            icon: Icons.light_mode,
            mode: ThemeMode.light,
            current: settings.themeMode,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ThemeMode.light),
          ),
          _ThemeOptionTile(
            label: 'ダーク',
            icon: Icons.dark_mode,
            mode: ThemeMode.dark,
            current: settings.themeMode,
            onTap: () => ref
                .read(settingsProvider.notifier)
                .setThemeMode(ThemeMode.dark),
          ),

          const Divider(height: 32),

          // ----- アプリ情報 -----
          _SectionHeader(label: 'アプリ情報'),
          ListTile(
            leading: const Icon(Icons.local_fire_department),
            title: const Text('Burner List'),
            subtitle: const Text('バージョン 1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('使い方'),
            onTap: () => _showAbout(context),
          ),

          const Divider(height: 32),

          // ----- データ管理 -----
          _SectionHeader(label: 'データ管理'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text('全データを削除'),
            subtitle: const Text('すべてのタスクを完全に削除します'),
            onTap: () => _confirmDeleteAll(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('全データを削除'),
        content: const Text('すべてのタスクが削除されます。この操作は取り消せません。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(taskProvider.notifier).cleanSlate();
              Navigator.pop(ctx);
            },
            child: const Text('削除'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AlertDialog(
        title: Text('Burner Listとは'),
        content: Text(
          '一度に一つのことに集中するためのタスク管理アプリです。\n\n'
          'Front Burner: 今最も重要なタスク\n'
          'Back Burner: 次にやること\n'
          'Counter Space: アイデアや保留タスク\n'
          'Kitchen Sink: その他すべて',
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final ThemeMode mode;
  final ThemeMode current;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.label,
    required this.icon,
    required this.mode,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = mode == current;
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: selected
          ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}
