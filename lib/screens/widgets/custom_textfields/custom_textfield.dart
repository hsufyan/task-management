import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../../bloc/setting/settings_bloc.dart';

class CustomTextField extends StatefulWidget {
  final String? subtitle;
  final String title;
  final String hinttext;
  final bool isRequired;
  final bool? isPassword;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final void Function(String?) onSaved;
  final void Function(String?)? onchange;
  final void Function(String)? onFieldSubmitted;
  final bool isLightTheme;
  final bool? readonly;
  final bool? currency;
  final double height;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled; // Added enabled parameter

  CustomTextField({
    super.key,
    required this.title,
    this.subtitle,
    this.currency,
    this.isPassword = false,
    this.readonly = false,
    required this.hinttext,
    this.isRequired = false,
    this.inputFormatters,
    double? height,
    required this.controller,
    this.keyboardType = TextInputType.text,
    required this.onSaved,
    this.onchange,
    this.onFieldSubmitted,
    required this.isLightTheme,
    this.enabled = true, // Default to true
  }) : height = height ?? 40.h;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _showPassword = true;
  String? currency;

  @override
  Widget build(BuildContext context) {
    currency = context.read<SettingsBloc>().currencySymbol;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: widget.title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16.sp,
                fontWeight: FontWeight.w700,
              ),
              if (widget.currency == true && currency != null)
                Text(
                  " ($currency) ",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.textClrChange,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (widget.isRequired)
                const Text(
                  " *",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              if (widget.subtitle != null)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 5.w),
                    child: CustomText(
                      text: widget.subtitle!,
                      color: AppColors.greyColor,
                      size: 12.sp,
                      fontWeight: FontWeight.w500,
                      maxLines: null,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        widget.height > 40.h
            ? IntrinsicHeight(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: widget.enabled ? Colors.grey : Colors.grey.withOpacity(0.5), // Greyed-out border when disabled
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: widget.enabled ? null : Colors.grey.withOpacity(0.2), // Greyed-out background when disabled
                  ),
                  child: TextFormField(
                    obscureText: widget.isPassword == true ? _showPassword : false,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: widget.enabled
                          ? Theme.of(context).colorScheme.textClrChange
                          : Theme.of(context).colorScheme.textClrChange.withOpacity(0.5), // Dim text when disabled
                    ),
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    maxLines: null,
                    minLines: 1,
                    onSaved: widget.onSaved,
                    onChanged: widget.onchange,
                    inputFormatters: widget.inputFormatters,
                    readOnly: widget.readonly == true || !widget.enabled, // Disable input when not enabled
                    onFieldSubmitted: widget.onFieldSubmitted,
                    decoration: InputDecoration(
                      hintText: widget.hinttext,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.greyForgetColor,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: widget.height > 40.h ? 10.h : 5.h,
                        horizontal: 10.w,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              )
            : Container(
                height: 40.h,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.enabled ? Colors.grey : Colors.grey.withOpacity(0.5), // Greyed-out border when disabled
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: widget.enabled ? null : Colors.grey.withOpacity(0.2), // Greyed-out background when disabled
                ),
                child: Center(
                  child: TextFormField(
                    obscureText: widget.isPassword == true ? _showPassword : false,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14.sp,
                      color: widget.enabled
                          ? Theme.of(context).colorScheme.textClrChange
                          : Theme.of(context).colorScheme.textClrChange.withOpacity(0.5), // Dim text when disabled
                    ),
                    controller: widget.controller,
                    keyboardType: widget.keyboardType,
                    maxLines: 1,
                    textAlignVertical: TextAlignVertical.center,
                    onSaved: widget.onSaved,
                    onChanged: widget.onchange,
                    inputFormatters: widget.inputFormatters,
                    readOnly: widget.readonly == true || !widget.enabled, // Disable input when not enabled
                    onFieldSubmitted: widget.onFieldSubmitted,
                    decoration: InputDecoration(
                      suffixIcon: widget.isPassword == true
                          ? InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: widget.enabled // Enable toggle only if field is enabled
                                  ? () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    }
                                  : null,
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(end: 10.w),
                                child: Icon(
                                  _showPassword ? Icons.visibility_off : Icons.visibility,
                                  color: Theme.of(context).colorScheme.fontColor.withValues(alpha: 0.4),
                                  size: 22.sp,
                                ),
                              ),
                            )
                          : null,
                      hintText: widget.hinttext,
                      hintStyle: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14.sp,
                        color: AppColors.greyForgetColor,
                      ),
                      contentPadding: widget.isPassword == true
                          ? EdgeInsets.symmetric(
                              vertical: (40.h) / 4,
                              horizontal: 10.w,
                            )
                          : EdgeInsets.symmetric(
                              vertical: (40.h) / 4,
                              horizontal: 10.w,
                            ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}