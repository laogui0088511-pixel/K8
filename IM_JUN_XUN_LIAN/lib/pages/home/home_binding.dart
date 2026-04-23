import 'package:get/get.dart';
import 'package:openim_common/openim_common.dart';
// ignore: implementation_imports
import 'package:openim_working_circle/src/pages/work_moments_list/work_moments_list_logic.dart';

import '../contacts/contacts_logic.dart';
import '../conversation/conversation_logic.dart';
import '../mine/mine_logic.dart';
import 'home_logic.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    GetTags.createMomentsTag();
    Get.lazyPut(() => HomeLogic());
    Get.lazyPut(() => ConversationLogic());
    Get.lazyPut(() => ContactsLogic());
    Get.lazyPut(() => MineLogic());
    Get.lazyPut(() => WorkMomentsListLogic(), tag: GetTags.moments);
  }
}
