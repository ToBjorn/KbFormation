require('!!file-loader?name=[name].[ext]!./index.html')
/* required library for our React app */
var ReactDOM = require('react-dom')
var React = require("react")
var Qs = require("qs")
var Cookie = require("cookie")
var XMLHttpRequest = require("xhr2")
var createReactClass = require('create-react-class')

/* required css for our application */
require('./tonys.webflow/css/webflow.css');
require('./tonys.webflow/css/tonys.webflow.css');

var HTTP = new (function () {
  this.get = (url) => this.req('GET', url)
  this.delete = (url) => this.req('DELETE', url)
  this.post = (url, data) => this.req('POST', url, data)
  this.put = (url, data) => this.req('PUT', url, data)

  this.req = (method, url, data) => new Promise((resolve, reject) => {
    var req = new XMLHttpRequest()
    req.open(method, url)
    req.responseType = "text"
    req.setRequestHeader("accept", "application/json,*/*;0.8")
    req.setRequestHeader("content-type", "application/json")
    req.onload = () => {
      if (req.status >= 200 && req.status < 300) {
        resolve(req.responseText && JSON.parse(req.responseText))
      } else {
        reject({ http_code: req.status })
      }
    }
    req.onerror = (err) => {
      reject({ http_code: req.status })
    }
    req.send(data && JSON.stringify(data))
  })
})()

var remoteProps = {
  user: (props) => {
    return {
      url: "/api/me",
      prop: "user"
    }
  },
  orders: (props) => {
    var qs = { ...props.qs }
    var query = Qs.stringify(qs)
    return {
      url: "/api/orders" + (query == '' ? '' : '?' + query),
      prop: "orders"
    }
  },
  order: (props) => {
    return {
      url: "/api/order/" + props.order_id,
      prop: "order"
    }
  }
}

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

var Layout = createReactClass({
  getInitialState() {
    return {
      modal: null,
      loader: null,
      page: 1
    }
  },
  loader(promise) {
    this.setState({ loader: 'loading' })
    promise.then(() => {
      this.setState({ loader: null, modal: null })
    })
    return promise;
  },
  modal(spec) {
    this.setState({
      modal: {
        ...spec, callback: (res) => {
          if (spec.callback)
            spec.callback(res)
        }
      }
    })
  },
  render() {
    if (this.state.modal) {
      var modal_component = {
        'delete': (props) => <DeleteModal {...props} />,
      }[this.state.modal && this.state.modal.type];
      modal_component = modal_component && modal_component(this.state.modal)
    }
    if (this.state.loader) {
      var loader_component = <LoadingModal {...props} />
    }
    var props = {
      ...this.props, modal: this.modal, loader: this.loader, page: this.props.qs["page"] || this.state.page
    }
    return <JSXZ in="orders" sel=".layout">
      <Z sel=".modal-wrapper" className={cn(classNameZ, { 'hidden': !modal_component })}>
        {modal_component}
      </Z>
      <Z sel=".loader-wrapper" className={cn(classNameZ, { 'hidden': !loader_component })}>
        {loader_component}
      </Z>
      <Z sel=".layout-container">
        <this.props.Child {...props} />
      </Z>
    </JSXZ>
  }
})

var Header = createReactClass({
  render() {
    return <JSXZ in="orders" sel=".header-container">
      <Z sel=".orders-container">
        <this.props.Child {...this.props} />
      </Z>
    </JSXZ>
  }
})

function arrayRemove(arr, value) {
  return arr.filter(function (ele) {
    return ele[0] != value;
  });
}

var Orders = createReactClass({
  statics: {
    remoteProps: [remoteProps.orders]
  },
  render() {
    let reste = parseInt(this.props.orders.value[0]) % 30
    let nbrPage = parseInt(this.props.orders.value[0]) / 30
    if (reste > 0) nbrPage++;
    nbrPage = parseInt(nbrPage)

    return <JSXZ in="orders" sel=".orders-container">
      <Z sel=".collection-item">
        {this.props.orders.value[1]?.map(order => (<JSXZ in="orders" sel=".table-line">
          <Z sel=".blockcommand">{order[1].remoteid}</Z>
          <Z sel=".blockcustomer">{order[1].custom.customer.full_name}</Z>
          <Z sel=".blockaddress">{order[1].custom.shipping_address.street + " " + order[1].custom.shipping_address.postcode + " " + order[1].custom.shipping_address.city}</Z>
          <Z sel=".blockquantity">{order[1].custom.items.length}</Z>
          <Z sel=".buttondetails" onClick={(e) => GoTo("order", order[0])}><ChildrenZ /></Z>
          <Z sel=".buttonpay">
            <span class="text-span">???</span>
            <br />Status: {order[1].status.state}
            <br />Payment method: {order[1].custom.shipping_method_ui}
          </Z>
          <Z sel=".buttondelete" onClick={() => (
            this.props.modal({
              type: 'delete',
              callback: (value) => {
                if (value) {
                  console.log(order[0])
                  this.props.loader(HTTP.delete("/api/order/" + order[0])).then(() => {
                    this.props.orders.value[1] = arrayRemove(this.props.orders.value[1], order[0]);
                    this.props.orders.value[0] = parseInt(this.props.orders.value[0]) - 1
                    GoTo("orders")
                  });
                }
              }
            }))}><ChildrenZ /></Z>
        </JSXZ>))}
      </Z>
      <Z sel=".page-container">
        <JSXZ in="orders" sel=".pageButtons">
          <Z sel=".pagePrev" onClick={() => {
            if (parseInt(this.props.page) > 1) {
              if (parseInt(this.props.page) == 2) {
                GoTo("orders")
              } else {
                GoTo("orders", "", { page: parseInt(this.props.page) - 1 });
              }
            }
          }}><ChildrenZ /></Z>
          <Z sel=".pageNext" onClick={() => {
            if (parseInt(this.props.page) < nbrPage) {
              GoTo("orders", "", { page: parseInt(this.props.page) + 1 });
            }
          }}><ChildrenZ /></Z>
          <Z sel=".pageCount">{parseInt(this.props.page)}/{nbrPage}</Z>
        </JSXZ>
      </Z>
    </JSXZ>
  }
})

