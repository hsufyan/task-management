import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskify/config/colors.dart';

import '../../utils/widgets/custom_text.dart';

class DatePickerWidget extends StatelessWidget {
  final TextEditingController dateController;
  final String title;
  final bool? star;
  final bool? width;
  final String? titlestartend;
  final double? size;
  final void Function()? onTap;
  final bool isLightTheme;

  const DatePickerWidget({
    super.key,
    required this.dateController,
    this.size,
    this.width,
    this.star,
    required this.title,
    this.titlestartend,
    this.onTap,
    required this.isLightTheme,
  });



  @override
  Widget build(BuildContext context) {
    print("zkgfdnm,  ${dateController.text}");
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width == true ? 0 : 0.sp),
          child: Row(
            children: [
              CustomText(
                text: title,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(width: 5.h),
              titlestartend != null
                  ? CustomText(
                text: titlestartend!,
                color: AppColors.greyColor,
                size: 12.sp,
                fontWeight: FontWeight.w700,
              )
                  : SizedBox(),
              star == true
                  ? CustomText(
                text: " *",
                color: Colors.red,
                size: 15,
                fontWeight: FontWeight.w400,
              )
                  : SizedBox(),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          height: 40.h,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.greyColor),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center( // ✅ Ensures vertical centering
            child: TextFormField(
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: size ?? 14.sp,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              readOnly: true,
              onTap: onTap,
              controller: dateController,
              textAlignVertical: TextAlignVertical.center, // ✅ Centers text vertically
              textAlign: TextAlign.start, // ✅ Keeps text aligned to the left
              decoration: InputDecoration(

                  hintText: (dateController.text.isEmpty || dateController.text.trim() == "null")
                      ? AppLocalizations.of(context)!.selectdate
                      : dateController.text,


                hintStyle: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                isCollapsed: true, // ✅ Removes extra padding
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w), // ✅ Horizontal padding
                border: InputBorder.none,
              ),
            ),
          ),
        )


      ],
    );
  }
}

