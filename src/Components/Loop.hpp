#ifndef LIME_LOOP_HPP
#define LIME_LOOP_HPP
#include <uv.h>
#include <atomic>
#include <thread>
#include "../Base/Resource.hpp"

namespace Lime {
class Loop {
 public:
  Loop() {
    uv_loop_init(&loop_);

    uv_async_init(&loop_, &async_, async_cb_);
    async_.data = this;

    uv_prepare_init(&loop_, &prepare_);
    uv_prepare_start(&prepare_, prepare_cb_);
    prepare_.data = this;

    uv_check_init(&loop_, &check_);
    uv_check_start(&check_, check_cb_);
    check_.data = this;

    running_.store(false);
  }

  virtual ~Loop() { uv_loop_close(&loop_); }

  virtual bool Init(bool new_thread = true, void* arg = nullptr) {
    if (running_.load()) {
      return false;
    } else {
      thread_arg_.store(arg);

      thread_create_.store(new_thread);

      if (!new_thread) {
        Resource<std::thread::id, Loop>::Build(std::this_thread::get_id(),
                                               this);
      }

      return true;
    }
  }

  virtual bool Start() {
    if (thread_create_.load()) {
      uv_thread_create(&thread_, thread_cb_, this);
    } else {
      thread_ = uv_thread_self();
      thread_callback(thread_arg_);
    }
    running_.store(true);
    return true;
  }

  virtual bool Stop() {
    uv_async_send(&async_);

    return true;
  }

  virtual bool Running() { return running_.load(); }

  virtual bool Join() {
    if (thread_create_.load()) {
      uv_thread_join(&thread_);
    }
    return true;
  }

 protected:
  virtual void thread_callback(void* arg) {
    Resource<std::thread::id, Loop>::Build(std::this_thread::get_id(), this);
    uv_run(&loop_, UV_RUN_DEFAULT);
  }
  virtual void prepare_callback(uv_prepare_t* handle) {}
  virtual void check_callback(uv_check_t* handle) {}
  virtual void async_callback(uv_async_t* handle) {
    uv_stop(&loop_);
    running_.store(false);
  }
  virtual void timer_callback(uv_timer_t* handle) {}

 protected:
  static void static_thread_callback(void* handle) {
    ((Loop*)handle)->thread_callback(((Loop*)handle)->thread_arg_);
  }
  static void static_check_callback(uv_check_t* handle) {
    ((Loop*)handle->data)->check_callback(handle);
  }
  static void static_prepare_callback(uv_prepare_t* handle) {
    ((Loop*)handle->data)->prepare_callback(handle);
  }
  static void static_async_callback(uv_async_t* handle) {
    ((Loop*)handle->data)->async_callback(handle);
  }
  static void static_timer_callback(uv_timer_t* handle) {
    ((Loop*)handle->data)->timer_callback(handle);
  }

 protected:
  uv_loop_t loop_;
  uv_thread_t thread_;
  uv_async_t async_;
  uv_prepare_t prepare_;
  uv_check_t check_;
  uv_timer_t timer_;
  uv_thread_cb thread_cb_ = (uv_thread_cb)&static_thread_callback;
  uv_async_cb async_cb_ = (uv_async_cb)&static_async_callback;
  uv_prepare_cb prepare_cb_ = (uv_prepare_cb)&static_prepare_callback;
  uv_check_cb check_cb_ = (uv_check_cb)&static_check_callback;
  uv_timer_cb timer_cb_ = (uv_timer_cb)&static_timer_callback;
  std::atomic_bool running_;
  std::atomic_bool thread_create_;
  std::atomic<void*> thread_arg_;
};
}  // namespace Lime
#endif  // !LIME_LOOP_HPP