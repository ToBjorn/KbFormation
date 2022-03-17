require('!!file-loader?name=[name].[ext]!./index.html')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var Qs = require("qs")
var Cookie = require("cookie")
var createReactClass = require('create-react-class')

/* required css for our application */
require('./tonys.webflow/css/webflow.css');
require('./tonys.webflow/css/tonys.webflow.css');

var Layout = createReactClass({
  render() {
    return <JSXZ in="orders" sel=".layout">
      <Z sel=".layout-container">
        <this.props.Child {...this.props} />
      </Z>
    </JSXZ>
  }
})

var Header = createReactClass({
  render() {
    return <JSXZ in="orders" sel=".layout-container">
      <Z sel=".header-container">
        <this.props.Child {...this.props} />
      </Z>
    </JSXZ>
  }
})

var Orders = createReactClass({
  render() {
    return <JSXZ in="orders" sel=".header-container">
      <Z sel=".orders-container"><ChildrenZ /></Z>
    </JSXZ>
  }
})

var Order = createReactClass({
  render() {
    return <JSXZ in="order-details" sel=".header-container">
      <Z sel=".orders-container"><ChildrenZ /></Z>
    </JSXZ>
  }
})

var Child = createReactClass({
  render() {
    var [ChildHandler, ...rest] = this.props.handlerPath
    return <ChildHandler {...this.props} handlerPath={rest} />
  }
})

var ErrorPage = createReactClass({
  render() {
    return <div style={{ padding: "1rem" }}>
      <p>{this.props.code}</p>
      <p>{this.props.message}</p>
    </div>
  }
})

var routes = {
  "orders": {
    path: (params) => {
      return "/";
    },
    match: (path, qs) => {
      return (path == "/") && { handlerPath: [Layout, Header, Orders] } // Note that we use the "&&" expression to simulate a IF statement
    }
  },
  "order": {
    path: (params) => {
      return "/order/" + params;
    },
    match: (path, qs) => {
      var r = new RegExp("/order/([^/]*)$").exec(path)
      return r && { handlerPath: [Layout, Header, Order], order_id: r[1] } // Note that we use the "&&" expression to simulate a IF statement
    }
  }
}

var browserState = { Child: Child }

function onPathChange() {
  var path = location.pathname
  var qs = Qs.parse(location.search.slice(1))
  var cookies = Cookie.parse(document.cookie)

  browserState = {
    ...browserState,
    path: path,
    qs: qs,
    cookie: cookies
  }

  var route;

  // We try to match the requested path to one our our routes
  for (var key in routes) {
    routeProps = routes[key].match(path, qs)
    if (routeProps) {
      route = key
      break;
    }
  }
  // We add the route name and the route Props to the global browserState
  browserState = {
    ...browserState,
    ...routeProps,
    route: route
  }

  // If the path in the URL doesn't match with any of our routes, we render an Error component (we will have to create it later)
  if (!route)
    return ReactDOM.render(<ErrorPage message={"Not Found"} code={404} />, document.getElementById('root'))

  // If we found a match, we render the Child component, which will render the handlerPath components recursively, remember ? ;)
  ReactDOM.render(<Child {...browserState} />, document.getElementById('root'))
}

window.addEventListener("popstate", () => { onPathChange() });
onPathChange();
