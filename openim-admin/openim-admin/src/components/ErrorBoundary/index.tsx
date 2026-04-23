import React, { Component, ReactNode } from 'react';
import ChunkLoadError from './ChunkLoadError';

interface Props {
  children: ReactNode;
}

interface State {
  hasError: boolean;
  error?: Error;
  retryCount: number;
}

const MAX_RETRY_COUNT = 1;
const CHUNK_LOAD_ERROR_REGEX = /Loading chunk \d+ failed|Failed to fetch dynamically imported module/i;

class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: undefined,
      retryCount: 0,
    };
  }

  static getDerivedStateFromError(error: Error): State {
    return {
      hasError: true,
      error,
      retryCount: 0,
    };
  }

  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('ErrorBoundary caught an error:', error, errorInfo);

    // 检测是否是 chunk 加载错误
    if (CHUNK_LOAD_ERROR_REGEX.test(error.message)) {
      const { retryCount } = this.state;

      // 如果还没有达到最大重试次数，自动刷新页面
      if (retryCount < MAX_RETRY_COUNT) {
        console.log('Chunk load error detected, auto-reloading...');
        this.setState({ retryCount: retryCount + 1 });
        setTimeout(() => {
          window.location.reload();
        }, 1000);
      }
    }
  }

  handleRetry = () => {
    this.setState({
      hasError: false,
      error: undefined,
      retryCount: 0,
    });
    window.location.reload();
  };

  render() {
    const { hasError, error, retryCount } = this.state;

    if (hasError && retryCount >= MAX_RETRY_COUNT) {
      return <ChunkLoadError error={error} onRetry={this.handleRetry} />;
    }

    if (hasError && retryCount < MAX_RETRY_COUNT) {
      return <div style={{ textAlign: 'center', padding: '50px' }}>正在重新加载...</div>;
    }

    return this.props.children;
  }
}

export default ErrorBoundary;
