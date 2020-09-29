#ifndef LIME_POOL_HPP
#define LIME_POOL_HPP

#include <memory>
#include "Singleton.hpp"

namespace Lime {
/**
 * Revise Malloc() & Free() to customize it.
 * 1. Do memory statistics
 * 2. Use in-code tcmalloc or jemalloc
 */
template <uint32_t size>
class PoolKernel : public Singleton<PoolKernel<size>> {
 public:
  PoolKernel() {}

  virtual ~PoolKernel() {}

  void *Malloc() { return malloc(size); }

  void Free(void *const chunk) { free(chunk); }
};

/**
 * Use this to Malloc/New or Free/Delete Object, it relies on typename.
 */
template <typename T>
class ObjectPool {
 public:
  static void *Malloc() { return PoolKernel<sizeof(T)>::Instance().Malloc(); }

  static void Free(void *const chunk) {
    return PoolKernel<sizeof(T)>::Instance().Free(chunk);
  }

  template <typename... Args_Type>
  static T *New(Args_Type... args) {
    return new (PoolKernel<sizeof(T)>::Instance().Malloc()) T(args...);
  }

  static void Delete(void *const chunk) {
    ((T *)chunk)->~T();
    return PoolKernel<sizeof(T)>::Instance().Free(chunk);
  }
};

/**
 * Use this to New or Free Object, it relies on size.
 */
template <uint32_t size>
class MemoryPool {
 public:
  static void *Malloc() { return PoolKernel<size>::Instance().Malloc(); }

  static void Free(void *const chunk) {
    return PoolKernel<size>::Instance().Free(chunk);
  }
};

/**
 * Use more memory to exchange memory neaty and efficiency.
 */
class ResizedMemoryPool {
 public:
  static void *Malloc(uint32_t size) {
#define CASE_REGION_MALLOC_BEGIN(s) if (size <= ((uint32_t)2 << (s - 1))) {
#define CASE_REGION_MALLOC_END(s)                                   \
  return PoolKernel<((uint32_t)2 << (s - 1))>::Instance().Malloc(); \
  }                                                                 \
  else
#define CASE_MEMORY_MALLOC(s)                                         \
  if (size <= ((uint32_t)2 << (s - 1)))                               \
    return PoolKernel<((uint32_t)2 << (s - 1))>::Instance().Malloc(); \
  else

    CASE_REGION_MALLOC_BEGIN(6)
    CASE_MEMORY_MALLOC(3)      // 1 Byte
    CASE_REGION_MALLOC_END(6)  // 1 Word

    CASE_REGION_MALLOC_BEGIN(12)
    CASE_MEMORY_MALLOC(7)
    CASE_MEMORY_MALLOC(8)
    CASE_MEMORY_MALLOC(9)
    CASE_MEMORY_MALLOC(10)
    CASE_MEMORY_MALLOC(11)
    CASE_REGION_MALLOC_END(12)  // 1 Page

    CASE_REGION_MALLOC_BEGIN(16)
    CASE_MEMORY_MALLOC(13)
    CASE_MEMORY_MALLOC(14)
    CASE_MEMORY_MALLOC(15)
    CASE_REGION_MALLOC_END(16)  // 1 Buff

    CASE_REGION_MALLOC_BEGIN(24)
    CASE_MEMORY_MALLOC(19)
    CASE_MEMORY_MALLOC(20)
    CASE_MEMORY_MALLOC(21)
    CASE_MEMORY_MALLOC(22)
    CASE_MEMORY_MALLOC(23)
    CASE_REGION_MALLOC_END(24)  // 16M

    return malloc(size);
  }

  static void Free(void *const chunk, uint32_t size) {
#define CASE_REGION_FREE_BEGIN(s) if (size <= ((uint32_t)2 << (s - 1))) {
#define CASE_REGION_FREE_END(s)                                 \
  PoolKernel<((uint32_t)2 << (s - 1))>::Instance().Free(chunk); \
  }                                                             \
  else
#define CASE_MEMORY_FREE(s)                                       \
  if (size <= ((uint32_t)2 << (s - 1)))                           \
    PoolKernel<((uint32_t)2 << (s - 1))>::Instance().Free(chunk); \
  else

    CASE_REGION_FREE_BEGIN(6)
    CASE_MEMORY_FREE(3)      // 1 Byte
    CASE_REGION_FREE_END(6)  // 1 Word

    CASE_REGION_FREE_BEGIN(12)
    CASE_MEMORY_FREE(7)
    CASE_MEMORY_FREE(8)
    CASE_MEMORY_FREE(9)
    CASE_MEMORY_FREE(10)
    CASE_MEMORY_FREE(11)
    CASE_REGION_FREE_END(12)  // 1 Page

    CASE_REGION_FREE_BEGIN(16)
    CASE_MEMORY_FREE(13)
    CASE_MEMORY_FREE(14)
    CASE_MEMORY_FREE(15)
    CASE_REGION_FREE_END(16)  // 1 Buff

    CASE_REGION_FREE_BEGIN(24)
    CASE_MEMORY_FREE(19)
    CASE_MEMORY_FREE(20)
    CASE_MEMORY_FREE(21)
    CASE_MEMORY_FREE(22)
    CASE_MEMORY_FREE(23)
    CASE_REGION_FREE_END(24)  // 16M

    free(chunk);
  }
};
}  // namespace Lime
#endif  // !LIME_POOL_HPP
