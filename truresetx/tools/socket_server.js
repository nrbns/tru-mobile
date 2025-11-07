// Minimal Socket.IO server for local testing of the Realtime Loader UI
// Usage: node tools/socket_server.js

const io = require('socket.io')(3000, {
  cors: { origin: '*' }
});

io.on('connection', (socket) => {
  console.log('client connected', socket.id);

  let progress = 0.0;
  const interval = setInterval(() => {
    progress += 0.05;
    if (progress > 1) progress = 1;
    socket.emit('progress', progress);
    socket.emit('log', `Progress ${(progress * 100).toFixed(0)}%`);
    if (progress >= 1) {
      clearInterval(interval);
      socket.emit('log', 'Done');
    }
  }, 500);

  socket.on('start', () => {
    socket.emit('log', 'Start received');
  });

  socket.on('pause', () => {
    socket.emit('log', 'Paused (server-side demo)');
  });

  socket.on('resume', () => {
    socket.emit('log', 'Resumed (server-side demo)');
  });

  socket.on('disconnect', () => {
    console.log('client disconnected', socket.id);
  });
});
