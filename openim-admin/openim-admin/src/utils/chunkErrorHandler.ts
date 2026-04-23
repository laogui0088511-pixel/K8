/**
 * 处理动态导入（chunk）加载失败的工具函数
 */

import React from 'react';

const CHUNK_LOAD_ERROR_REGEX = /Loading chunk \d+ failed|Failed to fetch dynamically imported module/i;
const MAX_RELOAD_COUNT = 1;
const RELOAD_COUNT_KEY = 'chunk_reload_count';
const RELOAD_TIMESTAMP_KEY = 'chunk_reload_timestamp';
const RELOAD_TIMEOUT = 10000; // 10秒内的重载计数

/**
 * 检查是否是 chunk 加载错误
 */
export const isChunkLoadError = (error: Error): boolean => {
  return CHUNK_LOAD_ERROR_REGEX.test(error.message);
};

/**
 * 获取重载次数
 */
const getReloadCount = (): number => {
  const timestamp = Number(sessionStorage.getItem(RELOAD_TIMESTAMP_KEY) || 0);
  const now = Date.now();

  // 如果超过超时时间，重置计数
  if (now - timestamp > RELOAD_TIMEOUT) {
    sessionStorage.setItem(RELOAD_COUNT_KEY, '0');
    sessionStorage.setItem(RELOAD_TIMESTAMP_KEY, String(now));
    return 0;
  }

  return Number(sessionStorage.getItem(RELOAD_COUNT_KEY) || 0);
};

/**
 * 增加重载次数
 */
const incrementReloadCount = (): number => {
  const count = getReloadCount() + 1;
  sessionStorage.setItem(RELOAD_COUNT_KEY, String(count));
  sessionStorage.setItem(RELOAD_TIMESTAMP_KEY, String(Date.now()));
  return count;
};

/**
 * 处理 chunk 加载错误
 */
export const handleChunkError = (error: Error): void => {
  if (!isChunkLoadError(error)) {
    throw error;
  }

  const count = getReloadCount();

  if (count < MAX_RELOAD_COUNT) {
    console.warn(`Chunk loading failed, attempting reload (${count + 1}/${MAX_RELOAD_COUNT})...`);
    incrementReloadCount();
    window.location.reload();
  } else {
    console.error('Chunk loading failed after maximum retries');
    // 清除计数，避免影响下次访问
    sessionStorage.removeItem(RELOAD_COUNT_KEY);
    sessionStorage.removeItem(RELOAD_TIMESTAMP_KEY);
    throw error;
  }
};

/**
 * 包装动态导入，自动处理加载失败
 */
export const lazyWithRetry = <T extends React.ComponentType<any>>(
  importFunc: () => Promise<{ default: T }>,
): React.LazyExoticComponent<T> => {
  return React.lazy(async () => {
    try {
      return await importFunc();
    } catch (error) {
      handleChunkError(error as Error);
      // 如果没有重载，则重新抛出错误
      throw error;
    }
  });
};

/**
 * 全局监听未处理的 Promise 拒绝
 */
export const setupChunkErrorHandler = (): void => {
  window.addEventListener('unhandledrejection', (event) => {
    if (event.reason && isChunkLoadError(event.reason)) {
      event.preventDefault();
      handleChunkError(event.reason);
    }
  });
};
