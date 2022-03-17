import React from 'react';

export function OrderDetails(props) {
    const { details, setDetails } = props;

    const handleClick = (event) => {
        setDetails(null);
    }

    return (
        <JSXZ in="order-details" sel=".container">
            <Z sel=".w-dyn-items">
                <JSXZ in="order-details" sel=".w-dyn-item">
                    <Z sel=".customer">{details.custom.customer.full_name}</Z>
                    <Z sel=".address">{details.custom.shipping_address.street + " " + details.custom.shipping_address.postcode + " " + details.custom.shipping_address.city}</Z>
                    <Z sel=".commandnumber">{details.remoteid}</Z>
                </JSXZ>
            </Z>
             <Z sel=".order-details-list">
                {details.custom.items.map(item => (<JSXZ in="order-details" sel=".table-line">
                    <Z sel=".product-name">{item.product_title}</Z>
                    <Z sel=".quantity">{item.quantity_to_fetch}</Z>
                    <Z sel=".unitprice">{item.unit_price}</Z>
                    <Z sel=".totalprice">{item.quantity_to_fetch * item.unit_price}</Z>
                </JSXZ>))
                }
            </Z>
            <Z sel=".goback" onClick={(e) => handleClick(e)}><ChildrenZ/></Z>
        </JSXZ>
    );
}