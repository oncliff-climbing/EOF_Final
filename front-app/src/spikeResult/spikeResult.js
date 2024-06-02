import React, { useState, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import './spikeResult.css'
import LoadingBar from '../loading/loadingBar';

// Spike 컴포넌트 정의
const Spike = () => {
  // 상태 선언
  const { id } = useParams();
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [elapsedTime, setElapsedTime] = useState(0); // 경과 시간 상태
  const [testCompleted, setTestCompleted] = useState(false); // 테스트 완료 여부 상태

  // 컴포넌트가 마운트될 때 호출되는 useEffect 훅
  useEffect(() => {
    // 데이터 가져오기 함수
    const executeTest = async () => {
      try {       
        // spike-stats 호출
        const test_id = id;
        const spikeResponse = await fetch(`http://localhost:8000/testcase/${test_id}/spike-stats/`);
        const spikeResult = await spikeResponse.json();
        if (!spikeResponse.ok) {
          throw new Error(`HTTP error! status: ${spikeResponse.status}`);
        }

        setData(spikeResult); // 데이터 상태 업데이트
        setLoading(false); // 로딩 상태 업데이트
        setTestCompleted(true); // 테스트 완료 상태 업데이트
      } catch (error) {
        setError(error); // 에러 상태 업데이트
        setLoading(false); // 로딩 상태 업데이트
      }
    };

    executeTest();
  }, [id]); // id가 변경될 때마다 useEffect가 실행되도록 함

  // 로딩 중일 때 렌더링
  if (loading) {
    return (
        <div className='spike-load'>
            <h2 className='spike-title'>Spike 테스트 중 ...</h2>
            <p className='timer'>경과 시간: {elapsedTime}초</p>
            {/* <LoadingBar height="20px" width={`${progress}%`} color="#007bff" /> */}
        </div>
    );
  };

  // 에러 발생 시 렌더링
  if (error) {
    return <div>Error: {error.message}</div>;
  }

  // 데이터가 있을 때 렌더링
return (
    <div className='spike'>
      <h2 className='spike-title'>Spike Result</h2>
      <div className='spikewrapper'>
        <div className='fail'>
            실패율 
            <br></br>
            <h1>❌</h1>
            <h2>{data[0][1]}%</h2>
        </div>
        <div className='user'>
            유저 수 
            <br></br>
            <h1>👥</h1>
            <h2>{data[0][3]}명</h2>
        </div>
        {testCompleted && 
        <div className='time'>
            경과 시간 
            <br></br>
            <h1>🕐</h1>
            <h2>{data[0][4]}초</h2>
        </div>}
      </div>
    </div>
  );
  
};

export default Spike;
