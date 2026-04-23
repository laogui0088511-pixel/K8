import { Result, Button } from 'antd';
import React from 'react';

interface ChunkLoadErrorProps {
  error?: Error;
  onRetry?: () => void;
}

const ChunkLoadError: React.FC<ChunkLoadErrorProps> = ({ error, onRetry }) => {
  const handleReload = () => {
    if (onRetry) {
      onRetry();
    } else {
      window.location.reload();
    }
  };

  return (
    <div style={{ 
      height: '100vh', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center' 
    }}>
      <Result
        status="warning"
        title="页面加载失败"
        subTitle={
          error?.message?.includes('chunk') 
            ? '页面资源加载失败，可能是由于网络问题或版本更新导致。请刷新页面重试。'
            : '页面加载时遇到问题，请刷新页面重试。'
        }
        extra={[
          <Button type="primary" key="reload" onClick={handleReload}>
            刷新页面
          </Button>,
        ]}
      />
    </div>
  );
};

export default ChunkLoadError;
