import 'package:flutter/material.dart';
import '../../../../product/widgets/app_scaffold.dart';

/// Settings page widget
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(title: 'Settings', body: _SettingsList());
  }
}

/// Settings list widget
class _SettingsList extends StatelessWidget {
  const _SettingsList();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SettingsSection(
          title: 'Appearance',
          children: [
            _SettingsTile(
              title: 'Theme',
              subtitle: 'Light',
              leading: const Icon(Icons.palette),
              onTap: () {
                // TODO: Implement theme selection
              },
            ),
            _SettingsTile(
              title: 'Language',
              subtitle: 'English',
              leading: const Icon(Icons.language),
              onTap: () {
                // TODO: Implement language selection
              },
            ),
          ],
        ),
        _SettingsSection(
          title: 'Notifications',
          children: [
            _SettingsTile(
              title: 'Enable Notifications',
              subtitle: 'Receive reminders for tasks',
              leading: const Icon(Icons.notifications),
              trailing: Switch(
                value: true, // TODO: Get from settings
                onChanged: (value) {
                  // TODO: Update notification settings
                },
              ),
            ),
            _SettingsTile(
              title: 'Reminder Time',
              subtitle: '9:00 AM',
              leading: const Icon(Icons.schedule),
              onTap: () {
                // TODO: Implement reminder time selection
              },
            ),
          ],
        ),
        _SettingsSection(
          title: 'Audio',
          children: [
            _SettingsTile(
              title: 'Recording Quality',
              subtitle: 'High',
              leading: const Icon(Icons.mic),
              onTap: () {
                // TODO: Implement recording quality selection
              },
            ),
            _SettingsTile(
              title: 'Playback Speed',
              subtitle: '1.0x',
              leading: const Icon(Icons.speed),
              onTap: () {
                // TODO: Implement playback speed selection
              },
            ),
          ],
        ),
        _SettingsSection(
          title: 'Data & Storage',
          children: [
            _SettingsTile(
              title: 'Sync with Cloud',
              subtitle: 'Keep tasks synchronized',
              leading: const Icon(Icons.cloud_sync),
              trailing: Switch(
                value: false, // TODO: Get from settings
                onChanged: (value) {
                  // TODO: Update sync settings
                },
              ),
            ),
            _SettingsTile(
              title: 'Export Tasks',
              subtitle: 'Backup your data',
              leading: const Icon(Icons.download),
              onTap: () {
                // TODO: Implement task export
              },
            ),
            _SettingsTile(
              title: 'Import Tasks',
              subtitle: 'Restore from backup',
              leading: const Icon(Icons.upload),
              onTap: () {
                // TODO: Implement task import
              },
            ),
          ],
        ),
        _SettingsSection(
          title: 'About',
          children: [
            const _SettingsTile(
              title: 'Version',
              subtitle: '1.0.0',
              leading: Icon(Icons.info),
              onTap: null,
            ),
            _SettingsTile(
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              leading: const Icon(Icons.privacy_tip),
              onTap: () {
                // TODO: Navigate to privacy policy
              },
            ),
            _SettingsTile(
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              leading: const Icon(Icons.description),
              onTap: () {
                // TODO: Navigate to terms of service
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Settings section widget
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
        const Divider(),
      ],
    );
  }
}

/// Settings tile widget
class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.leading,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

// TODO: Implement theme switching functionality
// TODO: Implement language selection
// TODO: Implement notification settings
// TODO: Implement audio quality settings
// TODO: Implement data sync functionality
// TODO: Implement data export/import
// TODO: Add about page navigation
