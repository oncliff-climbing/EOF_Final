import React from 'react';
import './button.css';
import { Link } from 'react-router-dom';

const ButtonGroup = () => {
  return (
    <div className="button-group">
      <Link to='/add'>
        <button className="btn">
          <h2>ADD</h2>
          <span className="tooltip1">새로운 테스트 케이스<br></br>추가하기</span>
        </button>
      </Link>
      <Link to='/list'>
        <button className="btn">
        <h2>LIST</h2>
          <span className="tooltip2">테스트 케이스 목록<br></br>보기 및 실행</span>
        </button>
      </Link>
    </div>
  );
};

export default ButtonGroup;
