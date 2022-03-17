import React from 'react';

export function Orders(props) {
    const { orders, setDetails } = props;

    const handleClick = (event, order) => {
        setDetails(order);
    }

    return (
        <JSXZ in="orders" sel=".container" >
            <Z sel=".collection-item">
                {orders.map(order => (<JSXZ in="orders" sel=".table-line">
                    <Z sel=".blockcommand">{order[1].remoteid}</Z>
                    <Z sel=".blockcustomer">{order[1].custom.customer.full_name}</Z>
                    <Z sel=".blockaddress">{order[1].custom.shipping_address.street + " " + order[1].custom.shipping_address.postcode + " " + order[1].custom.shipping_address.city}</Z>
                    <Z sel=".blockquantity">{order[1].custom.items.length}</Z>
                    <Z sel=".buttondetails" onClick={(e) => handleClick(e, order[1])}><ChildrenZ/></Z>
                    <Z sel=".buttonpay">
                        <span class="text-span"></span>
                        <br/>Status: {order[1].status.state}
                        <br/>Payment method: {order[1].custom.shipping_method_ui}
                    </Z>
                </JSXZ>))}
            </Z>
        </JSXZ>
    );
}