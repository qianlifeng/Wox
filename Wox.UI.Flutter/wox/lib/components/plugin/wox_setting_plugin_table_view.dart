import 'dart:convert';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:uuid/v4.dart';
import 'package:wox/components/wox_image_view.dart';
import 'package:wox/entity/wox_image.dart';
import 'package:wox/entity/wox_plugin_setting_table.dart';
import 'package:flutter/material.dart' as material;

import 'wox_setting_plugin_item_view.dart';
import 'wox_setting_plugin_table_update_view.dart';

class WoxSettingPluginTable extends WoxSettingPluginItem {
  final PluginSettingValueTable item;
  static const String rowUniqueIdKey = "wox_table_row_id";

  const WoxSettingPluginTable(super.plugin, this.item, super.onUpdate, {super.key, required});

  Widget columnWidth({required Widget child, required int width}) {
    if (width == 0) return Expanded(child: child);

    return SizedBox(
      width: width.toDouble(),
      child: child,
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            for (var column in item.columns)
              columnWidth(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    column.label,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                width: column.width,
              )
            //operation column
            ,
            columnWidth(
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  "Operation",
                  style: TextStyle(
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              width: 100,
            ),
          ],
        ),
        const material.Divider(thickness: 0.4, indent: 0)
      ],
    );
  }

  Widget buildRowValue(PluginSettingValueTableColumn column, Map<String, dynamic> row) {
    var value = row[column.key] ?? "";

    if (column.type == PluginSettingValueType.pluginSettingValueTableColumnTypeText) {
      return Text(
        value,
        style: const TextStyle(
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (column.type == PluginSettingValueType.pluginSettingValueTableColumnTypeCheckbox) {
      return Row(
        children: [
          value == "true" ? const Icon(material.Icons.check_box) : const Icon(material.Icons.check_box_outline_blank),
        ],
      );
    }
    if (column.type == PluginSettingValueType.pluginSettingValueTableColumnTypeTextList) {
      return Column(
        children: [
          for (var txt in value)
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Text("${(value as List<dynamic>).length == 1 ? "" : "-"} $txt"),
            ),
        ],
      );
    }
    if (column.type == PluginSettingValueType.pluginSettingValueTableColumnTypeWoxImage) {
      final woxImage = WoxImage.fromJson(value);
      return Row(
        children: [
          WoxImageView(woxImage: woxImage, width: 24, height: 24),
        ],
      );
    }

    return Text("Unknown column type: ${column.type}");
  }

  Widget buildRows(BuildContext context) {
    var rowsJson = getSetting(item.key);
    if (rowsJson == "") {
      return const Padding(
        padding: EdgeInsets.only(bottom: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("No rows"),
          ],
        ),
      );
    }

    var rows = json.decode(rowsJson);
    //give each row a unique key
    for (var row in rows) {
      row[rowUniqueIdKey] = const UuidV4().generate();
    }

    return Column(
      children: [
        for (var row in rows)
          Column(
            children: [
              Row(
                children: [
                  for (var column in item.columns)
                    columnWidth(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: buildRowValue(column, row),
                      ),
                      width: column.width,
                    ),
                  //operation column
                  columnWidth(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          HyperlinkButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return WoxSettingPluginTableUpdate(
                                      plugin: plugin,
                                      item: item,
                                      row: row,
                                      onUpdate: (key, value) {
                                        var rowsJson = getSetting(key);
                                        if (rowsJson == "") {
                                          rowsJson = "[]";
                                        }
                                        for (var i = 0; i < rows.length; i++) {
                                          if (rows[i][rowUniqueIdKey] == value[rowUniqueIdKey]) {
                                            rows[i] = value;
                                            break;
                                          }
                                        }

                                        //remove the unique key
                                        rows.forEach((element) {
                                          element.remove(rowUniqueIdKey);
                                        });

                                        updateConfig(key, json.encode(rows));
                                      },
                                    );
                                  });
                            },
                            child: const Icon(material.Icons.edit),
                          ),
                          HyperlinkButton(
                            onPressed: () {
                              var rowsJson = getSetting(item.key);
                              if (rowsJson == "") {
                                rowsJson = "[]";
                              }
                              rows.removeWhere((element) => element[rowUniqueIdKey] == row[rowUniqueIdKey]);

                              //remove the unique key
                              rows.forEach((element) {
                                element.remove(rowUniqueIdKey);
                              });

                              updateConfig(item.key, json.encode(rows));
                            },
                            child: const Icon(material.Icons.delete),
                          ),
                        ],
                      ),
                    ),
                    width: 100,
                  ),
                ],
              ),
              const material.Divider(thickness: 0.4, indent: 0)
            ],
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  item.title,
                ),
              ),
              HyperlinkButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return WoxSettingPluginTableUpdate(
                            plugin: plugin,
                            item: item,
                            row: const {},
                            onUpdate: (key, row) {
                              var rowsJson = getSetting(key);
                              if (rowsJson == "") {
                                rowsJson = "[]";
                              }
                              var rows = json.decode(rowsJson);
                              rows.add(row);
                              //remove the unique key
                              rows.forEach((element) {
                                element.remove(rowUniqueIdKey);
                              });

                              updateConfig(key, json.encode(rows));
                            },
                          );
                        });
                  },
                  child: const Row(
                    children: [
                      Icon(material.Icons.add),
                      Text("Add"),
                    ],
                  )),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: material.Colors.grey[300]!),
            ),
            child: layout(
              children: [
                buildHeader(),
                buildRows(context),
              ],
              style: item.style,
            ),
          ),
        ],
      ),
    );
  }
}
