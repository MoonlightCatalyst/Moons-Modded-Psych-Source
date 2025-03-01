/*
 * Author:  David Robert Nadeau
 * Site:    http://NadeauSoftware.com/
 * License: Creative Commons Attribution 3.0 Unported License
 *          http://creativecommons.org/licenses/by/3.0/deed.en_US
 */

#if defined(_WIN32)
#include <windows.h>
#include <psapi.h>

#elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
#include <unistd.h>
#include <sys/resource.h>

 #if defined(__APPLE__) && defined(__MACH__)
 #include <mach/mach.h>

 #elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
 #include <fcntl.h>
 #include <procfs.h>

 #elif defined(__linux__) || defined(__linux) || defined(linux) || defined(__gnu_linux__)
 #include <stdio.h>

 #endif

#else
#error 'Cannot define getPeakRSS() or getCurrentRSS() for an unknown OS.'

#endif

/*
 * Returns the peak (maximum so far) resident set size (physical
 * memory use) measured in bytes, or zero if the value cannot be
 * determined on this OS.
 */
size_t getPeakRSS() {
  #if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    PROCESS_MEMORY_COUNTERS info;
    GetProcessMemoryInfo(GetCurrentProcess(), &info, sizeof(info));
    return (size_t) info.PeakWorkingSetSize;

  #elif (defined(_AIX) || defined(__TOS__AIX__)) || (defined(__sun__) || defined(__sun) || defined(sun) && (defined(__SVR4) || defined(__svr4__)))
    /* AIX and Solaris ------------------------------------------ */
    struct psinfo psinfo;
    int fd = open('/proc/self/psinfo', O_RDONLY);
    if (fd != -1) {
      if (read(fd, &psinfo, sizeof(psinfo)) != sizeof(psinfo)) {
        close(fd);
        return (size_t) 0L; /* Can't read? */
      }
      close(fd);
      return (size_t) (psinfo.pr_rssize * 1024L);
    }

  #elif defined(__unix__) || defined(__unix) || defined(unix) || (defined(__APPLE__) && defined(__MACH__))
    /* BSD, Linux, and OSX -------------------------------------- */
    struct rusage rusage;
    getrusage(RUSAGE_SELF, &rusage);
    return (size_t) (rusage.ru_maxrss
    #if defined(__APPLE__) && defined(__MACH__)
    * 1024L
    #endif);
  #endif

  /* Unknown OS ----------------------------------------------- */
  return (size_t) 0L; /* Unsupported. */
}

/*
 * Returns the current resident set size (physical memory use) measured
 * in bytes, or zero if the value cannot be determined on this OS.
 */
size_t getCurrentRSS() {
  #if defined(_WIN32)
    /* Windows -------------------------------------------------- */
    PROCESS_MEMORY_COUNTERS info;
    GetProcessMemoryInfo(GetCurrentProcess(), &info, sizeof(info));
    return (size_t) info.WorkingSetSize;

  #elif defined(__APPLE__) && defined(__MACH__)
    /* OSX ------------------------------------------------------ */
    struct mach_task_basic_info info;
    mach_msg_type_number_t infoCount = MACH_TASK_BASIC_INFO_COUNT;
    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t) &info, &infoCount) == KERN_SUCCESS)
      return (size_t) info.resident_size;

  #elif defined(__linux__) || defined(__linux) || defined(linux) || defined(__gnu_linux__)
    /* Linux ---------------------------------------------------- */
    FILE* fp = fopen('/proc/self/statm', 'r');
    long rss = 0L;
    if (fp != NULL) {
      if (fscanf(fp, '%*s%ld', &rss) != 1) {
        fclose(fp);
        return (size_t) 0L; /* Can't read? */
      }
      fclose(fp);
      return (size_t) rss * (size_t) sysconf(_SC_PAGESIZE);
    }

  #endif

  /* AIX, BSD, Solaris, and Unknown OS ------------------------ */
  return (size_t) 0L; /* Unsupported. */
}