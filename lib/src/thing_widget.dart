import 'package:dart_wot/dart_wot.dart';
import 'package:flutter/material.dart';

import 'action_widget.dart';
import 'event_widget.dart';
import 'property_widget.dart';

/// A [StatelessWidget] representing a Thing.
class ThingWidget extends StatelessWidget {
  /// The [thingDescription] associated with this ThingWidget.
  final ThingDescription thingDescription;

  /// The maximum width of this Widget. Defaults to 400.
  final double maxWidth;

  final WoT _wot;

  /// Constructor.
  const ThingWidget(this.thingDescription, this._wot,
      {Key? key, this.maxWidth = 400})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final placeholder = Row(children: const [
      Text("Loading Thing Widget..."),
      CircularProgressIndicator()
    ]);

    return FutureBuilder<ConsumedThing>(
        future: _wot.consume(thingDescription),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return placeholder;
          }

          if (snapshot.hasError) {
            return ErrorWidget(snapshot.error!);
          }

          return _buildAffordanceWidgets(context, snapshot.data!);
        });
  }

  Widget _buildIcon(BuildContext context, ThingDescription thingDescription) {
    const iconSize = 36.0;
    const fallbackIcon = Icon(
      Icons.lightbulb,
      size: iconSize,
    );

    // TODO(JKRhb): Filter sizes
    final iconLinks =
        thingDescription.links.where((link) => link.rel == "icon");

    if (iconLinks.isNotEmpty) {
      final iconLink = iconLinks.first;

      // TODO(JKRhb): Ensure that href is always an absolute URL
      return Image.network(
        iconLink.href.toString(),
        height: iconSize,
        width: iconSize,
        errorBuilder: (context, object, stackTrace) => fallbackIcon,
      );
    }

    return fallbackIcon;
  }

  List<Widget> _buildHeader(BuildContext context, ConsumedThing consumedThing) {
    final description = consumedThing.thingDescription.description;
    Widget? subtitle;
    if (description != null) {
      subtitle = Text(
        description,
        style: Theme.of(context).textTheme.subtitle1,
      );
    }

    final List<Widget> children = [
      Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildIcon(context, consumedThing.thingDescription),
                    SizedBox.fromSize(
                      size: const Size(15, 0),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consumedThing.thingDescription.title,
                            style: Theme.of(context).textTheme.headline4,
                          ),
                          if (subtitle != null) subtitle
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const IconButton(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                ),
                onPressed: null,
              ),
            ],
          )),
    ];

    return children;
  }

  void _buildPropertyWidgets(
      List<Widget> widgets, ConsumedThing consumedThing) {
    final properties = consumedThing.thingDescription.properties;

    if (properties.isEmpty) {
      return;
    }

    widgets.add(const _InteractionAffordanceHeader("Properties"));

    for (final property in properties.keys) {
      widgets.add(PropertyWidget(property, consumedThing));
    }
  }

  void _buildActionWidgets(List<Widget> widgets, ConsumedThing consumedThing) {
    final actions = consumedThing.thingDescription.actions;

    if (actions.isEmpty) {
      return;
    }

    widgets.add(const _InteractionAffordanceHeader("Actions"));

    for (final action in actions.keys) {
      widgets.add(ActionWidget(action, consumedThing));
    }
  }

  void _buildEventWidgets(List<Widget> widgets, ConsumedThing consumedThing) {
    final events = consumedThing.thingDescription.events;

    if (events.isEmpty) {
      return;
    }

    widgets.add(const _InteractionAffordanceHeader("Events"));

    for (final event in events.keys) {
      widgets.add(EventWidget(event, consumedThing));
    }
  }

  Widget _buildAffordanceWidgets(
      BuildContext context, ConsumedThing consumedThing) {
    final widgets = _buildHeader(context, consumedThing);

    _buildPropertyWidgets(widgets, consumedThing);
    _buildActionWidgets(widgets, consumedThing);
    _buildEventWidgets(widgets, consumedThing);

    return Container(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.secondary),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 15),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: widgets,
            )),
      ),
      // ),
    );
  }
}

class _InteractionAffordanceHeader extends StatelessWidget {
  /// The type of this Affordance which will displayed in the UI.
  final String affordanceType;

  /// Constructor.
  const _InteractionAffordanceHeader(
    this.affordanceType, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(-1, 0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 0, 0),
        child: Text(
          affordanceType,
          style: Theme.of(context).textTheme.headline4,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}
