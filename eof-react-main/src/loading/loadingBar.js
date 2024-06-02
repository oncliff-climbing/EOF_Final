import React from 'react';
import './loadingBar.css'; // 로딩 바 스타일을 위한 CSS 파일 import

const LoadingBar = ({ height, width, color }) => {
  return (
    <div className="loading-bar-container" style={{ height, width }}>
      <div className="loading-bar" style={{ backgroundColor: color }} />
    </div>
  );
};

export default LoadingBar;
