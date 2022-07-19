// Copyright 2022 The NAMIB Project Developers. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:dart_wot/dart_wot.dart';
import 'package:flutter/material.dart';

/// A [StatefulWidget] that can be used to trigger actions offered by Thing.
class ActionWidget extends StatefulWidget {
  /// The [ConsumedThing] associated with this action.
  final ConsumedThing consumedThing;

  /// The key of the action. Used to access it in the [consumedThing].
  final String actionKey;

  /// Creates a new [ActionWidget] for invoking an action of a [ConsumedThing].
  /// That action is specified by its [actionKey].
  const ActionWidget(this.actionKey, this.consumedThing, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => ActionState();
}

/// Represents the state of an action.
class ActionState extends State<ActionWidget> {
  Object? _actionOutput;
  bool _updating = false;

  String get _actionTitle {
    final title =
        widget.consumedThing.thingDescription.actions[widget.actionKey]?.title;

    return title ?? widget.actionKey;
  }

  String? get _actionDescription {
    return widget
        .consumedThing.thingDescription.actions[widget.actionKey]?.description;
  }

  @override
  Widget build(BuildContext context) {
    // TODO(JKRhb): Find a more elegant solution
    final Widget button;

    if (_updating) {
      button = const CircularProgressIndicator();
    } else {
      button = IconButton(
        onPressed: _invokeAction,
        icon: const Icon(
          Icons.arrow_circle_up,
          size: 30,
        ),
      );
    }

    final description = _actionDescription;

    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _actionTitle,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    if (description != null) Text(description),
                  ],
                ),
              ),
              button,
            ],
          ),
          if (_actionOutput != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0, 15, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Value'),
                  Text('$_actionOutput'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _invokeAction() async {
    setState(() {
      _updating = true;
    });
    // TODO(JKRhb): Add support for input values
    final status =
        await widget.consumedThing.invokeAction(widget.actionKey, null, null);
    var value = await status.value();

    if (value == "") {
      value = null;
    }

    setState(() {
      _updating = false;
      _actionOutput = value;
    });
  }
}
