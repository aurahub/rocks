#ifndef LIME_TCP_HPP
#define LIME_TCP_HPP

#include <atomic>
#include <boost/asio/basic_streambuf.hpp>
#include <queue>
#include <thread>
#include "../Base/Pool.hpp"
#include "../Components/Log.hpp"
#include "../Components/Loop.hpp"

namespace Lime {
class TcpConnection {
 public:
  struct Config {
    Config(){};
    const static uint32_t uv_buff_size = 64 * 1024;
  };
  TcpConnection() {
    tcp_.data = this;
    running_.store(false);
  }
  virtual ~TcpConnection() {}

  bool Init(std::function<void()> recycle_func) {
    running_.store(false);
    recycle_func_ = recycle_func;

    uv_tcp_nodelay(&tcp_, 1);

    sockaddr_in sock_addr;
    int32_t len = sizeof(sock_addr);
    if (uv_tcp_getpeername(&tcp_, (sockaddr *)&sock_addr, &len) == 0) {
      char addr[16];
      uv_inet_ntop(AF_INET, &sock_addr.sin_addr, addr, sizeof(addr));
      ip_ = addr;
      port_ = ntohs(sock_addr.sin_port);
      LOG(SYS, INFO) << boost::format(
                            "[Connection %x][%s] TcpConnection from %s:%d.\n") %
                            this % __FUNCTION__ % ip_ % port_;
    }

    return true;
  }

  bool Start() {
    running_.store(true);
    LOG(SYS, INFO) << boost::format("[Connection %x][%s] start running.\n") %
                          this % __FUNCTION__;

    return true;
  }

  bool Stop() {
    running_.store(false);
    LOG(SYS, INFO) << boost::format("[Connection %x][%s] stop running.\n") %
                          this % __FUNCTION__;

    return true;
  }

  bool Running() { return running_.load(); }

 public:
  bool ConsumerWrite(uv_buf_t buf) {
    write_queue_.push(buf);
    uv_write_t *write = ObjectPool<uv_write_t>::New();
    write->data = this;
    uv_write(write, (uv_stream_t *)&tcp_, &buf, 1, write_cb_);

    return true;
  }

  bool ConsumerStart() {
    uv_read_start((uv_stream_t *)&tcp_, alloc_cb_, read_cb_);
    LOG(SYS, INFO) << boost::format(
                          "[Connection %x][%s] consumer start running.\n") %
                          this % __FUNCTION__;
  }

  bool ConsumerStop() {
    if (!uv_is_closing((uv_handle_t *)&tcp_)) {
      uv_close((uv_handle_t *)&tcp_, nullptr);
    }

    recycle_func_();
    LOG(SYS, INFO) << boost::format(
                          "[Connection %x][%s] consumer stop running.\n") %
                          this % __FUNCTION__;
  }

  uv_tcp_t &Tcp() { return tcp_; }

  std::string Ip() { return ip_; }

  uint16_t Port() { return port_; }

 protected:
  virtual void alloc_callback(uv_handle_t *handle, size_t suggested_size,
                              uv_buf_t *buf) {
    *buf = uv_buf_init((char *)MemoryPool<Config::uv_buff_size>::Malloc(),
                       Config::uv_buff_size);
  }

  virtual void read_callback(uv_stream_t *handle, ssize_t nread,
                             const uv_buf_t *buf) {
    if (nread > 0) {
      const_cast<uv_buf_t *>(buf)->len = nread;
      read_stream_buff_.sputn(buf->base, buf->len);
      MemoryPool<Config::uv_buff_size>::Free(buf->base);
      LOG(SYS, DEBUG)
          << boost::format(
                 "[Connection %x][%s] read length:%u, packet length:%u.\n") %
                 this % __FUNCTION__ % nread % *(int16_t *)buf->base;
    } else if (nread == 0) {
      LOG(SYS, DEBUG)
          << boost::format(
                 "[Connection %x][%s] read length:%u, packet length:%u.\n") %
                 this % __FUNCTION__ % nread % nread;
    } else {
      if (nread == -4095 || nread == -104) {
        MemoryPool<Config::uv_buff_size>::Free(buf->base);
        Stop();
        LOG(SYS, INFO)
            << boost::format(
                   "[Connection %x][%s] client disconnected with code:%u.\n") %
                   this % __FUNCTION__ % nread;
      } else {
        MemoryPool<Config::uv_buff_size>::Free(buf->base);
        Stop();
        LOG(SYS, ERROR) << boost::format(
                               "[Connection %x][%s] error %d %s %s.\n") %
                               this % __FUNCTION__ % (int32_t)nread %
                               uv_strerror(-1 * nread) %
                               uv_err_name(-1 * nread);
      }
    }
  }

