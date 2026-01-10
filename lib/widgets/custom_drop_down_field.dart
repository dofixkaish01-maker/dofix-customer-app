import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/dimensions.dart';
import '../utils/styles.dart';

class CustomDropdownField extends StatefulWidget {
  final String hintText;
  final String? selectedValue;
  final List<String>? selectedValues;
  final List<String> options;
  final Function(dynamic) onChanged;
  final bool showBorder;
  final bool showTitle;
  final bool required;
  final String? Function(dynamic)? validator;
  final bool isMultiple;

  const CustomDropdownField({
    Key? key,
    required this.hintText,
    this.selectedValue,
    this.selectedValues,
    required this.options,
    required this.onChanged,
    this.showBorder = true,
    this.showTitle = false,
    this.required = false,
    this.validator,
    this.isMultiple = false,
  }) : super(key: key);

  @override
  State<CustomDropdownField> createState() => _CustomDropdownFieldState();
}

class _CustomDropdownFieldState extends State<CustomDropdownField> {
  List<String> _selectedValues = [];

  @override
  void initState() {
    super.initState();
    if (widget.isMultiple && widget.selectedValues != null) {
      _selectedValues = List.from(widget.selectedValues!);
    }
  }

  void _onMultiSelect(BuildContext context) async {
    final List<String> tempSelected = List.from(_selectedValues);

    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text("Select Options"),
              content: SingleChildScrollView(
                child: Column(
                  children: widget.options.map((option) {
                    final isSelected = tempSelected.contains(option);
                    return CheckboxListTile(
                      value: isSelected,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(child: Text(option)),
                          if (isSelected) Icon(Icons.check, color: Colors.green),
                        ],
                      ),
                      onChanged: (bool? isChecked) {
                        setDialogState(() {
                          if (isChecked == true) {
                            tempSelected.add(option);
                          } else {
                            tempSelected.remove(option);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, tempSelected),
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() {
        _selectedValues = result;
      });
      widget.onChanged(_selectedValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showTitle)
          Text(
            widget.hintText,
            style: albertSansRegular.copyWith(fontSize: Dimensions.fontSize12),
          ),
        SizedBox(height: widget.showTitle ? 5 : 0),
        GestureDetector(
          onTap: widget.isMultiple ? () => _onMultiSelect(context) : null,
          child: AbsorbPointer(
            absorbing: widget.isMultiple,
            child: DropdownButtonFormField<String>(
              value: widget.isMultiple ? null : widget.selectedValue,
              decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.black.withOpacity(0.3),
                  ),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.red,
                  ),
                ),
                focusedErrorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2,
                    color: Colors.red,
                  ),
                ),
                hintText: widget.isMultiple
                    ? (_selectedValues.isEmpty ? widget.hintText : _selectedValues.join(", "))
                    : widget.hintText,
                hintStyle: albertSansRegular.copyWith(
                  fontSize: Dimensions.fontSize14,
                  color: Theme.of(context).hintColor,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
              ),
              items: widget.isMultiple
                  ? []
                  : widget.options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: widget.isMultiple
                  ? null
                  : (newValue) {
                widget.onChanged(newValue);
              },
              isExpanded: true,
              validator: (value) {
                if (widget.required) {
                  if (widget.isMultiple) {
                    if (_selectedValues.isEmpty) return 'This field is required';
                  } else {
                    if (value == null || value.isEmpty) return 'This field is required';
                  }
                }
                return widget.validator?.call(value);
              },
            ),
          ),
        ),
      ],
    );
  }
}
