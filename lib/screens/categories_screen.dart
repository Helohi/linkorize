import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linkorize/managers/memory_data_manager.dart';
import 'package:linkorize/managers/shared_text_manager.dart';
import 'package:linkorize/models/category.dart';
import 'package:linkorize/screens/category_screen.dart';
import 'package:linkorize/screens/confirm_deletion_alert_dialog.dart';
import 'package:linkorize/screens/edit_category_alert_dialog.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> categories = [];
  List<int> selectedCategories = [];
  late Future<void> _getCategoriesOnce;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => Provider.of<SharedTextManager>(context, listen: false)
          .checkForNewMessages(),
    );

    _getCategoriesOnce = getAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: selectedCategories.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  selectedCategories.clear();
                  for (int i = 0; i < categories.length; i++) {
                    selectedCategories.add(i);
                  }
                  setState(() {});
                },
                icon: Icon(Icons.checklist),
              ),
        title: Consumer<SharedTextManager>(
          builder: (context, value, child) => value.sharedText.isEmpty
              ? Text("Linkorize")
              : Text("Choose Category for link"),
        ),
        centerTitle: true,
        actions: [
          if (selectedCategories.isNotEmpty)
            IconButton(
              onPressed: () {
                showDeleteConfirmationForList(selectedCategories);
              },
              icon: Icon(Icons.delete),
            )
        ],
      ),
      body: FutureBuilder(
          future: _getCategoriesOnce,
          builder: (context, snapshot) {
            print(snapshot);
            if (snapshot.connectionState == ConnectionState.done) {
              return categories.isEmpty
                  ? Center(
                      child: Text(
                        "Create Your First Category",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: categories.length + 1,
                      itemBuilder: (context, index) => index < categories.length
                          ? Dismissible(
                              key: UniqueKey(),
                              confirmDismiss: (direction) async {
                                if (direction == DismissDirection.startToEnd) {
                                  if (categories[index].notes.isEmpty) {
                                    return true;
                                  } else {
                                    showDeleteConfirmation(index);
                                  }
                                } else if (direction ==
                                    DismissDirection.endToStart) {
                                  editCategory(index);
                                }
                                return null;
                              },
                              background: Container(
                                color: Colors.red,
                                child: Align(
                                  alignment: Alignment(-0.9, 0.0),
                                  child:
                                      Icon(Icons.delete, color: Colors.white),
                                ),
                              ),
                              onDismissed: (direction) => removeCategory(index),
                              secondaryBackground: Container(
                                color: Colors.blue,
                                child: Align(
                                  alignment: Alignment(0.9, 0.0),
                                  child: Icon(Icons.edit, color: Colors.white),
                                ),
                              ),
                              child: ListTile(
                                selected: selectedCategories.contains(index),
                                selectedTileColor: Colors.grey[350],
                                onTap: () {
                                  selectedCategories.isEmpty
                                      ? Navigator.of(context).push(
                                          CupertinoPageRoute(
                                            builder: (context) =>
                                                CategoryScreen(
                                              category: categories[index],
                                              linksToCreateNewNotes: Provider
                                                      .of<SharedTextManager>(
                                                          context,
                                                          listen: false)
                                                  .sharedText,
                                            ),
                                          ),
                                        )
                                      : setState(
                                          () => selectedCategories
                                                  .contains(index)
                                              ? selectedCategories.remove(index)
                                              : selectedCategories.add(index),
                                        );
                                },
                                onLongPress: () => setState(
                                    () => selectedCategories.add(index)),
                                leading: CircleAvatar(
                                  backgroundColor:
                                      categories[index].avatarColor,
                                  radius: 12,
                                ),
                                title: Text(categories[index].name),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            )
                          : SizedBox(height: 60),
                    );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: onNewCategoryAsked,
        backgroundColor: Colors.black,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmation(int index) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmDeletionAlertDialog(
        category: categories[index],
        onConfirm: () => removeCategory(index),
      ),
    );
  }

  Future<void> showDeleteConfirmationForList(List<int> indexes) {
    return showDialog(
      context: context,
      builder: (context) => ConfirmDeletionAlertDialog(
        title: "Are you sure you want to delete ${indexes.length} categories?",
        onConfirm: () {
          for (int i in indexes) {
            removeCategory(i);
          }
          setState(() {});
        },
      ),
    );
  }

  Color randomColor() {
    // No need in creation of white color
    return Color.from(
      alpha: 1.0,
      red: Random().nextDouble(),
      green: Random().nextDouble(),
      blue: Random().nextDouble(),
    );
  }

  void editCategory(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return EditCategoryAlertDialog(
          category: categories[index],
          onCategoryChanged: (changedCategory) {
            MemoryDataManager.changeCategory(
              changedCategory.id,
              changedCategory,
            );
            setState(
              () => categories[index] = changedCategory,
            );
          },
          bottomButtonTitle: "",
          onBottomButtonPressed: null,
        );
      },
    );
  }

  void onNewCategoryAsked() {
    showDialog(
      context: context,
      builder: (context) => EditCategoryAlertDialog(
        category: Category(
          id: Uuid().v4(),
          avatarColor: randomColor(),
          name: "New Category",
          notes: [],
        ),
        autofocusOnName: true,
        onCategoryChanged: (_) {},
        bottomButtonTitle: "Create",
        onBottomButtonPressed: (category) {
          MemoryDataManager.addNewCategory(category);
          setState(() => categories.add(category));
        },
      ),
    );
  }

  void removeCategory(int index) {
    MemoryDataManager.removeCategory(categories[index].id);

    setState(
      () => categories.removeAt(index),
    );
  }

  Future<void> getAllCategories() async {
    return categories.addAll(await MemoryDataManager.getAllCategories());
  }
}
