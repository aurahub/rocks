#ifndef LIME_SERVICE_HPP
#define LIME_SERVICE_HPP
#include <boost/format.hpp>
#include <iostream>
#include <set>
#include <string>

namespace Lime {

/**
 * Service Interface, only to show a service template
 */
class ServiceInterface {
 public:
  ServiceInterface() {}

  virtual ~ServiceInterface() {}

  virtual bool Init() { return true; }

  virtual bool Start() { return true; }

  virtual bool Boot() { return true; }

  virtual bool Stop() { return true; }

  virtual bool Running() { return true; }

  virtual std::string TypeName() { return typeid(ServiceInterface).name(); }
};

/**
 * Service class is used to resolve Service instance depedencies.
 */
template <typename T>
class Service : public ServiceInterface {
 public:
  Service() {}

  virtual ~Service() {}

 public:
  virtual Service<T> *Depends(ServiceInterface *service) final {
    if (service && dependencies_.find(service) == dependencies_.end()) {
      dependencies_.insert(service);
    }
    return this;
  }

  virtual bool Boot() {
    for (auto &dependency : dependencies_) {
      if (dependency && !dependency->Running()) {
        if (dependency->Boot()) {
          std::cout << boost::format("[Service %s][%s] Boot success.\n") %
                           dependency->TypeName() % __FUNCTION__;
        } else {
          std::cout << boost::format("[Service %s][%s] Boot fail.\n") %
                           dependency->TypeName() % __FUNCTION__;
          return false;
        }
      }
    }
    if (!Start()) {
      std::cout << boost::format("[Service %s][%s] Start fail.\n") %
                       TypeName() % __FUNCTION__;
      return false;
    }
    return true;
  }

  virtual const std::set<ServiceInterface *> &Dependencies() final {
    return dependencies_;
  }

 protected:
  std::set<ServiceInterface *> dependencies_;
};
}  // namespace Lime
#endif  // !LIME_SERVICE_HPP