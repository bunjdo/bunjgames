import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

typedef StringToVoidFunc = void Function(String);

enum SingleFieldFormType {
  TEXT,
  UNSIGNED_INT
}

class SingleFieldForm extends StatefulWidget {
  final String label;
  final SingleFieldFormType type;
  final StringToVoidFunc callback;

  SingleFieldForm({required this.label, required this.type, required this.callback});

  @override
  SingleFieldFormState createState() => SingleFieldFormState();
}

class SingleFieldFormState extends State<SingleFieldForm> {

  final String validationError = 'This field cannot be empty';
  final formKey = GlobalKey<FormState>();

  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: widget.label,
            ),
            inputFormatters: widget.type == SingleFieldFormType.UNSIGNED_INT ? [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
            ] : [],
            keyboardType: widget.type == SingleFieldFormType.UNSIGNED_INT
                ? TextInputType.number : TextInputType.text,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return validationError;
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  widget.callback(controller.text.trim());
                }
              },
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
