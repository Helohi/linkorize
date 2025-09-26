import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:linkorize/managers/memory_data_manager.dart';
import 'package:linkorize/models/category.dart';
import 'package:linkorize/screens/confirm_deletion_alert_dialog.dart';
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
  final Set<int> selectedNotes = {};

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
        actions: [
          if (selectedNotes.length == 1)
            IconButton(
              onPressed: () {
                onEditNoteAsked(selectedNotes.first);
                setState(() => selectedNotes.clear());
              },
              icon: Icon(Icons.edit),
            ),
          if (selectedNotes.isNotEmpty)
            IconButton(
              onPressed: () => onDeleteSelectedNotesAsked(),
              icon: Icon(Icons.delete),
            ),
          if (selectedNotes.isNotEmpty)
            IconButton(
                onPressed: () {
                  final selectedLength = selectedNotes.length;
                  selectedNotes.clear();
                  if (selectedLength != widget.category.notes.length) {
                    selectedNotes.addAll(
                      List.generate(
                        widget.category.notes.length,
                        (index) => index,
                      ),
                    );
                  }
                  setState(() {});
                },
                icon: Icon(Icons.checklist))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
        child: ListView.builder(
          itemCount: widget.category.notes.length + 1,
          itemBuilder: (context, index) => index != widget.category.notes.length
              ? Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Material(
                    color: selectedNotes.contains(index)
                        ? Colors.grey
                        : Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    child: InkWell(
                      onLongPress: () => setState(
                        () => selectedNotes.add(index),
                      ),
                      onTap: selectedNotes.isNotEmpty
                          ? () => setState(() => selectedNotes.contains(index)
                              ? selectedNotes.remove(index)
                              : selectedNotes.add(index))
                          : widget.category.notes[index].link.isNotEmpty
                              ? () async {
                                  final data =
                                      widget.category.notes[index].link.trim();
                                  final uri = Uri.tryParse(data);
                                  if (uri == null ||
                                      !uri.hasScheme ||
                                      uri.host.isEmpty) {
                                    copyToClipboard(data);
                                    return;
                                  }

                                  launchUrl(uri, webOnlyWindowName: "_blank")
                                      .then(
                                        (value) => value
                                            ? null
                                            : copyToClipboard(data),
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
                )
              : SizedBox(
                  height: 100,
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onNewNoteAsked,
        backgroundColor: Colors.black,
        label: Text(
          "Add Link",
          style: TextStyle(color: Colors.white),
        ),
        icon: Icon(
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

  void onDeleteSelectedNotesAsked() {
    showDialog(
      context: context,
      builder: (context) => ConfirmDeletionAlertDialog(
        title: "Are you sure you want to delete ${selectedNotes.length} links?",
        onConfirm: () {
          for (int i in selectedNotes) {
            deleteNoteInCategory(i);
          }
          setState(() => selectedNotes.clear());
        },
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
