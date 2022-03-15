require('!!file-loader?name=[name].[ext]!./index.html')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var createReactClass = require('create-react-class')

/* required css for our application */
require('./tonys.webflow/css/webflow.css');
require('./tonys.webflow/css/tonys.webflow.css');

var orders = [
  { remoteid: "000000189", custom: { customer: { full_name: "TOTO & CIE" }, billing_address: "Some where in the world" }, items: 2 },
  { remoteid: "000000190", custom: { customer: { full_name: "Looney Toons" }, billing_address: "The Warner Bros Company" }, items: 3 },
  { remoteid: "000000191", custom: { customer: { full_name: "Asterix & Obelix" }, billing_address: "Armorique" }, items: 29 },
  { remoteid: "000000192", custom: { customer: { full_name: "Lucky Luke" }, billing_address: "A Cowboy doesn't have an address. Sorry" }, items: 0 },
]
var key=0;

var Page = createReactClass({
  render() {
    return <JSXZ in="orders" sel=".container">
      <Z sel=".collection-item">
        {orders.map(order => (<JSXZ in="orders" sel=".table-line">
          <Z sel=".blockcommand">{order.remoteid}</Z>
          <Z sel=".blockcustomer">{order.custom.customer.full_name}</Z>
          <Z sel=".blockaddress">{order.custom.billing_address}</Z>
          <Z sel=".blockquantity">{order.items}</Z>
        </JSXZ>))
        }
      </Z>
    </JSXZ>
  }
})

ReactDOM.render(<Page />, document.getElementById('root'));