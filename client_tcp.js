const net = require('net');

const client = new net.Socket();
client.connect(8080, '127.0.0.1', () => {
    console.log('Connected');
});

client.on('data', (data) => {
    console.log('Received: ' + data);
    client.destroy(); 
});

client.on('close', () => {
    console.log('Connection closed');
});
