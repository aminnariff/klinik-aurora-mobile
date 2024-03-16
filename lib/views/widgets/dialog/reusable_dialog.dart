import 'package:klinik_aurora_mobile/config/color.dart';
import 'package:klinik_aurora_mobile/views/widgets/dialog/confirmation_dialog.dart';
import 'package:klinik_aurora_mobile/views/widgets/dialog/confirmation_dialog_attribute.dart';
import 'package:klinik_aurora_mobile/views/widgets/dialog/dialog.dart';
import 'package:klinik_aurora_mobile/views/widgets/dialog/dialog_attribute.dart';
import 'package:klinik_aurora_mobile/views/widgets/dialog/dialog_button_attribute.dart';
import 'package:klinik_aurora_mobile/views/widgets/dialog/dialog_type.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

showDialogError(BuildContext context, String text) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppDialog(
          DialogAttribute(text: text, type: DialogType.error),
        );
      });
}

showDialogSuccess(BuildContext context, String text) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppDialog(
          DialogAttribute(text: text, type: DialogType.success),
        );
      });
}

showConfirmDialog(BuildContext context, String bodyText) async {
  return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          ConfirmationDialogAttribute(
            type: DialogType.info,
            logo: SvgPicture.asset(
              'assets/icons/failed/warning.svg',
              height: 120,
              colorFilter: const ColorFilter.mode(Color(0XFF9200BA), BlendMode.srcIn),
            ),
            text: bodyText,
            confrimButton: DialogButtonAttribute(
              () {
                Navigator.pop(context, true);
              },
              text: 'Confirm',
              textColor: Colors.white,
            ),
            cancelButton: DialogButtonAttribute(
              () {
                Navigator.pop(context, false);
              },
              text: 'Cancel',
              color: const Color(0XFFEAEAEA),
              textColor: textPrimaryColor,
            ),
          ),
        );
      });
}
