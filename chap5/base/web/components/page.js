import React, { useEffect, useState } from 'react';
import { Grid } from './grid';

export function Page() {
    const [orders, setOrders] = useState(null);

    useEffect(() => { getOrders() }, []);

    const getOrders = async function () {
        const response = await fetch('api/orders');
        const data = await response.json();
        setOrders(data);
    }

    return (
        <div>
            {orders ? (
                <Grid 
                orders={orders}
                />
            ) : (<div>Loading...</div>)}
        </div>
    );
}