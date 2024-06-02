// execute.js

import React, { useState, useEffect, useRef } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import './execute.css';
import { Link } from 'react-router-dom';
import Loading from '../loading/loading.js';

const Execute = () => {
  const { id } = useParams();
  const [testData, setTestData] = useState(null);
  const isExecuted = useRef(false); // useRef로 실행 여부를 추적

  const executeTest = async () => {
    if (!isExecuted.current) { // isExecuted가 false일 때만 실행
      isExecuted.current = true; // 실행 후 true로 변경
      try {
        const response = await axios.get(`http://localhost:8000/testcase/${id}/execute/`);
        setTestData(response.data);
      } catch (error) {
        console.error('Error executing test:', error);
      }
    }
  };

  // const deleteTest = async () => {
  //   try {
  //     await axios.delete(`http://localhost:8000/testcase/${id}/stats/`);
  //     console.log('Test deleted successfully');
  //   } catch (error) {
  //     console.error('Error deleting test:', error);
  //   }
  // };

  useEffect(() => {
    console.log(1);
    // deleteTest(); // 삭제 요청 실행
    

    // 실행 요청을 삭제 요청 후에 보내도록 setTimeout 사용
    setTimeout(() => {
      executeTest();
    }, 1000); // 1초 후 실행

  }, []); // 빈 배열로 한 번만 실행되도록 설정

  return (
    <div className="Execute">
      
      {testData ? (
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
          <Loading />
        </div>
      )}
       
    </div>
  );
}

export default Execute;