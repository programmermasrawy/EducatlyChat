import 'package:educalty_chat/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

// ignore: must_be_immutable
class PhoneNumberWidget extends StatefulWidget {
  final Function(String phone) onChangePhone;
  final Function(String phone) onSubmitPhone;
  final Function(Country phone) onCountryChanged;
  Country country;
  final String? hint;
  final TextEditingController phone;
  final bool enabled;
  final String? Function(dynamic value)? validator;
  final List<FilteringTextInputFormatter>? inputFormatter;
  final TextInputAction? textInputAction;

  PhoneNumberWidget({
    super.key,
    required this.country,
    this.hint,
    required this.onChangePhone,
    required this.onCountryChanged,
    required this.onSubmitPhone,
    required this.phone,
    this.enabled = true,
    this.validator,
    this.textInputAction,
    this.inputFormatter,
  });

  @override
  State<PhoneNumberWidget> createState() => _PhoneNumberWidgetState();
}

class _PhoneNumberWidgetState extends State<PhoneNumberWidget> {
  final TextEditingController countryCtrl = TextEditingController();
  final phoneFocus = FocusNode();
  final error = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Card(
          elevation: 2,
          color: ChatAppColors.primaryColor,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            width: 90,
            height: 53,
            padding: const EdgeInsets.all(6),
            child: Center(
              child: IntlPhoneField(
                showCountryFlag: true,
                autofocus: false,
                obscureText: true,
                enabled: widget.enabled,
                showCursor: false,
                showDropdownIcon: false,
                cursorWidth: 0,
                controller: countryCtrl,
                disableLengthCheck: true,
                initialCountryCode: widget.country.code,
                onCountryChanged: (country) {
                  widget.country = country;
                  widget.phone.clear();
                  setState(() {});
                  widget.onCountryChanged(country);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: widget.phone,
            focusNode: phoneFocus,
            textInputAction: widget.textInputAction ?? TextInputAction.send,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp('[+]')),
              FilteringTextInputFormatter.deny(RegExp('[ ]')),
              ...[if (widget.inputFormatter != null) ...widget.inputFormatter!]
            ],
            onSaved: (tx) => widget.onSubmitPhone(tx!),
            validator: (value) {
              if (widget.validator != null) return widget.validator!(value);
              final phoneCheck = PhoneNumber.parse("+${widget.country.dialCode}${widget.phone.text}");
              if (phoneCheck.isValid(type: PhoneNumberType.mobile)) {
                if (phoneCheck.isoCode.name == widget.country.code) {
                  return null;
                } else {
                  return "Invalid phone number";
                }
              } else {
                return "Invalid phone number";
              }
            },
            onChanged: (value) => widget.onChangePhone(value),
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: widget.hint ?? 'Enter phone number',
              hintStyle: const TextStyle(color: Colors.grey),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey, width: 1),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          ),
        ),
      ],
    );
  }
}
