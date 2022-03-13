function myFunction() {
    const domContainer = document.querySelector('#root');
    const property = React.createElement('div', {}, 'Hey I was created from react');
    ReactDOM.render(property, domContainer);
}