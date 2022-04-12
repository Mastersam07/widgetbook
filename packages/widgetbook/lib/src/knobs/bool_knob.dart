import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:widgetbook/src/knobs/knobs.dart';
import 'package:widgetbook/src/knobs/nullable_checkbox.dart';

class BoolKnob extends Knob<bool> {
  BoolKnob({
    required String label,
    String? description,
    required bool value,
  }) : super(
          label: label,
          description: description,
          value: value,
        );

  @override
  Widget build() => BooleanKnobWidget(
        label: label,
        description: description,
        value: value,
      );
}

class NullableBoolKnob extends Knob<bool?> {
  NullableBoolKnob({
    required String label,
    String? description,
    required bool? value,
  }) : super(
          label: label,
          description: description,
          value: value,
        );

  @override
  Widget build() => BooleanKnobWidget(
        label: label,
        description: description,
        value: value,
        nullable: true,
      );
}

class BooleanKnobWidget extends StatefulWidget {
  const BooleanKnobWidget({
    Key? key,
    required this.label,
    required this.description,
    required this.value,
    this.nullable = false,
  }) : super(key: key);

  final String label;
  final String? description;
  final bool? value;
  final bool nullable;

  @override
  State<BooleanKnobWidget> createState() => _BooleanKnobWidgetState();
}

class _BooleanKnobWidgetState extends State<BooleanKnobWidget> {
  bool value = false;

  @override
  void initState() {
    super.initState();
    if (widget.value != null) {
      value = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = widget.value == null;
    return KnobWrapper(
      description: widget.description,
      child: KnobWrapper(
        description: widget.description,
        child: ListTile(
          title: Text(widget.label, overflow: TextOverflow.ellipsis),
          dense: true,
          subtitle:
              widget.description == null ? null : Text(widget.description!),
          trailing: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Switch(
                key: Key('${widget.label}-switchTileKnob'),
                value: value,
                onChanged: disabled
                    ? null
                    : (v) {
                        setState(() {
                          value = v;
                        });
                        context.read<KnobsNotifier>().update(widget.label, v);
                      },
              ),
              NullableCheckbox(
                cachedValue: value,
                value: widget.value,
                label: widget.label,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
