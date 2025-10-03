import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskify/utils/widgets/custom_text.dart';

Widget detailMenu({required isEdit,required
// isDiscuss,required 

isDelete, required key, required context,
  required onpressEdit, required onpressDelete, onpressdiscuss}) {
  return ExpandableFab(
    key: key,
    openButtonBuilder: RotateFloatingActionButtonBuilder(
      child: HeroIcon(
        HeroIcons.ellipsisVertical,
        style: HeroIconStyle.solid,
        color: AppColors.pureWhiteColor,
        size: 30.sp,
      ),
      fabSize: ExpandableFabSize.regular,
      foregroundColor:
          Theme.of(context).colorScheme.textClrChange, // icon color
      backgroundColor: AppColors.primary, // main FAB background color
      angle: 3.14 * 2,
    ),
    closeButtonBuilder: FloatingActionButtonBuilder(
      size: 60.sp,
      builder: (BuildContext context, void Function()? onPressed,
          Animation<double> progress) {
        return FloatingActionButton(
          backgroundColor: AppColors.primary, // Same as your main FAB color
          onPressed: onPressed,
          shape: const CircleBorder(),
          child: HeroIcon(
            HeroIcons.xMark,
            style: HeroIconStyle.solid,
            color: AppColors.pureWhiteColor,
            size: 25.sp,
          ),
        );
      },
    ),
    // openCloseStackAlignment: Alignment.bottomRight, // Align at the bottom-right
    // distance: isDiscuss ?80.w:60.w, // Distance from the main FAB to its children
     // type: ExpandableFabType.fan,
   // type: !isDiscuss ?ExpandableFabType.up:ExpandableFabType.fan,
     fanAngle: 100,
    overlayStyle: ExpandableFabOverlayStyle(
      color: Colors.black.withValues(alpha:0.5),
      blur: 1,
    ),
    children: [
      // Column to stack buttons vertically
      isEdit == true
          ? FloatingActionButton.small(
              tooltip: AppLocalizations.of(context)!.editproject,
              backgroundColor: Color(0xffc0c8d2),
              heroTag: CustomText(
                text: AppLocalizations.of(context)!.createProj,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              onPressed: onpressEdit,
              child: HeroIcon(
                HeroIcons.pencil,
                style: HeroIconStyle.solid,
                color: Colors.blue,
                size: 20.sp,
              ),
            )
          : SizedBox.shrink(),
      // Delete button
      isDelete == true
          ? FloatingActionButton.small(
              tooltip: AppLocalizations.of(context)!.deleteProj,
              backgroundColor: Color(0xffdc9797),
              heroTag: CustomText(
                text: AppLocalizations.of(context)!.deleteProj,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              onPressed: onpressDelete,
              child: HeroIcon(
                HeroIcons.trash,
                style: HeroIconStyle.solid,
                color: AppColors.red,
                size: 20.sp,
              ),
            )
          : SizedBox.shrink(),
      // isDiscuss == true  ?FloatingActionButton.small(
      //   tooltip: AppLocalizations.of(context)!.deleteProj,
      //   backgroundColor: AppColors.mileStoneBgColor,
      //   heroTag: CustomText(
      //     text: AppLocalizations.of(context)!.deleteProj,
      //     color: Theme.of(context).colorScheme.textClrChange,
      //   ),
      //   onPressed: onpressdiscuss,
      //   child: HeroIcon(
      //     HeroIcons.ellipsisHorizontal,
      //     style: HeroIconStyle.solid,
      //     color: AppColors.mileStoneColor,
      //     size: 20.sp,
      //   ),
      // ):SizedBox()

      // isDelete == true
      //     ? FloatingActionButton.small(
      //   tooltip: AppLocalizations.of(context)!.deleteProj,
      //   backgroundColor: AppColors.photoBgColor,
      //   heroTag: CustomText(
      //     text: AppLocalizations.of(context)!.deleteProj,
      //     color: Theme.of(context).colorScheme.textClrChange,
      //   ),
      //   onPressed: onpressDelete,
      //   child: HeroIcon(
      //     HeroIcons.photo,
      //     style: HeroIconStyle.solid,
      //     color: AppColors.photoColor,
      //     size: 20.sp,
      //   ),
      // )
      //     : SizedBox.shrink(),
      // isDelete == true
      //     ? FloatingActionButton.small(
      //   tooltip: AppLocalizations.of(context)!.deleteProj,
      //   backgroundColor: AppColors.statusTimelineBgColor,
      //   heroTag: CustomText(
      //     text: AppLocalizations.of(context)!.deleteProj,
      //     color: Theme.of(context).colorScheme.textClrChange,
      //   ),
      //
      //   onPressed: onpressDelete,
      //   child: HeroIcon(
      //     HeroIcons.bars3,
      //     style: HeroIconStyle.solid,
      //     color: AppColors.statusTimelineColor,
      //     size: 20.sp,
      //   ),
      // )
      //     : SizedBox.shrink(),
      // isDelete == true
      //     ? FloatingActionButton.small(
      //   tooltip: AppLocalizations.of(context)!.deleteProj,
      //   backgroundColor:AppColors.activityLogColor,
      //   heroTag: CustomText(
      //     text: AppLocalizations.of(context)!.deleteProj,
      //     color: Theme.of(context).colorScheme.textClrChange,
      //   ),
      //   onPressed: onpressDelete,
      //   child: HeroIcon(
      //     HeroIcons.chartBar,
      //     style: HeroIconStyle.solid,
      //     color: AppColors.activityLogBgColor,
      //     size: 20.sp,
      //   ),
      // )
      //     : SizedBox.shrink(),
    ],
  );
}
