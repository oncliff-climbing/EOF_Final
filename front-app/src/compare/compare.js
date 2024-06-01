import React, { useEffect, useState, useRef } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import Chart from 'chart.js/auto';
import './compare.css';
import 'chartjs-adapter-date-fns';
import { useLocation } from 'react-router-dom';

const Result = () => {
  const { id } = useParams();
  console.log(id)
  const location = useLocation();
  const queryParams = new URLSearchParams(location.search);
  const selectedResult = queryParams.get('compared');


  const test_id = id;
  const [data, setData] = useState([[], []]);
  const [loading, setLoading] = useState(true); // Loading state 추가
  const preRpsChartRef = useRef(null);
  const currentRpsChartRef = useRef(null);
  const preResponseTimeChartRef = useRef(null);
  const currentResponseTimeChartRef = useRef(null);
  const preNumberOfUsersChartRef = useRef(null);
  const currentNumberOfUsersChartRef = useRef(null);
  const cleanChartRef1 = useRef(null);
  const cleanChartRef2= useRef(null);
  const cleanChartRef3 = useRef(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const current_response = await axios.get(`http://localhost:8000/testcase/${test_id}/stats/`);
        console.log(current_response.data)
        console.log("####################")
        const count = current_response.data[0][0]
        console.log(count)
        let pre_response_data = [];
        if (count !== 1) {
          console.log("**************************")
          console.log(selectedResult)
          const pre_response = await axios.get(`http://localhost:8000/testcase/${test_id}/stats/${selectedResult}`);
          console.log("&&&&&&&&&&&&&&&&&&&&&&")
          pre_response_data = pre_response.data;
        }

        const mergedData = [pre_response_data, current_response.data];
        setData(mergedData);
        setLoading(false); // 데이터 로딩 완료 후 로딩 상태 해제
      } catch (error) {
        console.error('데이터를 불러오는 중 오류가 발생했습니다:', error);
      }
    };

    fetchData();

    return () => {
      // 컴포넌트 언마운트 시 차트 정리
      if (preRpsChartRef.current) preRpsChartRef.current.destroy();
      if (currentRpsChartRef.current) currentRpsChartRef.current.destroy();
      if (preResponseTimeChartRef.current) preResponseTimeChartRef.current.destroy();
      if (currentResponseTimeChartRef.current) currentResponseTimeChartRef.current.destroy();
      if (preNumberOfUsersChartRef.current) preNumberOfUsersChartRef.current.destroy();
      if (currentNumberOfUsersChartRef.current) currentNumberOfUsersChartRef.current.destroy();
      if (cleanChartRef1.current) cleanChartRef1.current.destroy();
      if (cleanChartRef2.current) cleanChartRef2.current.destroy();
      if (cleanChartRef3.current) cleanChartRef3.current.destroy();
    };
  }, [test_id, selectedResult]);

  useEffect(() => {
    if (!loading) {
      drawCharts(data);
    }
  }, [data, loading]);

  // CANVAS에 글씨쓰기 (안되서 주석처리 해둠)
  // useEffect(() => {
  //   if (!loading && data[0].length === 0) {
  //     const canvas = document.getElementById('cleanChart1');
  //     const ctx = canvas.getContext('2d');
  //     ctx.font = '100px Arial';
  //     ctx.fillStyle = 'black';
  //     // console.log("asdfasdf")
  //     ctx.fillText('No Data', 10, 30);

  //   }
  // }, [loading, data]);

  // 차트 그리는 함수
  const drawCharts = (mergedData) => {
    let recordedTimes1 = [];
    let rpsValues1 = [];
    let responseTimes1 = [];
    let numberOfUsers1 = [];
    let preData = [];
    if (mergedData[0].length !== 0) {
      preData = mergedData[0];
      recordedTimes1 = preData.map(row => new Date(row[7] * 1000).toISOString().substr(11, 8));
      rpsValues1 = preData.map(row => row[3]);
      responseTimes1 = preData.map(row => row[5]);
      numberOfUsers1 = preData.map(row => row[6]);
    }
    const currentData = mergedData[1];
    const recordedTimes2 = currentData.map(row => new Date(row[7] * 1000).toISOString().substr(11, 8));
    const rpsValues2 = currentData.map(row => row[3]);
    const responseTimes2 = currentData.map(row => row[5]);
    const numberOfUsers2 = currentData.map(row => row[6]);

    const createChart = (ctx, labels, label, data, backgroundColor, borderColor) => {
      return new Chart(ctx, {
        type: 'line',
        data: {
          labels: labels,
          datasets: [{
            label: label,
            data: data,
            backgroundColor: backgroundColor,
            borderColor: borderColor,
            borderWidth: 1
          }]
        },
        options: {
          scales: {
            xAxes: [{
              type: 'time',
              time: {
                unit: 'minute' // 시간 단위 설정 (분)
              }
            }],
            yAxes: [{
              ticks: {
                beginAtZero: true
              }
            }]
          }
        }
      });
    };

    if (mergedData[0].length !== 0) {
      let order = '';
      if (selectedResult === "1") {
        order = "1st"
      } else if (selectedResult === "2") {
        order = "2nd"
      } else {
        order = String(selectedResult) + "th";
      }

      if (preRpsChartRef.current) preRpsChartRef.current.destroy();
      preRpsChartRef.current = createChart(
        document.getElementById('preRpsChart').getContext('2d'), 
        recordedTimes1, `${order} RPS`, rpsValues1, 'rgba(255, 99, 132, 0.2)', 'rgba(255, 99, 132, 1)'
      );

      // 과거 평균 응답 시간
      if (preResponseTimeChartRef.current) preResponseTimeChartRef.current.destroy();
      preResponseTimeChartRef.current = createChart(
        document.getElementById('preResponseTimeChart').getContext('2d'), 
        recordedTimes1, `${order} Response Time`, responseTimes1, 'rgba(54, 162, 235, 0.2)', 'rgba(54, 162, 235, 1)'
      );

      // 과거 유저 수
      if (preNumberOfUsersChartRef.current) preNumberOfUsersChartRef.current.destroy();
      preNumberOfUsersChartRef.current = createChart(
        document.getElementById('preNumberOfUsersChart').getContext('2d'), 
        recordedTimes1, `${order} Number of Users`, numberOfUsers1, 'rgba(75, 192, 192, 0.2)', 'rgba(75, 192, 192, 1)'
      );
    } else {
            // 클린 차트1
            if (cleanChartRef1.current) cleanChartRef1.current.destroy();
            cleanChartRef1.current = createChart(
              document.getElementById('cleanChart1').getContext('2d'), recordedTimes2, 'pre Test RPS', '', 'rgba(255, 99, 132, 0.2)', 'rgba(255, 99, 132, 1)');
            // 클린 차트2
            if (cleanChartRef2.current) cleanChartRef2.current.destroy();
            cleanChartRef2.current = createChart(
              document.getElementById('cleanChart2').getContext('2d'), recordedTimes2, 'pre Test Response Time', '','rgba(54, 162, 235, 0.2)', 'rgba(54, 162, 235, 1)');
            // 클린 차트3
            if (cleanChartRef3.current) cleanChartRef3.current.destroy();
            cleanChartRef3.current = createChart(
              document.getElementById('cleanChart3').getContext('2d'), recordedTimes2, 'pre Test Number of Users', '', 'rgba(75, 192, 192, 0.2)', 'rgba(75, 192, 192, 1)');
    }
    // 현재 RPS
    if (currentRpsChartRef.current) currentRpsChartRef.current.destroy();
    currentRpsChartRef.current = createChart(
      document.getElementById('currentRpsChart').getContext('2d'), 
      recordedTimes2, 'Current Test RPS', rpsValues2, 'rgba(255, 99, 132, 0.2)', 'rgba(255, 99, 132, 1)'
    );
    // 현재 평균 응답 시간
    if (currentResponseTimeChartRef.current) currentResponseTimeChartRef.current.destroy();
    currentResponseTimeChartRef.current = createChart(
      document.getElementById('currentResponseTimeChart').getContext('2d'), 
      recordedTimes2, 'Current Test Response Time', responseTimes2, 'rgba(54, 162, 235, 0.2)', 'rgba(54, 162, 235, 1)'
    );          
    // 현재 유저 수
    if (currentNumberOfUsersChartRef.current) currentNumberOfUsersChartRef.current.destroy();
    currentNumberOfUsersChartRef.current = createChart(
      document.getElementById('currentNumberOfUsersChart').getContext('2d'), 
      recordedTimes2, 'Current Test Number of Users', numberOfUsers2, 'rgba(75, 192, 192, 0.2)', 'rgba(75, 192, 192, 1)'
    );
  };

  return (
    <div className="result">
      <h2>Incremental Data</h2>
      <div className="charts-container" style={{ width: '100%', display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)' }}>
        <div style={{ gridColumn: '1 / 2' }}>
          {data[0] && data[0].length > 0 && (
            <>
              <h3><center>{selectedResult}번째 결과</center></h3>
              <canvas id="preRpsChart"></canvas>
              <canvas id="preResponseTimeChart"></canvas>
              <canvas id="preNumberOfUsersChart"></canvas>
            </>
          )}
          {data[0] && data[0].length === 0 && (
            <>
              <h3><center>{selectedResult}번째 결과</center></h3>
              <canvas id="cleanChart1"></canvas>
              <canvas id="cleanChart2"></canvas>
              <canvas id="cleanChart3"></canvas>
            </> 
          )}
        </div>

        <div style={{ gridColumn: '2 / 3' }}>
          <h3><center>최신 결과</center></h3>
          <canvas id="currentRpsChart"></canvas>
          <canvas id="currentResponseTimeChart"></canvas>
          <canvas id="currentNumberOfUsersChart"></canvas>
        </div>
      </div>
    </div>
  );
}

export default Result;
