var http = require("http");
var server = http.createServer(function(request, response) {
  response.writeHead(200, { "Content-Type": "text/plain" });
  response.end("Hello World\n");
});

function run() {
  server.listen(10080, function(err) {
    if (err) {
      return console.log("something bad happened", err);
    }
    console.log("=>http server is listening on ", 10080);
  });
}

module.exports = {
  run: run
};
