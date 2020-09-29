#ifndef LIME_RESOURCE_HPP
#define LIME_RESOURCE_HPP

#include <atomic>
#include <mutex>
#include <unordered_map>
#include "Pool.hpp"

namespace Lime {
template <typename Key_Type, typename Value_Type>
class ResourceKernel : public Singleton<ResourceKernel<Key_Type, Value_Type>> {
 public:
  ResourceKernel() { lock_.store(true); }
  Value_Type *Build(const Key_Type &key, Value_Type *value = nullptr) {
    if (lock_.load()) {
      std::lock_guard<std::mutex> lock(mutex_);

      Value_Type *t = value ? value : ObjectPool<Value_Type>::New();
      dict_[key] = t;
      return t;
    } else {
      Value_Type *t = value ? value : ObjectPool<Value_Type>::New();
      dict_[key] = t;
      return t;
    }
  }
  void Ref(const Key_Type &from, const Key_Type &to) {
    if (lock_.load()) {
      std::lock_guard<std::mutex> lock(mutex_);

      dict_[to] = dict_[from];
    } else {
      dict_[to] = dict_[from];
    }
  }
  Value_Type *Find(const Key_Type &key) {
    if (lock_.load()) {
      std::lock_guard<std::mutex> lock(mutex_);

      return (Value_Type *)dict_[key];
    } else {
      return (Value_Type *)dict_[key];
    }
  }
  void Destroy(const Key_Type &key) {
    if (lock_.load()) {
      std::lock_guard<std::mutex> lock(mutex_);

      Value_Type *t = dict_[key];
      if (!t) {
        return;
      }
      ObjectPool<Value_Type>::Delete(t);
      for (auto iter : dict_) {
        Value_Type *value = iter->second;
        if (value == t) {
          dict_ = nullptr;
        }
      }
    } else {
      Value_Type *t = dict_[key];
      if (!t) {
        return;
      }
      ObjectPool<Value_Type>::Delete(t);
      for (auto iter : dict_) {
        Value_Type *value = iter->second;
        if (value == t) {
          dict_ = nullptr;
        }
      }
    }
  }
  void Traverse(std::function<void(Key_Type, Value_Type *)> f) {
    if (lock_.load()) {
      std::lock_guard<std::mutex> lock(mutex_);

      for (auto pair : dict_) {
        f(pair.first, pair.second);
      }
    } else {
      for (auto pair : dict_) {
        f(pair.first, pair.second);
      }
    }
  }
  bool GetLock() { return lock_.load(); }
  void SetLock(bool lock) { lock_.store(lock); }

 protected:
  std::unordered_map<Key_Type, Value_Type *> dict_;
  std::mutex mutex_;
  std::atomic_bool lock_;
};

template <typename Key_Type, typename Value_Type>
class Resource {
 public:
  static Value_Type *Build(const Key_Type &key, Value_Type *value = nullptr) {
    return ResourceKernel<Key_Type, Value_Type>::Instance().Build(key, value);
  }
  static void Ref(const Key_Type &from, const Key_Type &to) {
    return ResourceKernel<Key_Type, Value_Type>::Instance().Ref(from, to);
  }
  static Value_Type *Find(const Key_Type &key) {
    return ResourceKernel<Key_Type, Value_Type>::Instance().Find(key);
  }
  static void Destroy(const Key_Type &key) {
    return ResourceKernel<Key_Type, Value_Type>::Instance().Destroy(key);
  }
  static void Traverse(std::function<void(Key_Type, Value_Type *)> f) {
    return ResourceKernel<Key_Type, Value_Type>::Instance().Traverse(f);
  }
  static bool GetLock() {
    return ResourceKernel<Key_Type, Value_Type>::Instance().GetLock();
  }
  static void SetLock(bool lock) {
    return ResourceKernel<Key_Type, Value_Type>::Instance().SetLock(lock);
  }
};
}  // namespace Lime

#endif  // !LIME_RESOURCE_HPP
