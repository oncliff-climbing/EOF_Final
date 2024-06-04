import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import Loading from '../loading/loading.js';

const Execute = () => {
  const [testData, setTestData] = useState(null);
  const [isLoadingComplete, setIsLoadingComplete] = useState(false); // 작업 완료 여부를 상태로 관리

  // Loading 컴포넌트에서 작업이 완료되었을 때 호출할 함수
  const handleLoadingComplete = (testData) => {
    setTestData(testData); // 특정 값 설정
    setIsLoadingComplete(true); // 작업 완료 상태로 변경
  };

  return (
    <div className="Execute">
      {isLoadingComplete ? ( // 작업 완료 여부에 따라 UI를 변경
        <div>
          <h2>테스트가 완료되었습니다!</h2>
          <div className="test-details">
            <p>Test 이름: {testData.test_name}</p>
            <p>대상 URL: {testData.target_url}</p>
            <p>초기 유저 수: {testData.user_num} 명</p>
            <p>증가 유저 수: {testData.user_plus_num} 명</p>
            <p>증가 간격: {testData.interval_time} 초</p>
            <p>증가 횟수: {testData.plus_count} 번</p>
          </div>
          <Link to={`/result/${testData.test_id}`} className="result-button">결과 확인하기</Link>
        </div>
      ) : (
        <div>
          <Loading onComplete={handleLoadingComplete} /> {/* Loading 컴포넌트에 콜백 함수 전달 */}
        </div>
      )}
    </div>
  );
}

export default Execute; 
