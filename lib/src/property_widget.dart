// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';
import 'package:flutter/material.dart';

/// A [StatefulWidget] that can be used to read, write, and observe properties
/// offered by a Thing.
class PropertyWidget extends StatefulWidget {
  /// The key of the property. Used to access it in the [consumedThing].
  final String propertyKey;

  /// The [ConsumedThing] associated with this property.
  final ConsumedThing consumedThing;

  /// Creates a new [PropertyWidget] for interacting with a property of a
  /// [ConsumedThing]. That property is specified by its [propertyKey].
  const PropertyWidget(this.propertyKey, this.consumedThing, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => PropertyState();
}

/// Represents the state of a property.
class PropertyState extends State<PropertyWidget> {
  /// The currently value of the propety.
  Object? _propertyValue;
  bool _updating = false;

  String get _propertyTitle {
    final title = widget
        .consumedThing.thingDescription.actions[widget.propertyKey]?.title;

    return title ?? widget.propertyKey;
  }

  String? get _propertyDescription {
    return widget.consumedThing.thingDescription.properties[widget.propertyKey]
        ?.description;
  }

  @override
  Widget build(BuildContext context) {
    // TODO(JKRhb): Find a more elegant solution
    final Widget button;

    if (_updating) {
      button = const CircularProgressIndicator();
    } else {
      button = IconButton(
          onPressed: _readProperty,
          icon: const Icon(
            Icons.refresh,
            size: 30,
          ));
    }

    Widget? description;
    if (_propertyDescription != null) {
      description = Text(
        _propertyDescription!,
        style: Theme.of(context).textTheme.subtitle2,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          _propertyTitle,
                          style: Theme.of(context).textTheme.headline5,
                          textAlign: TextAlign.left,
                        ),
                        if (description != null) description
                      ]),
                ),
                button
              ]),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Value',
                ),
                Text(
                  '${_propertyValue ?? "Unknown"}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _readProperty() async {
    setState(() {
      _updating = true;
    });

    final status =
        await widget.consumedThing.readProperty(widget.propertyKey, null);
    final value = await status.value();

    setState(() {
      _updating = false;
      _propertyValue = value.toString();
    });
  }
}