  virtual void write_callback(uv_write_t *handle, int status) {
    uv_buf_t buf;
    if (!write_queue_.empty()) {
      buf = write_queue_.front();
      write_queue_.pop();
      MemoryPool<Config::uv_buff_size>::Free(buf.base);
    }

    ObjectPool<uv_write_t>::Delete(handle);
    LOG(SYS, DEBUG) << boost::format("[Connection %x][%s] write size %llu.\n") %
                           this % __FUNCTION__ % buf.len;

    if (status == -1) {
      LOG(SYS, ERROR) << boost::format(
                             "[Connection %x][%s] write fail, close!\n") %
                             this % __FUNCTION__;
      Stop();
    }
  }

 protected:
  static void static_alloc_callback(uv_handle_t *handle, size_t suggested_size,
                                    uv_buf_t *buf) {
    ((TcpConnection *)handle->data)
        ->alloc_callback(handle, suggested_size, buf);
  }

  static void static_read_callback(uv_stream_t *handle, ssize_t nread,
                                   const uv_buf_t *buf) {
    ((TcpConnection *)handle->data)->read_callback(handle, nread, buf);
  }

  static void static_write_callback(uv_write_t *handle, int status) {
    ((TcpConnection *)handle->data)->write_callback(handle, status);
  }

 protected:
  uv_tcp_t tcp_;
  uv_alloc_cb alloc_cb_ = (uv_alloc_cb)&static_alloc_callback;
  uv_read_cb read_cb_ = (uv_read_cb)&static_read_callback;
  uv_write_cb write_cb_ = (uv_write_cb)&static_write_callback;
  std::function<void()> recycle_func_;

  boost::asio::basic_streambuf<> read_stream_buff_;
  std::queue<uv_buf_t> write_queue_;

  std::atomic_bool running_;
  std::string ip_;
  uint16_t port_;
};

class TcpServer : public Loop {
 public:
  struct Config {
    Config(){};
    std::string host;
    uint16_t port;
    const static int32_t backlog = 128;
    const static uint32_t max_connection_count = 1000;
  };

  TcpServer() {
    uv_tcp_init(&loop_, &tcp_server_);
    uv_tcp_nodelay(&tcp_server_, 1);
    tcp_server_.data = this;
  }
  virtual ~TcpServer() {}

  virtual bool Init(const Config &conf = Config()) {
    conf_ = conf;

    uv_ip4_addr(conf_.host.c_str(), conf_.port, &addr_);

    return Loop::Init();
  }

  virtual Config &Conf() { return conf_; }

  virtual bool Start() {
    uv_tcp_bind(&tcp_server_, (const struct sockaddr *)&addr_, 0);
    int32_t uv_ret =
        uv_listen((uv_stream_t *)&tcp_server_, Config::backlog, conn_cb_);
    bool ret = (uv_ret == 0);
    if (!ret) {
      LOG(SYS, ERROR) << boost::format("[TcpServer %x][%s] error %s %s.\n") %
                             this % __FUNCTION__ % uv_strerror(uv_ret) %
                             uv_err_name(uv_ret);
      return ret;
    }

    return Loop::Start();
  }

  virtual bool Stop() { return Loop::Stop(); }

  virtual bool Running() { return Loop::Running(); }

 protected:
  virtual void connection_callback(uv_stream_t *tcp_server, int status) {
    if (status == -1) {
      LOG(SYS, ERROR) << boost::format(
                             "[TcpServer %x][%s] on_new_connection "
                             "TcpConnection,status %d.\n") %
                             this % __FUNCTION__ % status;
      return;
    }

    TcpConnection *tcp_connection = ObjectPool<TcpConnection>::New();
    uv_tcp_t *tcp_client = &tcp_connection->Tcp();
    uv_tcp_init(&loop_, tcp_client);

    if (uv_accept((uv_stream_t *)tcp_server, (uv_stream_t *)tcp_client) == 0) {
      tcp_connection->Init(
          [=]() { ObjectPool<TcpConnection>::Delete(tcp_connection); });
      tcp_connection->Start();
    } else {
      uv_close((uv_handle_t *)tcp_client, nullptr);
      ObjectPool<TcpConnection>::Delete(tcp_connection);
    }
  }

 protected:
  static void static_connection_callback(uv_stream_t *tcp_server, int status) {
    ((TcpServer *)tcp_server->data)->connection_callback(tcp_server, status);
  }

 protected:
  Config conf_;
  uv_tcp_t tcp_server_;
  sockaddr_in addr_;
  uv_connection_cb conn_cb_ = (uv_connection_cb)&static_connection_callback;
};
}  // namespace Lime

#endif  // !LIME_TCP_HPP
