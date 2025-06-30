import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:substationapp/controller/substationncontroller.dart';
import 'package:substationapp/model/workrecordListModel.dart';
import 'dart:convert';

class Substationhome extends StatelessWidget {
  const Substationhome({super.key});

  @override
  Widget build(BuildContext context) {
    final SubstationController controller = Get.put(SubstationController());
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Substation Search'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.searchController,
                          onChanged: (value) {
                            controller.searchText.value = value;
                            controller.showSearchResults.value = true;
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Substation Name',
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          final ssname = controller.searchController.text.trim();
                          controller.searchText.value = ssname;
                          controller.showSearchResults.value = false;

                          if (ssname.isNotEmpty) {
                            controller.fetchWorkList(ssname);
                          }
                        },
                        icon: const Icon(Icons.search),
                        label: const Text("Search"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Obx(() {
                if (controller.isLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: CircularProgressIndicator(),
                  );
                }

                final list = controller.filteredList;

                if (controller.searchText.value.isEmpty ||
                    !controller.showSearchResults.value) {
                  return const SizedBox();
                }

                if (list.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("No Substation Found"),
                  );
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 180,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return ListTile(
                        title: Text(item.SSNAME ?? ''),
                        onTap: () {
                          controller.searchController.text = item.SSNAME ?? '';
                          controller.searchText.value = item.SSNAME ?? '';
                          controller.showSearchResults.value = false;
                          controller.fetchWorkList(item.SSNAME ?? '');
                        },
                      );
                    },
                  ),
                );
              }),

              Obx(() {
                if (!controller.showSearchResults.value &&
                    controller.worklist.isNotEmpty) {
                  return TextButton.icon(
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchText.value = '';
                      controller.worklist.clear();
                      controller.showSearchResults.value = true;
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Search Again"),
                  );
                }
                return const SizedBox();
              }),

              const SizedBox(height: 10),

              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: TextField(
                    onChanged: (value) => controller.worklistSearchText.value = value,
                    decoration: const InputDecoration(
                      hintText: 'Search in Work Records',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.worklist.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final worklist = controller.filteredWorklist;

                  if (worklist.isEmpty) {
                    return const Center(child: Text("No work records found."));
                  }

                  return Scrollbar(
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columnSpacing: 20,
                          dataRowHeight: 56,
                          headingRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.indigo.shade100,
                          ),
                          columns: const [
                            DataColumn(label: Text('MAJOR')),
                            DataColumn(label: Text('Project')),
                            DataColumn(label: Text('TR')),
                            DataColumn(label: Text('PACI')),
                            DataColumn(label: Text('SGMAKE')),
                            DataColumn(label: Text('SGTYPE')),
                            DataColumn(label: Text('Entry Date')),
                          ],
                          rows: worklist.map((WorkListModel item) {
                            return DataRow(
                              cells: [
                                DataCell(Text(item.MAJOR?.toString() ?? '')),
                                DataCell(Text(item.Project?.toString() ?? '')),
                                DataCell(Text(item.TR?.toString() ?? '')),
                                DataCell(Text(item.PACI?.toString() ?? '')),
                                DataCell(Text(item.SGMAKE?.toString() ?? '')),
                                DataCell(Text(item.SGTYPE?.toString() ?? '')),
                                DataCell(Row(
                                  children: [
                                    Expanded(child: Text(item.EntryDate?.toString() ?? '')),
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.indigo),
                                      tooltip: 'Edit',
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            final _formKey = GlobalKey<FormState>();
                                            final majorController = TextEditingController(text: item.MAJOR?.toString() ?? '');
                                            final projectController = TextEditingController(text: item.Project?.toString() ?? '');
                                            final trController = TextEditingController(text: item.TR?.toString() ?? '');
                                            final paciController = TextEditingController(text: item.PACI?.toString() ?? '');
                                            final sgmakeController = TextEditingController(text: item.SGMAKE?.toString() ?? '');
                                            final sgtypeController = TextEditingController(text: item.SGTYPE?.toString() ?? '');
                                            final ssnameController = TextEditingController(text: item.SSNAME?.toString() ?? '');
                                            return AlertDialog(
                                              title: const Text('Edit Work Record'),
                                              content: SingleChildScrollView(
                                                child: Form(
                                                  key: _formKey,
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      TextFormField(
                                                        controller: majorController,
                                                        decoration: const InputDecoration(labelText: 'MAJOR'),
                                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                                      ),
                                                      TextFormField(
                                                        controller: projectController,
                                                        decoration: const InputDecoration(labelText: 'Project'),
                                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                                      ),
                                                      TextFormField(
                                                        controller: trController,
                                                        decoration: const InputDecoration(labelText: 'TR'),
                                                        keyboardType: TextInputType.number,
                                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                                      ),
                                                      TextFormField(
                                                        controller: paciController,
                                                        decoration: const InputDecoration(labelText: 'PACI'),
                                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                                      ),
                                                      TextFormField(
                                                        controller: sgmakeController,
                                                        decoration: const InputDecoration(labelText: 'SGMAKE'),
                                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                                      ),
                                                      TextFormField(
                                                        controller: sgtypeController,
                                                        decoration: const InputDecoration(labelText: 'SGTYPE'),
                                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                                      ),
                                                      TextFormField(
                                                        controller: ssnameController,
                                                        decoration: const InputDecoration(labelText: 'SSNAME'),
                                                        validator: (v) => v!.isEmpty ? 'Required' : null,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(context).pop(),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    if (_formKey.currentState!.validate()) {
                                                      final updatedRecord = WorkListModel(
                                                        RecordID: item.RecordID,
                                                        MAJOR: majorController.text,
                                                        Project: projectController.text,
                                                        TR: trController.text,
                                                        PACI: paciController.text,
                                                        SGMAKE: sgmakeController.text,
                                                        SGTYPE: sgtypeController.text,
                                                        SSNAME: ssnameController.text,
                                                        EntryDate: DateTime.now(),
                                                      );
                                                      final success = await controller.editWorkRecord(updatedRecord);
                                                      // ignore: avoid_print
                                                      print('Edit Response: ' + (success ? 'Success' : 'Failed'));
                                                      if (success) {
                                                        Navigator.of(context).pop();
                                                        controller.fetchWorkList(ssnameController.text);
                                                      }
                                                    }
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }).toList(),
                        ), // <-- closes DataTable
                      ), // <-- closes SingleChildScrollView (horizontal)
                    ), // <-- closes SingleChildScrollView (vertical)
                  ); // <-- closes Scrollbar
                }), // <-- closes Obx
              ), // <-- closes Expanded
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final _formKey = GlobalKey<FormState>();
            final majorController = TextEditingController();
            final projectController = TextEditingController();
            final trController = TextEditingController();
            final paciController = TextEditingController();
            final sgmakeController = TextEditingController();
            final sgtypeController = TextEditingController();
            final ssnameController = TextEditingController(text: controller.searchController.text);
            // Remove entryDateController and EntryDate field from UI
            await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Add New Work Record'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: majorController,
                            decoration: const InputDecoration(labelText: 'MAJOR'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: projectController,
                            decoration: const InputDecoration(labelText: 'Project'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: trController,
                            decoration: const InputDecoration(labelText: 'TR'),
                            keyboardType: TextInputType.number,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: paciController,
                            decoration: const InputDecoration(labelText: 'PACI'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: sgmakeController,
                            decoration: const InputDecoration(labelText: 'SGMAKE'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: sgtypeController,
                            decoration: const InputDecoration(labelText: 'SGTYPE'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          TextFormField(
                            controller: ssnameController,
                            decoration: const InputDecoration(labelText: 'SSNAME'),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                icon: const Icon(Icons.bug_report),
                                label: const Text('Test Fill'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                                onPressed: () {
                                  majorController.text = 'test major';
                                  projectController.text = 'test project';
                                  trController.text = '123';
                                  paciController.text = 'hh';
                                  sgmakeController.text = 'ghtesr';
                                  sgtypeController.text = 'ff';
                                  ssnameController.text = controller.searchController.text.isNotEmpty ? controller.searchController.text : 'test ss';
                                  // Print payload for debugging
                                  final testRecord = WorkListModel(
                                    MAJOR: majorController.text,
                                    Project: projectController.text,
                                    TR: trController.text,
                                    PACI: paciController.text,
                                    SGMAKE: sgmakeController.text,
                                    SGTYPE: sgtypeController.text,
                                    SSNAME: ssnameController.text,
                                    EntryDate: DateTime.now(),
                                  );
                                  final payload = {
                                    'title': 'UpdateWorkDetails',
                                    'description': 'Update Work Details',
                                    'ReqJSonData': jsonEncode([
                                      {
                                        'ActionType': 1,
                                        'RecordID': 0,
                                        'MAJOR': testRecord.MAJOR,
                                        'SSNAME': testRecord.SSNAME,
                                        'Project': testRecord.Project,
                                        'TR': testRecord.TR,
                                        'PACI': testRecord.PACI,
                                        'SGMAKE': testRecord.SGMAKE,
                                        'SGTYPE': testRecord.SGTYPE,
                                        'EntryDate': testRecord.EntryDate,
                                      }
                                    ]),
                                  };
                                  // ignore: avoid_print
                                  print('Test Add Payload: ' + payload.toString());
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final newRecord = WorkListModel(
                            MAJOR: majorController.text,
                            Project: projectController.text,
                            TR: trController.text,
                            PACI: paciController.text,
                            SGMAKE: sgmakeController.text,
                            SGTYPE: sgtypeController.text,
                            SSNAME: ssnameController.text,
                            EntryDate: DateTime.now(),
                          );
                          final success = await controller.addWorkRecord(newRecord);
                          // Print response for debugging
                          // ignore: avoid_print
                          print('Test Add Response: ' + (success ? 'Success' : 'Failed'));
                          if (success) {
                            Navigator.of(context).pop();
                            // Optionally refresh work list
                            controller.fetchWorkList(ssnameController.text);
                          }
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New'),
          backgroundColor: Colors.indigo,
        ),
      ),
    );
  }
}
