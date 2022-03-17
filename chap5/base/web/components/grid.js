import React, { useState } from 'react';
import { OrderDetails } from './order-details';
import { Orders } from './orders';

export function Grid(props) {
    const { orders } = props;
    const [orderToDetail, setOrderToDetail] = useState(null);

    return (
        <div>
            { orderToDetail ? (
                    <OrderDetails 
                    details={orderToDetail}
                    setDetails={setOrderToDetail}
                    />
                ) : (
                    <Orders 
                    orders={orders}
                    setDetails={setOrderToDetail}
                    />
                )}
        </div>
    );
}