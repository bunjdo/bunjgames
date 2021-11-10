import 'package:flutter/material.dart';
import 'package:mobile/styles.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: SettingsForm(),
    );
  }
}

class SettingsForm extends StatefulWidget {
  @override
  SettingsFormState createState() => SettingsFormState();
}

class SettingsFormState extends State<SettingsForm> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return SettingsList(
      backgroundColor: baseBackground,
      sections: [
        SettingsSection(
          title: 'Section',
          titleTextStyle: TextStyle(color: baseTextColor),
          titlePadding: EdgeInsets.only(left: 16, top: 16),
          tiles: [
            SettingsTile(
              title: 'Language',
              subtitle: 'English',
              leading: Icon(Icons.language, color: baseTextColor),
              onPressed: (BuildContext context) {},
            ),
            SettingsTile.switchTile(
              title: 'Use fingerprint',
              leading: Icon(Icons.fingerprint, color: baseTextColor),
              switchValue: false,
              onToggle: (bool value) {},
            ),
          ],
        ),
      ],
    );
  }

}