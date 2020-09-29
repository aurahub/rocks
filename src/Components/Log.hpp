#ifndef LIME_LOG_HPP
#define LIME_LOG_HPP

#include <log4cplus/configurator.h>
#include <log4cplus/helpers/loglog.h>
#include <log4cplus/helpers/stringhelper.h>
#include <log4cplus/logger.h>
#include <log4cplus/loggingmacros.h>
#include <boost/filesystem.hpp>
#include <boost/lockfree/spsc_queue.hpp>
#include "../Base/Resource.hpp"
#include "../Components/Loop.hpp"

namespace Lime {
struct Log {
  enum Level { FATAL = 1, ERROR = 2, WARN = 3, INFO = 4, DEBUG = 5 };
  Level level;
  std::string content;
};

class LoggerLoop : public Loop {
 public:
  struct Config {
    std::string properties;
    std::string logger;
    const static uint32_t log_queue_size = 1024;
  };
  using Queue = boost::lockfree::spsc_queue<
      Log, boost::lockfree::capacity<Config::log_queue_size>>;
  LoggerLoop() {
    uv_async_init(&loop_, &log_async_, log_async_cb_);
    log_async_.data = this;
  }
  virtual ~LoggerLoop() {
    for (auto iter = log_queue_map_.begin(); iter != log_queue_map_.end();
         ++iter) {
      ObjectPool<Queue>::Delete(iter->second);
    }
  }

  std::string get_config_path() {
    std::string initial_path =
        boost::filesystem::initial_path<boost::filesystem::path>().string();
    std::string env;
    char* ptr_env = std::getenv("PRO_SPEC_T");
    if (ptr_env == nullptr) {
      std::string cmd =
          (boost::format("source /etc/profile;echo $PRO_SPEC_T")).str();
      std::vector<std::string> result_vector;
      FILE* fd = popen(cmd.c_str(), "r");
      if (!fd) {
        return "";
      }
      char line[1024];
      while (fgets(line, sizeof(line), fd) != NULL) {
        if (line[strlen(line) - 1] == '\n') {
          line[strlen(line) - 1] = '\0';
        }
        result_vector.push_back(line);
      }
      pclose(fd);
      if (result_vector.size() > 0) {
        env = result_vector[0];
      }
    } else {
      env = std::string(ptr_env);
    }
    if (env == "") {
      return "";
    }
    std::string config_path =
        (boost::format("%s/../Config_%s/") % initial_path % env).str();
    return config_path;
  }

  virtual bool Init(const Config& conf) {
    conf_ = conf;
    std::string path_file =
        (boost::format("%s/%s") % get_config_path() % conf_.properties).str();
    log4cplus::PropertyConfigurator::doConfigure(LOG4CPLUS_TEXT(path_file));

    return Loop::Init(true, nullptr);
  }

  bool Start() {
    auto logger = log4cplus::Logger::getInstance(LOG4CPLUS_TEXT(conf_.logger));

    logger_ = logger;

    return Loop::Start();
  }

  bool Stop() { return Loop::Stop(); }

  bool Running() { return Loop::Running(); }

  void BuildQueue(const std::thread::id& id) {
    auto iter = log_queue_map_.find(id);
    if (iter == log_queue_map_.end()) {
      log_queue_map_.insert(std::make_pair(id, ObjectPool<Queue>::New()));
    }
  }

  bool Write(const Log& log) {
    if (Resource<std::string, LoggerLoop>::GetLock()) {
      std::lock_guard<std::mutex> lock(mutex_);
      auto iter = log_queue_map_.find(std::this_thread::get_id());
      if (iter == log_queue_map_.end()) {
        log_queue_map_.insert(std::make_pair(std::this_thread::get_id(),
                                             ObjectPool<Queue>::New()));
        iter = log_queue_map_.find(std::this_thread::get_id());
      }
      if (!iter->second->push(log)) {
        return false;
      }
    } else {
      auto iter = log_queue_map_.find(std::this_thread::get_id());
      if (iter == log_queue_map_.end()) {
        return false;
      }
      if (!iter->second->push(log)) {
        return false;
      }
    }
    return (uv_async_send(&log_async_) == 0);
  }

 protected:
  virtual void log_async_callback(uv_async_t* handle) {
    if (Resource<std::string, LoggerLoop>::GetLock()) {
      std::lock_guard<std::mutex> lock(mutex_);
      QueueToLog4Plus();
    } else {
      QueueToLog4Plus();
    }
  }

 protected:
  static void static_log_async_callback(uv_async_t* handle) {
    ((LoggerLoop*)handle->data)->log_async_callback(handle);
  }

 protected:
  void QueueToLog4Plus() {
    Log log;
    for (auto iter = log_queue_map_.begin(); iter != log_queue_map_.end();
         ++iter) {
      while (true) {
        if (!iter->second->pop(log)) {
          break;
        }

        switch (log.level) {
          case Log::FATAL:
            LOG4CPLUS_FATAL(logger_, log.content.c_str());
            break;
          case Log::ERROR:
            LOG4CPLUS_ERROR(logger_, log.content.c_str());
            break;
          case Log::WARN:
            LOG4CPLUS_WARN(logger_, log.content.c_str());
            break;
          case Log::INFO:
            LOG4CPLUS_INFO(logger_, log.content.c_str());
            break;
          case Log::DEBUG:
            LOG4CPLUS_DEBUG(logger_, log.content.c_str());
            break;
        }
      }
    }
  }

 protected:
  Config conf_;
  std::mutex mutex_;

  uv_async_t log_async_;
  uv_async_cb log_async_cb_ = (uv_async_cb)&static_log_async_callback;

  log4cplus::Logger logger_;
  std::map<std::thread::id, Queue*> log_queue_map_;
};

class StreamLog : public std::basic_stringstream<char, std::char_traits<char>> {
 public:
  StreamLog(Log::Level level, LoggerLoop* logger_writer) {
    log_.level = level;
    logger_writer_ = logger_writer;
  }
  virtual ~StreamLog() {
    log_.content = str().c_str();
    if (log_.content[log_.content.size() - 1] == '\n') {
      log_.content[log_.content.size() - 1] = '\0';
    }
    if (logger_writer_) {
      logger_writer_->Write(log_);
    }
    if (log_.level == Log::ERROR || log_.level == Log::FATAL) {
      if (Resource<std::string, LoggerLoop>::GetLock()) {
        log_.content.append("\n");
        std::cout << log_.content;
      } else {
        LoggerLoop* console_writer =
            Resource<std::string, LoggerLoop>::Find("CSL");
        if (console_writer && logger_writer_ != console_writer) {
          console_writer->Write(log_);
        }
      }
    }
  }
  StreamLog& AppendNumber(int64_t number) {
    this->operator<<(number);
    return *this;
  }
  StreamLog& AppendString(const std::string& str) {
    this->operator<<(str.c_str());
    return *this;
  }

 protected:
  LoggerLoop* logger_writer_;
  Log log_;
};

#define LOG(LOGGER, LEVEL)    \
  Lime::StreamLog(Lime::Log::LEVEL, \
            Lime::Resource<std::string, Lime::LoggerLoop>::Find(#LOGGER))
}  // namespace Lime

#endif  // !LIME_LOG_HPP
