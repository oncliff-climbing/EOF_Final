import React, { useState, useEffect } from 'react';

function Logmsg() {
  const [socket, setSocket] = useState(null);
  const [message, setMessage] = useState('');
  const [receivedMessage, setReceivedMessage] = useState('');

  useEffect(() => {
    const ws = new WebSocket('http://www.cloudeof.com:8080/ws'); // 해당 URL은 FastAPI 서버의 웹 소켓 엔드포인트로 변경해야 합니다.
    
    ws.onopen = () => {
      console.log('Connected to server');
    };

    ws.onmessage = (event) => {
      const message = event.data;
      console.log('Received message from server:', message);
      setReceivedMessage(message);
    };

    ws.onclose = () => {
      console.log('Disconnected from server');
    };

    setSocket(ws);

    return () => {
      ws.close();
    };
  }, []);

  const sendMessage = () => {
    if (socket && socket.readyState === WebSocket.OPEN) {
      socket.send(message);
      setMessage('');
    }
  };

  return (
    <div>
      <h1>WebSocket Test</h1>
      <div>
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          placeholder="Enter message..."
        />
        <button onClick={sendMessage}>Send</button>
      </div>
      <div>
        <h2>Received Message: {receivedMessage}</h2>
      </div>
    </div>
  );
}

export default Logmsg;
