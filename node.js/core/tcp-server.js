const {Server} = require('net');
const {relative} = require('path');
const {format} = require('util');

module.relfilename = relative(process.cwd(), module.filename);

var server = new Server();

server.maxConnections = 1024;

server.on('listening', function() {
  module.address = format(
      '(%s)%s:%s', server.address().family, server.address().address,
      server.address().port);
  console.log(
      '[%s][%s] Tcp server is listening, mode: (maxConnections %s)',
      module.relfilename, module.address, server.maxConnections);
});

server.getConnections(function(error, count) {
  if (error) {
    console.log(
        '[%s][%s] Tcp server gets error on %s', module.relfilename,
        module.address, error);
  } else if (!!module.address) {
    console.log(
        '[%s][%s] Tcp server works on %s connections', module.relfilename,
        module.address, count);
  }
});

server.on('connection', function(socket) {
  socket.remote = format(
      '(%s)%s:%s', socket.remoteFamily, socket.remoteAddress,
      socket.remotePort);

  socket.setEncoding('utf8');
  socket.setKeepAlive(true);
  socket.setNoDelay(true);
  socket.setTimeout(3000);

  console.log(
      '[%s][%s] Socket connected, mode: (encoding utf8, keepAlive on, noDelay on, timeout 3000 ms, bufferSize %s bytes)',
      module.relfilename, socket.remote, socket.bufferSize);

  socket.on('timeout', function() {
    console.log(
        '[%s][%s] Socket occurred a timeout', module.relfilename,
        socket.remote);
    socket.end();
  });

  socket.on('data', function(data) {
    console.log('%s %s', typeof (data), data)
    console.log(
        '[%s][%s] Socket received %s bytes: (%s)', module.relfilename,
        socket.remote, data.length, data);
    // streampack.gets
    socket.write('111' + data);
  });

  socket.on('error', function(error) {
    console.log(
        '[%s][%s] Socket occurred an error for (%s)', module.relfilename,
        socket.remote, error.message);
    socket.end();
  });

  socket.on('close', function(has_error) {
    if (has_error) {
      console.log(
          '[%s][%s] Socket closed for (transmission error) after it read %s bytes and write %s bytes',
          module.relfilename, socket.remote, socket.bytesRead,
          socket.bytesWrite);
    } else {
      console.log(
          '[%s][%s] Socket closed for (no error) after it read %s bytes and write %s bytes',
          module.relfilename, socket.remote, socket.bytesRead,
          socket.bytesWrite);
    }
  });

  socket.on('end', function() {
    console.log('[%s][%s] Socket ended.', module.relfilename, socket.remote);
  });
});

server.on('error', function(error) {
  console.log(
      '[%s][%s] Tcp server occurred an error for (%s).', module.relfilename,
      module.address, error);
  server.close();
});

server.on('close', function() {
  console.log(
      '[%s][%s] Tcp server closed.', module.relfilename, module.address);
});

module.exports = {
  run: function(port) {
    server.listen(port);
  }
};