var Order = createReactClass({
  statics: {
    remoteProps: [remoteProps.order]
  },
  render() {
    return <JSXZ in="order-details" sel=".container">
      <Z sel=".w-dyn-items">
        <JSXZ in="order-details" sel=".w-dyn-item">
          <Z sel=".customer">{this.props.order.value.custom.customer.full_name}</Z>
          <Z sel=".address">{this.props.order.value.custom.shipping_address.street + " " + this.props.order.value.custom.shipping_address.postcode + " " + this.props.order.value.custom.shipping_address.city}</Z>
          <Z sel=".commandnumber">{this.props.order.value.remoteid}</Z>
        </JSXZ>
      </Z>
      <Z sel=".order-details-list">
        {this.props.order.value.custom.items.map(item => (<JSXZ in="order-details" sel=".table-line">
          <Z sel=".product-name">{item.product_title}</Z>
          <Z sel=".quantity">{item.quantity_to_fetch}</Z>
          <Z sel=".unitprice">{item.unit_price}</Z>
          <Z sel=".totalprice">{item.quantity_to_fetch * item.unit_price}</Z>
        </JSXZ>))
        }
      </Z>
      <Z sel=".goback" onClick={() => GoTo("orders")}><ChildrenZ /></Z>
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

var DeleteModal = createReactClass({
  render() {
    return <JSXZ in="delete-modal" sel=".modal-wrapper">
      <Z sel=".declinebutton" onClick={() => this.props.callback(false)}><ChildrenZ /></Z>
      <Z sel=".acceptbutton" onClick={() => this.props.callback(true)}><ChildrenZ /></Z>
    </JSXZ>
  }
})

var LoadingModal = createReactClass({
  render() {
    return <JSXZ in="loading-modal" sel=".modal-wrapper">
    </JSXZ>
  }
})

var cn = function () {
  var args = arguments, classes = {}
  for (var i in args) {
    var arg = args[i]
    if (!arg) continue
    if ('string' === typeof arg || 'number' === typeof arg) {
      arg.split(" ").filter((c) => c != "").map((c) => {
        classes[c] = true
      })
    } else if ('object' === typeof arg) {
      for (var key in arg) classes[key] = arg[key]
    }
  }
  return Object.keys(classes).map((k) => classes[k] && k || '').join(' ')
}

var browserState = { Child: Child }

var GoTo = (route, params, query) => {
  var qs = Qs.stringify(query)
  var url = routes[route].path(params) + ((qs == '') ? '' : ('?' + qs))
  history.pushState({}, "", url)
  onPathChange()
}

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

  // If we found a match, we render the Child component, which will render the handlerPath components recursively, remember ? ;)
  addRemoteProps(browserState).then(
    (props) => {
      browserState = props
      // Log our new browserState
      console.log(browserState)
      // Render our components using our remote data
      ReactDOM.render(<Child {...browserState} />, document.getElementById('root'))
    }, (res) => {
      ReactDOM.render(<ErrorPage message={"Shit happened"} code={res.http_code} />, document.getElementById('root'))
    })
}

function addRemoteProps(props) {
  return new Promise((resolve, reject) => {
    var remoteProps = Array.prototype.concat.apply([],
      props.handlerPath
        .map((c) => c.remoteProps) // -> [[remoteProps.orders], null]
        .filter((p) => p) // -> [[remoteProps.orders]]
    )
    remoteProps = remoteProps
      .map((spec_fun) => spec_fun(props)) // [{url: '/api/orders', prop: 'orders'}]
      .filter((specs) => specs) // get rid of undefined from remoteProps that don't match their dependencies
      .filter((specs) => !props[specs.prop] || props[specs.prop].url != specs.url) // get rid of remoteProps already resolved with the url
    if (remoteProps.length == 0)
      return resolve(props)
    const promise_mapper = (spec) => {
      // we want to keep the url in the value resolved by the promise here : spec = {url: '/api/orders', value: ORDERS, prop: 'orders'}
      return HTTP.get(spec.url).then((res) => { spec.value = res; return spec })
    }

    const reducer = (acc, spec) => {
      // spec = url: '/api/orders', value: ORDERS, prop: 'user'}
      acc[spec.prop] = { url: spec.url, value: spec.value }
      return acc
    }

    const promise_array = remoteProps.map(promise_mapper)
    return Promise.all(promise_array)
      .then(xs => xs.reduce(reducer, props), reject)
      .then((p) => {
        // recursively call remote props, because props computed from
        // previous queries can give the missing data/props necessary
        // to define another query
        return addRemoteProps(p).then(resolve, reject)
      }, reject)
  })
}

window.addEventListener("popstate", () => { onPathChange() });
onPathChange();
