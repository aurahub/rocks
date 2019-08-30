var tcp_server = require('./core/tcp-server');
var http_server = require('./core/http-server');

tcp_server.run(10001, '0.0.0.0.0');
http_server.run();
