import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:linkorize/models/category.dart';

class ConfirmDeletionAlertDialog extends StatelessWidget {
  const ConfirmDeletionAlertDialog({
    super.key,
    this.category,
    this.title,
    required this.onConfirm,
  });

  final Category? category;
  final String? title;
  final Function onConfirm;

  @override
  Widget build(BuildContext context) {
    assert(
      category != null || title != null,
      "either category or title should not be null",
    );
    return AlertDialog(
      title: title != null
          ? Text(title!)
          : Text.rich(
              TextSpan(
                text: "Delete ",
                children: [
                  TextSpan(text: category!.name),
                  TextSpan(text: " with "),
                  TextSpan(text: category!.notes.length.toString()),
                  TextSpan(text: " notes?"),
                ],
              ),
            ),
      content: SizedBox(
        width: 1,
        child: ActionSlider.standard(
          backgroundColor: Colors.white,
          toggleColor: Colors.red.shade400,
          sliderBehavior: SliderBehavior.stretch,
          action: (controller) async {
            controller.success();
            await Future.delayed(Duration(milliseconds: 500));
            onConfirm();
            if (context.mounted) Navigator.pop(context);
          },
          successIcon: Icon(Icons.delete_forever_rounded),
          child: Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.delete),
          ),
        ),
      ),
    );
  }
}
