import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:linkorize/models/category.dart';

/// if onBottomButtonPressed is null, then the bottom button will not be displayed
class EditCategoryAlertDialog extends StatefulWidget {
  const EditCategoryAlertDialog({
    super.key,
    required this.category,
    required this.onCategoryChanged,
    required this.bottomButtonTitle,
    required this.onBottomButtonPressed,
    this.autofocusOnName = false,
  });

  final Category category;
  final Function(Category) onCategoryChanged;
  final String bottomButtonTitle;
  final Function(Category)? onBottomButtonPressed;
  final bool autofocusOnName;

  @override
  State<EditCategoryAlertDialog> createState() =>
      EditCategoryAlertDialogState();
}

class EditCategoryAlertDialogState extends State<EditCategoryAlertDialog> {
  late final TextEditingController textController;
  late final FocusNode _focusNode;
  bool _isFirstTap = true;

  @override
  initState() {
    super.initState();
    textController = TextEditingController()..text = widget.category.name;
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _isFirstTap) {
        textController.selection = TextSelection(
            baseOffset: 0, extentOffset: textController.text.length);
      }
      _isFirstTap = false;
    });
  }

  @override
  void dispose() {
    textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TextField(
        controller: textController,
        autofocus: widget.autofocusOnName,
        focusNode: _focusNode,
        onTap: () {
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
        },
        onChanged: (value) {
          widget.category.name = value;
          widget.onCategoryChanged(widget.category);
        },
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: "Category Name",
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          icon: CircleAvatar(
            backgroundColor: widget.category.avatarColor,
          ),
        ),
        style: TextStyle(fontSize: 24),
      ),
      content: SingleChildScrollView(
        child: BlockPicker(
          pickerColor: widget.category.avatarColor,
          onColorChanged: (color) async {
            setState(() => widget.category.avatarColor = color);
            widget.onCategoryChanged(widget.category);
          },
        ),
      ),
      actions: [
        if (widget.onBottomButtonPressed != null)
          Row(
            children: [
              Expanded(
                child: MaterialButton(
                  onPressed: () {
                    widget.onBottomButtonPressed!(widget.category);
                    Navigator.pop(context);
                  },
                  color: Colors.black,
                  child: Text(
                    widget.bottomButtonTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }
}
