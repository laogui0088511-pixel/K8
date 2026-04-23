import 'dart:convert';

class ApiResp {
  int errCode;
  String errMsg;
  String errDlt;
  dynamic data;

  ApiResp.fromJson(Map<String, dynamic> map)
      : errCode = map["errCode"] ?? -1,
        errMsg = map["errMsg"] ?? '',
        errDlt = map["errDlt"] ?? '',
        data = map["data"];

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['errCode'] = errCode;
    data['errMsg'] = errMsg;
    data['errDlt'] = errDlt;
    data['data'] = data;
    return data;
  }

  @override
  String toString() {
    return jsonEncode(this);
  }
}

class ApiError {
  static String getMsg(int errorCode) {
    return _errorZH['$errorCode'] ?? '';
  }

  static const _errorZH = {
    '500': '服务器内部错误',
    '1001': '请求参数错误',
    '1002': '数据库错误',
    '1003': '服务器错误',
    '1004': '用户不存在',
    '1005': '记录未修改',
    '1006': '记录不存在',
    '1101': 'Token无效',
    '1102': 'Token过期',
    '1201': '被对方拉黑',
    '1301': '群组不存在',
    '1302': '不在群组中',
    '1303': '群组已满',
    '1401': '好友关系不存在',
    '1402': '已经是好友关系',
    '10001': '请求参数错误',
    '10002': '数据库错误',
    '10003': '服务器错误',
    '10006': '记录不存在',
    '20001': '密码错误',
    '20002': '账号不存在',
    '20003': '手机号已注册',
    '20004': '账号已注册',
    '20005': '验证码发送频繁，请稍后再试',
    '20006': '验证码错误',
    '20007': '验证码已过期',
    '20008': '验证码错误次数过多，请稍后再试',
    '20009': '验证码已使用',
    '20010': '邀请码已被使用',
    '20011': '邀请码不存在',
    '20012': '当前设备或IP受限，请稍后再试',
    '20013': '对方拒绝添加好友',
    '20014': '邮箱已注册',
  };
  static const _errorEN = {};
}
