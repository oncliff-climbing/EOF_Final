import React from 'react';
import { Routes, Route, BrowserRouter } from 'react-router-dom';
import AddTestCaseForm from './addTest/addTest.js';
import ButtonGroup from './main/button.js';
import HeaderBar from './header/headerBar.js'
import List from './testList/testList.js'
import Result from './result/result.js';
import Execute from './execute/execute.js';
import Loading from './loading/loading.js';
import Spike from './spike/spike.js';
import Compare from './compare/compare.js'
import './App.css';


const RouterComponent = () => {
  return (
    <div className='myApp'>
      <BrowserRouter>
        <HeaderBar />
        <Routes>
          <Route path="/" element={<ButtonGroup />} />
          <Route path="/add" element={<AddTestCaseForm />} />
          <Route path="/list" element={<List />} />
          <Route path="/result/:id" element={<Result />} />
          <Route path="/execute/:id" element={<Execute />} />
          <Route path="/loading/:id" element={<Loading />} />
          <Route path="/spike/:id" element={<Spike />} />
          <Route path="/compare/:id" element={<Compare />}/>
        </Routes>
      </BrowserRouter>
    </div>
  );
}

export default RouterComponent;
