import { ACCOUNT_URL } from '@/config';
import { request } from '@umijs/max';

export async function getVideoCallList(params: API.RtcManage.VideoParams) {
  try {
    const res = await request('/rtc/get_signal_invitation_records', {
      method: 'POST',
      data: {
        ...params,
      },
      headers: {
        isAccount: true,
      },
      baseURL: ACCOUNT_URL,
    });
    return {
      data: res?.data || { signalRecords: [], total: 0 },
      errCode: res?.errCode || 0,
      errMsg: res?.errMsg || '',
    };
  } catch (error) {
    console.error('获取通话记录失败:', error);
    return {
      data: { signalRecords: [], total: 0 },
      errCode: -1,
      errMsg: '获取数据失败',
    };
  }
}

export async function deleteVideoCall(params: API.RtcManage.DeleteVideoParams) {
  return request('/rtc/delete_signal_records', {
    method: 'POST',
    data: {
      ...params,
    },
    headers: {
      isAccount: true,
    },
    baseURL: ACCOUNT_URL,
  });
}

export async function getMeetingList(params: API.RtcManage.MeetingParams) {
  try {
    const res = await request('/rtc/get_meeting_records', {
      method: 'POST',
      data: {
        ...params,
      },
      headers: {
        isAccount: true,
      },
      baseURL: ACCOUNT_URL,
    });
    return {
      data: res?.data || { meetingRecords: [], total: 0 },
      errCode: res?.errCode || 0,
      errMsg: res?.errMsg || '',
    };
  } catch (error) {
    console.error('获取会议记录失败:', error);
    return {
      data: { meetingRecords: [], total: 0 },
      errCode: -1,
      errMsg: '获取数据失败',
    };
  }
}

export async function deleteMeeting(params: API.RtcManage.DeleteMeetingParams) {
  return request('/rtc/delete_meeting_records', {
    method: 'POST',
    data: {
      ...params,
    },
    headers: {
      isAccount: true,
    },
    baseURL: ACCOUNT_URL,
  });
}
