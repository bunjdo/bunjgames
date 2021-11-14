import 'package:flutter/material.dart';
import 'package:mobile/services/login.dart';
import 'package:mobile/services/settings.dart';
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
  SettingsService? settings;

  @override
  void initState() {
    super.initState();
    SettingsService.getInstance().then(
        (settings) => setState(() => this.settings = settings)
    );
  }

  String dialogText = "";
  Future<void> _displayTextInputDialog(
      BuildContext context,
      String title,
      String hint,
      String text,
      SettingsType settingsType
  ) async {
    return showDialog(context: context, builder: (context) {
      return AlertDialog(
        backgroundColor: baseBackgroundDark,
        title: Text(title),
        content: TextField(
          onChanged: (value) {
            setState(() {
              dialogText = value;
            });
          },
          decoration: InputDecoration(hintText: hint),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('DEFAULT'),
            onPressed: () {
              setState(() {
                settings!.setString(settingsType, settingsType.defaultValue).then((value) {
                  setState(() {});
                  Navigator.pop(context);
                });
              });
            },
          ),
          TextButton(
            child: Text('CANCEL'),
            onPressed: () {
              setState(() {
                Navigator.pop(context);
              });
            },
          ),
          TextButton(
            child: Text('OK'),
            onPressed: () {
              if (dialogText.trim().isNotEmpty && dialogText.trim() != "auto") {
                settings!.setString(settingsType, dialogText).then((value) {
                  setState(() {});
                  Navigator.pop(context);
                });
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this.settings == null)
      return SettingsList(backgroundColor: baseBackground, sections: []);
    return SettingsList(
      backgroundColor: baseBackground,
      sections: [
        SettingsSection(
          title: 'Api',
          titleTextStyle: TextStyle(color: baseTextColor),
          titlePadding: EdgeInsets.only(left: 16, top: 16),
          tiles: [
            SettingsTile(
              title: 'Api url',
              subtitle: settings!.getString(SettingsType.API_URL),
              leading: Icon(Icons.cloud, color: baseTextColor),
              onPressed: (BuildContext context) {
                var isDefault = settings!.getString(SettingsType.API_URL) == SettingsType.API_URL.defaultValue;
                _displayTextInputDialog(
                    context,
                    'Api url',
                    settings!.getString(SettingsType.API_URL),
                    isDefault ? "" : settings!.getString(SettingsType.API_URL),
                    SettingsType.API_URL
                );
              },
            ),
            SettingsTile(
              title: 'WebSocket url',
              subtitle: settings!.getString(SettingsType.WS_URL),
              leading: Icon(Icons.cloud_circle, color: baseTextColor),
              onPressed: (BuildContext context) {
                var isDefault = settings!.getString(SettingsType.WS_URL) == SettingsType.WS_URL.defaultValue;
                _displayTextInputDialog(
                    context,
                    'WebSocket url',
                    settings!.getString(SettingsType.WS_URL),
                    isDefault ? "" : settings!.getString(SettingsType.WS_URL),
                    SettingsType.WS_URL
                );
              },
            ),
          ],
        ),
        SettingsSection(
          title: 'UDP api',
          titleTextStyle: TextStyle(color: baseTextColor),
          tiles: [
            SettingsTile.switchTile(
              title: 'Use UDP api',
              leading: Icon(Icons.hdr_strong, color: baseTextColor),
              switchValue: settings!.getBool(SettingsType.USE_UDP_IP),
              onToggle: (bool value) async {
                await settings!.setBool(SettingsType.USE_UDP_IP, value);
                setState(() {});
              },
            ),
            SettingsTile(
              title: 'UDP IP',
              subtitle: settings!.getString(SettingsType.UDP_IP),
              leading: Icon(Icons.cloud_queue, color: baseTextColor),
              enabled: settings!.getBool(SettingsType.USE_UDP_IP),
              iosChevronPadding: null,
              onPressed: (BuildContext context) {
                var isDefault = settings!.getString(SettingsType.UDP_IP) == SettingsType.UDP_IP.defaultValue;
                _displayTextInputDialog(
                    context,
                    'UDP IP',
                    settings!.getString(SettingsType.UDP_IP),
                    isDefault ? "" : settings!.getString(SettingsType.UDP_IP),
                    SettingsType.UDP_IP
                );
              },
            ),
          ],
        ),
        SettingsSection(
          title: '',
          tiles: [
            SettingsTile(
              title: 'Apply settings',
              leading: Icon(Icons.save, color: baseTextColor),
              onPressed: (context) async => await LoginService().restart(),
            ),
          ],
        ),
      ],
    );
  }

}
