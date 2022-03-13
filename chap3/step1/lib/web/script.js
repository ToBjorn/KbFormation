myFunction = () => {
    const domContainer = document.querySelector('#root');
    const element = <div>Hey I was created from react</div>;
    ReactDOM.render(element, domContainer);
}