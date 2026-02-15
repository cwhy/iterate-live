import './style.css';

document.querySelector('#app').innerHTML = `
    <div style="display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; font-family: system-ui;">
        <h1>App Host</h1>
        <p>The app is running in your browser.</p>
        <p style="color: #666; font-size: 14px;">Close this window to quit the app.</p>
    </div>
`;
