import React from 'react';
import { Routes, Route, BrowserRouter } from 'react-router-dom';
import AddTestCaseForm from './addTest/addTest.js';
import ButtonGroup from './main/button.js';
import Result from './result/result.js';

const RouterComponent = () => {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<ButtonGroup />} />
        <Route path="/add" element={<AddTestCaseForm />} />
        <Route path="/result" element={<Result />} />
      </Routes>
    </BrowserRouter>
  );
}

export default RouterComponent;
