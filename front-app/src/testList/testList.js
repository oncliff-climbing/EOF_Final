import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import './testList.css';

const List = () => {
  const [tests, setTests] = useState([]);
  const [expandedIndex, setExpandedIndex] = useState(null);
  const [resultData, setResultData] = useState({});
  const [selectedResult, setSelectedResult] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    const fetchTests = async () => {
      try {
        const response = await axios.get('http://localhost:8000/testcase');        
        const data = response.data.map(([id, target_url, test_name, user_num, user_plus_num, interval_time, plus_count]) => ({
          id,
          target_url,
          test_name,
          user_num,
          user_plus_num,
          interval_time,
          plus_count
        }));
        setTests(data);
      } catch (error) {
        console.error('Error fetching test cases:', error);
      }
    };

    fetchTests();
  }, []);

  const handleToggleDetail = (index) => {
    setExpandedIndex(prevIndex => (prevIndex === index ? null : index));
    setResultData({});
    setSelectedResult(null);
  };

  const handleDelete = async (index) => {
    const testToDelete = tests[index];
    const confirmed = window.confirm(`${testToDelete.test_name}을(를) 정말 삭제하시겠습니까?`);

    if (confirmed) {
      try {
        const idToDelete = testToDelete.id;
        await axios.delete(`http://localhost:8000/testcase/${idToDelete}`);
        const newTests = tests.filter((_, i) => i !== index);
        setTests(newTests);
      } catch (error) {
        console.error('Error deleting test case:', error);
      }
    }
  };

  const handleRun = (id, event) => {
    event.stopPropagation();
    
    const test = tests.find(t => t.id === id);
    if (test.user_plus_num === 0 || test.interval_time === 0 || test.plus_count === 0) {
      navigate(`/spikeTest/${id}`);
    } else {
      navigate(`/execute/${id}`);
    }
  };

  const handleResult = async (id, event) => {
    event.stopPropagation();
    try {
      const response = await axios.get(`http://localhost:8000/testcase/${id}/results`);

      setResultData(prevData => ({ ...prevData, [id]: response.data }));
      setExpandedIndex(tests.findIndex(test => test.id === id));
    } catch (error) {
      console.error('Error fetching results:', error);
    }
  };

  const handleSelectResult = (event) => {
    event.stopPropagation(); // Add this line to prevent the event from closing the details
    setSelectedResult(event.target.value);
  };

  const handleExecuteResult = (id) => {
    const test = tests.find(t => t.id === id);
    console.log(test.user_plus_num, test.interval_time, test.plus_count)
    if (test.user_plus_num === 0 || test.interval_time === 0 || test.plus_count === 0) {
      navigate(`/spikeResult/${id}`);
    } else {
      navigate(`/result/${id}`);
    }
  };

  const handleCompareResult = (id) => {
    if (selectedResult) {
      navigate(`/compare/${id}?compared=${selectedResult}`);
    }
  }

  return (
    <div className="List">
      <div className="list-page-title"><h2>Test Case List</h2></div>
      {tests.map((test, index) => (
        <div className="test-case" key={test.id} onClick={() => handleToggleDetail(index)}>
          <div className="test-info">
            <div className="test-name">{test.test_name}</div>
            <div className="test-url">{test.target_url}</div>
            <div className="test-actions">
              <button className="deleteTest" onClick={(e) => { e.stopPropagation(); handleDelete(index); }}>삭제</button>
              <button className="excuteTest" onClick={(e) => { e.stopPropagation(); handleRun(test.id, e); }}>실행</button>
              <button onClick={() => handleExecuteResult(test.id)}>결과</button>
              <button className="resultTest" onClick={(e) => { e.stopPropagation(); handleResult(test.id, e); }}>비교</button>
            </div>
          </div>
          {expandedIndex === index && (
            <div className="test-details" onClick={(e) => e.stopPropagation()}>
              <p>초기 유저 수 : {test.user_num}</p>
              <p>증가 유저 수 : {test.user_plus_num}</p>
              <p>증가 간격 : {test.interval_time}</p>
              <p>증가 횟수 : {test.plus_count}</p>
              {resultData[test.id] && (
                <div className="result-list">
                  <h3>결과 비교:</h3>
                  {resultData[test.id].map((result, index) => (
                    <React.Fragment key={result}>
                      <label>
                        <input
                          type="radio"
                          name={`result-${test.id}`}
                          value={result}
                          onChange={handleSelectResult}
                        />
                        {`test${index + 1}`}
                      </label>
                      {(index + 1) % 3 === 0 && <br />} {/* 한 줄당 3개의 요소가 출력되면 줄바꿈 */}
                    </React.Fragment>
                  ))}
                  <br></br>
                  <button onClick={() => handleCompareResult(test.id)}>실행</button>
                </div>
              )}
            </div>
          )}
        </div>
      ))}
    </div>
  );
}

export default List;
