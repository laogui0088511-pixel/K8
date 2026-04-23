import { message } from 'antd';

const VERSION_CHECK_INTERVAL = 5 * 60 * 1000; // 5分钟检查一次
const VERSION_KEY = 'app_version';
const LAST_CHECK_TIME_KEY = 'last_version_check_time';

/**
 * 获取当前应用版本（通过检查 index.html 的哈希）
 */
const fetchCurrentVersion = async (): Promise<string | null> => {
  try {
    const response = await fetch(`/index.html?t=${Date.now()}`, {
      cache: 'no-cache',
      headers: {
        'Cache-Control': 'no-cache',
        Pragma: 'no-cache',
      },
    });

    if (!response.ok) {
      return null;
    }

    const html = await response.text();
    // 提取脚本文件的哈希值作为版本标识
    const scriptMatch = html.match(/<script[^>]+src="[^"]*\.([a-f0-9]{8,})\.[^"]*\.js"/i);
    return scriptMatch ? scriptMatch[1] : null;
  } catch (error) {
    console.error('Failed to fetch version:', error);
    return null;
  }
};

/**
 * 检查版本更新
 */
export const checkVersion = async (silent = false): Promise<boolean> => {
  const now = Date.now();
  const lastCheckTime = Number(localStorage.getItem(LAST_CHECK_TIME_KEY) || 0);

  // 如果距离上次检查时间小于间隔时间，跳过检查
  if (now - lastCheckTime < VERSION_CHECK_INTERVAL && silent) {
    return false;
  }

  const currentVersion = await fetchCurrentVersion();
  if (!currentVersion) {
    return false;
  }

  const storedVersion = localStorage.getItem(VERSION_KEY);
  localStorage.setItem(LAST_CHECK_TIME_KEY, String(now));

  // 首次访问，存储版本
  if (!storedVersion) {
    localStorage.setItem(VERSION_KEY, currentVersion);
    return false;
  }

  // 版本不一致，说明有更新
  if (storedVersion !== currentVersion) {
    localStorage.setItem(VERSION_KEY, currentVersion);
    
    if (!silent) {
      message.warning({
        content: '检测到新版本，页面将在3秒后自动刷新...',
        duration: 3,
        onClose: () => {
          window.location.reload();
        },
      });

      setTimeout(() => {
        window.location.reload();
      }, 3000);
    }

    return true;
  }

  return false;
};

/**
 * 启动版本检查定时器
 */
export const startVersionCheck = (): void => {
  // 初始检查（静默）
  checkVersion(true);

  // 定期检查
  setInterval(() => {
    checkVersion(true);
  }, VERSION_CHECK_INTERVAL);

  // 页面获得焦点时检查
  window.addEventListener('focus', () => {
    checkVersion(true);
  });
};

/**
 * 手动触发版本检查并刷新
 */
export const manualCheckVersion = async (): Promise<void> => {
  const hasUpdate = await checkVersion(false);
  if (!hasUpdate) {
    message.success('当前已是最新版本');
  }
};
