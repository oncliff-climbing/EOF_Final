import React from 'react';
import './headerBar.css';
import { Link } from 'react-router-dom';

const HeaderBar = () => {
  return (
    <Link to='/'>
      <div className="header-bar">
        EOF TEST
      </div>
    </Link>
  );
};

export default HeaderBar;