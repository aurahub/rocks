#ifndef LIME_SINGLETON_HPP
#define LIME_SINGLETON_HPP

namespace Lime {
/**
 * C++ standard Singleton
 */
template <typename T>
class Singleton {
 public:
  static T &Instance() {
    static T t;
    return t;
  }
};
}  // namespace Lime
#endif  // !LIME_SINGLETON_HPP