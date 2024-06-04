import React, { useEffect, useState, useRef } from 'react';
import { useParams } from 'react-router-dom';
import axios from 'axios';
import Chart from 'chart.js/auto';
import './loading.css';

const Loading = ({ onDataLoadComplete }) => { // 콜백 함수를 props로 받음
  const { id } = useParams();
  const [data, setData] = useState([]);
  const rpsChartRef = useRef(null);
  const responseTimeChartRef = useRef(null);
  const numberOfUsersChartRef = useRef(null);

  useEffect(() => {
    const fetchData = async () => {
      try {
        const response = await axios.get(`http://www.cloudeof.com:8080/testcase/${id}/stats/`);
        setData(response.data);
        drawCharts(response.data);
      } catch (error) {
        console.error('데이터를 불러오는 중 오류가 발생했습니다:', error);
      }
    };

    const executeTest = async () => {
      try {
        const response = await axios.get(`http://www.cloudeof.com:8080/testcase/${id}/execute/`);
        console.log('데이터가 성공적으로 저장되었습니다.');
        setData(response.data);
        fetchData();
      } catch (error) {
        console.error('Error executing test:', error);
      }
    };

    executeTest();

    return () => {
      if (rpsChartRef.current) rpsChartRef.current.destroy();
      if (responseTimeChartRef.current) responseTimeChartRef.current.destroy();
      if (numberOfUsersChartRef.current) numberOfUsersChartRef.current.destroy();
    };
  }, [id, onDataLoadComplete]);

  

  // 차트 그리는 함수
  const drawCharts = (data) => {
    const recordedTimes = data.map(row => new Date(row[7] * 1000).toISOString().substr(11, 8));
    const rpsValues = data.map(row => row[3]);
    const responseTimes = data.map(row => row[5]);
    const numberOfUsers = data.map(row => row[6]);

    // 기존 차트가 있으면 제거
    if (rpsChartRef.current) rpsChartRef.current.destroy();
    if (responseTimeChartRef.current) responseTimeChartRef.current.destroy();
    if (numberOfUsersChartRef.current) numberOfUsersChartRef.current.destroy();

    // RPS 차트
    var ctx1 = document.getElementById('rpsChart').getContext('2d');
    rpsChartRef.current = new Chart(ctx1, {
      type: 'line',
      data: {
        labels: recordedTimes,
        datasets: [{
          label: 'RPS',
          data: rpsValues,
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          borderColor: 'rgba(255, 99, 132, 1)',
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

    // Response Time 차트
    var ctx2 = document.getElementById('responseTimeChart').getContext('2d');
    responseTimeChartRef.current = new Chart(ctx2, {
      type: 'line',
      data: {
        labels: recordedTimes,
        datasets: [{
          label: 'Response Time',
          data: responseTimes,
          backgroundColor: 'rgba(54, 162, 235, 0.2)',
          borderColor: 'rgba(54, 162, 235, 1)',
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

    // Number of Users 차트
    var ctx3 = document.getElementById('numberOfUsersChart').getContext('2d');
    numberOfUsersChartRef.current = new Chart(ctx3, {
      type: 'line',
      data: {
        labels: recordedTimes,
        datasets: [{
          label: 'Number of Users',
          data: numberOfUsers,
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          borderColor: 'rgba(75, 192, 192, 1)',
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

  return (
    <div>
    <div className="loading">
      <h2>Incremental 테스트 진행 중 ...</h2>

      {/* 차트 컨테이너 */}
      <div className="charts-container" style={{ width: '90vw', display: 'grid', gridTemplateColumns: 'repeat(1, 1fr)' }}>
        {/* RPS 차트 */}
        <canvas id="rpsChart" width="800" height="150"></canvas>
        {/* Response Time 차트 */}
        <canvas id="responseTimeChart" width="800" height="150"></canvas>
        {/* Number of Users 차트 */}
        <canvas id="numberOfUsersChart" width="800" height="150"></canvas>
      </div>
      
    </div>
    </div>
  );
}

export default Loading;
