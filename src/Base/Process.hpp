#ifndef LIME_PROCESS_HPP
#define LIME_PROCESS_HPP

#include <sys/param.h>
#include <sys/stat.h>
#include <unistd.h>
#include "Singleton.hpp"
namespace Lime {
/**
 * To run in background.
 */
class Process : public Singleton<Process> {
 public:
  static void Daemonize() {
    int pid;
    int i;
    if ((pid = fork()) > 0)
      exit(0);
    else if (pid < 0)
      exit(1);

    setsid();

    if ((pid = fork()) > 0)
      exit(0);
    else if (pid < 0)
      exit(1);
    for (i = 0; i < NOFILE; i++) close(i);
    umask(0);
  }
};
}  // namespace Lime

#endif  // !LIME_PROCESS_HPP