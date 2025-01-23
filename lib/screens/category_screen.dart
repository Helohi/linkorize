import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkorize/managers/memory_data_manager.dart';
import 'package:linkorize/models/category.dart';
import 'package:linkorize/screens/edit_note_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../managers/shared_text_manager.dart';
import '../models/note.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({
    super.key,
    required this.category,
    this.linksToCreateNewNotes,
  });

  final Category category;
  final List<String>? linksToCreateNewNotes;

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();

    if (widget.linksToCreateNewNotes != null &&
        widget.linksToCreateNewNotes!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback(
        (timeStamp) {
          for (String sharedText in widget.linksToCreateNewNotes!) {
            onNewNoteAsked(
              initialLink: sharedText,
              onBottomButtonPressed: (note) {
                addNoteToCategory(note);
                Provider.of<SharedTextManager>(context, listen: false)
                    .removeFromSharedText(sharedText);
              },
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.category.avatarColor,
      appBar: AppBar(
        title: Text(widget.category.name),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
        child: ListView.builder(
          itemCount: widget.category.notes.length + 1,
          itemBuilder: (context, index) => index != widget.category.notes.length
              ? Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Dismissible(
                    key: UniqueKey(),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        deleteNoteInCategory(index);
                        return true;
                      } else if (direction == DismissDirection.endToStart) {
                        onEditNoteAsked(index);
                      }
                      return null;
                    },
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment(-0.9, 0.0),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      child: Align(
                        alignment: Alignment(0.9, 0.0),
                        child: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                    child: Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                      child: InkWell(
                        onTap: widget.category.notes[index].link.isNotEmpty
                            ? () async {
                                final data =
                                    widget.category.notes[index].link.trim();
                                final uri = Uri.tryParse(data);
                                if (uri == null) {
                                  copyToClipboard(data);
                                  return;
                                }

                                launchUrl(uri)
                                    .then(
                                      (value) =>
                                          value ? null : copyToClipboard(data),
                                    )
                                    .onError(
                                      (error, stackTrace) =>
                                          copyToClipboard(data),
                                    );
                              }
                            : null,
                        child: Column(
                          children: [
                            Row(),
                            if (widget.category.notes[index].title != null)
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  widget.category.notes[index].title!,
                                  style: TextStyle(fontSize: 24.0),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                widget.category.notes[index].link,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 100,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onNewNoteAsked,
        backgroundColor: Colors.black,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void onNewNoteAsked({
    String? initialText,
    String? initialLink,
    Function(Note)? onBottomButtonPressed,
  }) {
    onBottomButtonPressed ??= addNoteToCategory;

    showDialog(
      context: context,
      builder: (context) => EditNoteAlertDialog(
        initialText: initialText,
        initialLink: initialLink,
        bottomButtonTitle: "Save",
        autofocusOnTitle: true,
        onBottomButtonPressed: onBottomButtonPressed!,
      ),
    );
  }

  void onEditNoteAsked(int index) {
    showDialog(
      context: context,
      builder: (context) => EditNoteAlertDialog(
        bottomButtonTitle: "Save",
        initialText: widget.category.notes[index].title,
        initialLink: widget.category.notes[index].link,
        onBottomButtonPressed: (note) => editNoteInCategory(index, note),
      ),
    );
  }

  void copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Invalid link. Copied to Clipboard.")),
    );
  }

  void addNoteToCategory(Note note) {
    setState(() => widget.category.notes.add(note));
    MemoryDataManager.changeCategory(widget.category.id, widget.category);
  }

  void deleteNoteInCategory(int index) {
    setState(() => widget.category.notes.removeAt(index));
    MemoryDataManager.changeCategory(widget.category.id, widget.category);
  }

  void editNoteInCategory(int index, Note newNote) {
    setState(() => widget.category.notes[index] = newNote);
    MemoryDataManager.changeCategory(widget.category.id, widget.category);
  }
}
