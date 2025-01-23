import 'package:flutter/material.dart';
import 'package:linkorize/models/note.dart';

class EditNoteAlertDialog extends StatefulWidget {
  const EditNoteAlertDialog({
    super.key,
    required this.bottomButtonTitle,
    required this.onBottomButtonPressed,
    this.autofocusOnTitle = false,
    this.initialLink,
    this.initialText,
  });

  final String bottomButtonTitle;
  final Function(Note) onBottomButtonPressed;
  final bool autofocusOnTitle;
  final String? initialLink;
  final String? initialText;

  @override
  State<EditNoteAlertDialog> createState() => _EditNoteAlertDialogState();
}

class _EditNoteAlertDialogState extends State<EditNoteAlertDialog> {
  late final TextEditingController _titleTextController;
  late final TextEditingController _linkTextController;

  @override
  void initState() {
    super.initState();
    _titleTextController = TextEditingController(text: widget.initialText);
    _linkTextController = TextEditingController(text: widget.initialLink);
  }

  @override
  void dispose() {
    _titleTextController.dispose();
    _linkTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: _titleTextController,
        autofocus: widget.autofocusOnTitle,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(fontSize: 24),
        decoration: InputDecoration(
          border: InputBorder.none,
          label: Text("Title"),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _linkTextController,
            maxLines: 3,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              label: Text("Link"),
            ),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  color: Colors.black,
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onBottomButtonPressed(
                      Note(
                        title: _titleTextController.text,
                        link: _linkTextController.text,
                      ),
                    );
                  },
                  child: Text(
                    widget.bottomButtonTitle,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
