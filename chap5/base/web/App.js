import React from 'react';
import { Routes, Route } from 'react-router-dom';
import { Page } from './components/page';

export default function App() {
  return (
      <Routes>
        <Route path='/' element={<Page />} />
        <Route
          path="*"
          element={
            <main style={{ padding: "1rem" }}>
              <p>There's nothing here!</p>
            </main>
          }
        />
      </Routes>
  )
}