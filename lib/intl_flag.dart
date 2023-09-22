library intl_phone_field;

import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';

import './countries.dart';

class IntlFlag extends StatefulWidget {
  final TextAlign textAlign;
  final VoidCallback? onTap;
  final ValueChanged<Country>? onCountryChanged;
  final bool enabled;
  final String languageCode;
  final InputDecoration decoration;

  /// 2 letter ISO Code or country dial code.
  ///
  /// ```dart
  /// initialCountryCode: 'IN', // India
  /// initialCountryCode: '+225', // Côte d'Ivoire
  /// ```
  final String? initialCountryCode;

  /// List of Country to display see countries.dart for format
  final List<Country>? countries;
  final TextStyle? style;

  final BoxDecoration dropdownDecoration;

  /// The text that describes the search input field.
  ///
  /// When the input field is empty and unfocused, the label is displayed on top of the input field (i.e., at the same location on the screen where text may be entered in the input field).
  /// When the input field receives focus (or if the field is non-empty), the label moves above (i.e., vertically adjacent to) the input field.
  final String searchText;

  /// Whether to show or hide country flag.
  ///
  /// Default value is `true`.
  final bool showCountryFlag;

  /// The padding of the Flags Button.
  ///
  /// The amount of insets that are applied to the Flags Button.
  ///
  /// If unset, defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry flagsButtonPadding;

  /// Optional set of styles to allow for customizing the country search
  /// & pick dialog
  final PickerDialogStyle? pickerDialogStyle;

  /// The margin of the country selector button.
  ///
  /// The amount of space to surround the country selector button.
  ///
  /// If unset, defaults to [EdgeInsets.zero].
  final EdgeInsets flagsButtonMargin;

  const IntlFlag({
    Key? key,
    this.initialCountryCode,
    this.languageCode = 'en',
    this.textAlign = TextAlign.left,
    this.onTap,
    this.decoration = const InputDecoration(),
    this.style,
    this.countries,
    this.onCountryChanged,
    this.dropdownDecoration = const BoxDecoration(),
    this.enabled = true,
    @Deprecated('Use searchFieldInputDecoration of PickerDialogStyle instead') this.searchText = 'Search country',
    this.showCountryFlag = true,
    this.flagsButtonPadding = EdgeInsets.zero,
    this.pickerDialogStyle,
    this.flagsButtonMargin = EdgeInsets.zero,
  }) : super(key: key);

  @override
  _IntlFlagState createState() => _IntlFlagState();
}

class _IntlFlagState extends State<IntlFlag> {
  late List<Country> _countryList;
  late Country _selectedCountry;
  late List<Country> filteredCountries;

  @override
  void initState() {
    super.initState();
    _countryList = widget.countries ?? countries;
    filteredCountries = _countryList;
    _selectedCountry = _countryList.firstWhere((item) => item.code == (widget.initialCountryCode ?? 'TR'),
        orElse: () => _countryList.first);
  }

  Future<void> _changeCountry() async {
    filteredCountries = _countryList;
    await showModalBottomSheet(
      context: context,
      useRootNavigator: false,
      builder: (context) => StatefulBuilder(
        builder: (ctx, setState) => CountryPickerDialog(
          showDialCodes: false,
          languageCode: widget.languageCode.toLowerCase(),
          style: widget.pickerDialogStyle,
          filteredCountries: filteredCountries,
          searchText: widget.searchText,
          countryList: _countryList,
          selectedCountry: _selectedCountry,
          onCountryChanged: (Country country) {
            _selectedCountry = country;
            widget.onCountryChanged?.call(country);
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return _buildFlagsButton();
  }

  Container _buildFlagsButton() {
    return Container(
      margin: widget.flagsButtonMargin,
      child: DecoratedBox(
        decoration: widget.dropdownDecoration,
        child: InkWell(
          borderRadius: widget.dropdownDecoration.borderRadius as BorderRadius?,
          onTap: widget.enabled ? _changeCountry : null,
          child: Padding(
            padding: widget.flagsButtonPadding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(
                  width: 4,
                ),
                if (widget.showCountryFlag) ...[
                  kIsWeb
                      ? Image.asset(
                          'assets/flags/${_selectedCountry.code.toLowerCase()}.png',
                          package: 'intl_phone_field',
                          width: 32,
                        )
                      : Text(
                          _selectedCountry.flag,
                          style: const TextStyle(fontSize: 18),
                        ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum IconPosition {
  leading,
  trailing,
}
