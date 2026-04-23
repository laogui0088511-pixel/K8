import 'package:flutter/material.dart';
import 'package:flutter_openim_sdk/flutter_openim_sdk.dart';
import 'package:get/get.dart';
import 'package:openim/pages/contacts/group_profile_panel/group_profile_panel_logic.dart';
import 'package:openim/routes/app_navigator.dart';
import 'package:openim_common/openim_common.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sprintf/sprintf.dart';

enum SearchType {
  user,
  group,
}

class AddContactsBySearchLogic extends GetxController {
  static const Duration _searchCooldown = Duration(seconds: 30);

  final refreshCtrl = RefreshController();
  final searchCtrl = TextEditingController();
  final focusNode = FocusNode();
  final userInfoList = <UserFullInfo>[].obs;
  final groupInfoList = <GroupInfo>[].obs;
  late SearchType searchType;
  int pageNo = 0;
  DateTime? _lastSearchAt;

  @override
  void onClose() {
    searchCtrl.dispose();
    focusNode.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    searchType = Get.arguments['searchType'] ?? SearchType.user;
    searchCtrl.addListener(() {
      if (searchKey.isEmpty) {
        focusNode.requestFocus();
        userInfoList.clear();
        groupInfoList.clear();
      }
    });
    super.onInit();
  }

  bool get isSearchUser => searchType == SearchType.user;

  String get searchKey => searchCtrl.text.trim();

  bool get isNotFoundUser => userInfoList.isEmpty && searchKey.isNotEmpty;

  bool get isNotFoundGroup => groupInfoList.isEmpty && searchKey.isNotEmpty;

  void search() {
    if (searchKey.isEmpty) return;
    if (!_canSearch()) {
      IMViews.showToast(StrRes.searchTooFrequent);
      return;
    }

    _lastSearchAt = DateTime.now();
    if (isSearchUser) {
      searchUser();
    } else {
      searchGroup();
    }
  }

  bool _canSearch() {
    if (_lastSearchAt == null) return true;
    return DateTime.now().difference(_lastSearchAt!) >= _searchCooldown;
  }

  void searchUser() async {
    var list = await LoadingView.singleton.wrap(
      asyncFunction: () => Apis.searchUserFullInfo(
        content: searchKey,
        pageNumber: pageNo = 1,
        showNumber: 200,
      ),
    );
    userInfoList.assignAll(
        (list ?? []).where((user) => _isExactUserMatch(user)).toList());
    refreshCtrl.refreshCompleted();
    refreshCtrl.loadNoData();
  }

  void loadMoreUser() async {
    refreshCtrl.refreshCompleted();
    refreshCtrl.loadNoData();
  }

  void searchGroup() async {
    var list = await OpenIM.iMManager.groupManager.getGroupsInfo(
      groupIDList: [searchKey],
    );
    groupInfoList.assignAll(list);
  }

  String getMatchContent(UserFullInfo userInfo) {
    // String searchPrefix = "";
    // if (keyword == userInfo.userID) {
    //   searchPrefix = StrRes.searchIDIs;
    // } else if (keyword == userInfo.phoneNumber) {
    //   searchPrefix = StrRes.searchPhoneIs;
    // } else if (keyword == userInfo.email) {
    //   searchPrefix = StrRes.searchEmailIs;
    // } else if (keyword == userInfo.nickname) {
    //   searchPrefix = StrRes.searchNicknameIs;
    // }
    if (_equals(userInfo.userID, searchKey)) {
      return '${StrRes.userID}: ${userInfo.userID ?? ''}';
    }
    return '${StrRes.userID}: ${userInfo.userID ?? ''}';
  }

  bool _isExactUserMatch(UserFullInfo userInfo) {
    return _equals(userInfo.userID, searchKey);
  }

  bool _equals(String? value, String keyword) {
    return (value ?? '').trim() == keyword;
  }

  String? getShowName(dynamic info) {
    if (info is UserFullInfo) {
      return info.nickname;
    } else if (info is GroupInfo) {
      return info.groupName;
    }
    return null;
  }

  void viewInfo(dynamic info) {
    if (info is UserFullInfo) {
      AppNavigator.startUserProfilePane(
        userID: info.userID!,
        nickname: info.nickname,
        faceURL: info.faceURL,
      );
    } else if (info is GroupInfo) {
      AppNavigator.startGroupProfilePanel(
        groupID: info.groupID,
        joinGroupMethod: JoinGroupMethod.search,
      );
    }
  }

  String getShowTitle(info) {
    if (!isSearchUser) {
      return sprintf(StrRes.searchGroupNicknameIs, [getShowName(info)]);
    }

    UserFullInfo userFullInfo = info;
    final account = userFullInfo.userID ?? '';
    final nickname = userFullInfo.nickname ?? '';

    if (nickname.isNotEmpty && nickname != account) {
      return '账号:$account（${StrRes.nickname}：$nickname）';
    }
    return '账号:$account';
  }
}
