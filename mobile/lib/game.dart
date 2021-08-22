import 'package:flutter/material.dart';
import 'styles.dart';


class GamePage extends StatefulWidget {
  @override
  GamePageState createState() => GamePageState();
}



class GamePageState extends State<GamePage> {

  String title = "Bunjgames";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      drawer: GameDrawer(),
      body: Center(
        child: Button(),
      ),
    );
  }
}


class GameDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: baseBackground,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: baseBackgroundDark,
              ),
              child: Text('Title'),
            ),
            ListTile(
              title: Text('Item 1'),
            ),
            ListTile(
              title: Text('Item 2'),
            ),
          ],
        ),
      ),
    );
  }
}


class Button extends StatelessWidget {

  final VoidCallback onPressed = () {};
  final String text = "";

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: double.infinity,
        minHeight: double.infinity,
      ),
      child: new Container(
        margin: EdgeInsets.all(24),
        child: RawMaterialButton(
          elevation: 2.0,
          fillColor: buttonColorRed,
          padding: EdgeInsets.all(16),
          shape: CircleBorder(),
          onPressed: this.onPressed,
          child: Text(this.text),
        ),
      ),
    );
  }
}