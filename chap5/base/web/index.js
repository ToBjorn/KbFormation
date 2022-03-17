import './tonys.webflow/css/webflow.css';
import './tonys.webflow/css/tonys.webflow.css';
import '!!file-loader?name=[name].[ext]!./index.html'
import React from 'react';
import { render } from 'react-dom';
import {BrowserRouter} from 'react-router-dom';
import App from './App';

//const baseUrl = document.getElementsByTagName('base')[0].getAttribute('href');
const rootElement = document.getElementById('root');

render(
    <BrowserRouter>
        <App />
    </BrowserRouter>,
    rootElement
);