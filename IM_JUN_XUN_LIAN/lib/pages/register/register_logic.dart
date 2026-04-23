import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';

import '../../core/controller/app_controller.dart';

class RegisterLogic extends GetxController {
  final appLogic = Get.find<AppController>();
  final usernameCtrl = TextEditingController();
  final invitationCodeCtrl = TextEditingController();
  final enabled = false.obs;

  String get username => usernameCtrl.text.trim();

  @override
  void onClose() {
    usernameCtrl.dispose();
    invitationCodeCtrl.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    usernameCtrl.addListener(_onChanged);
    invitationCodeCtrl.addListener(_onChanged);
    super.onInit();
  }

  _onChanged() {
    enabled.value = needInvitationCodeRegister
        ? usernameCtrl.text.trim().isNotEmpty &&
            invitationCodeCtrl.text.trim().isNotEmpty
        : usernameCtrl.text.trim().isNotEmpty;
  }

  bool get needInvitationCodeRegister =>
      null != appLogic.clientConfigMap['needInvitationCodeRegister'] &&
      appLogic.clientConfigMap['needInvitationCodeRegister'] != '0';

  String? get invitationCode => IMUtils.emptyStrToNull(invitationCodeCtrl.text);

  void next() async {
    final uname = username;
    if (uname.isEmpty) {
      IMViews.showToast(StrRes.plsEnterUsername);
      return;
    }
    if (!IMUtils.isValidUsername(uname)) {
      IMViews.showToast(StrRes.usernameLengthInvalid);
      return;
    }
    if (needInvitationCodeRegister) {
      final code = invitationCode;
      if (code == null || code.isEmpty) {
        IMViews.showToast(StrRes.plsEnterInvitationCode);
        return;
      }
      // 校验邀请码
      final result = await LoadingView.singleton.wrap(
        asyncFunction: () => Apis.verifyInvitationCode(
          invitationCode: code,
        ),
      );
      if (result == null ||
          result.status != InvitationCodeVerifyStatus.success) {
        IMViews.showToast(StrRes.invalidInvitationCode);
        return;
      }
    }
    // 跳转到设置密码页面
    const defaultCode = '666666';
    AppNavigator.startSetPassword(
      areaCode: '+00',
      phoneNumber: uname,
      email: null,
      verificationCode: defaultCode,
      usedFor: 1,
      invitationCode: invitationCode,
    );
  }
}
