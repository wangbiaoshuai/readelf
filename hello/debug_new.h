/*
 * debug_new.h  1.7 2003/07/03
 *
 * Header file for checking leakage by operator new
 *
 * By Wu Yongwei
 *
 */

#ifndef _DEBUG_NEW_H
#define _DEBUG_NEW_H

#ifdef __cplusplus

#include <new>
/* Prototypes */
bool check_leaks();
void* operator new(size_t size, const char* file,const char* function,  int line);
void* operator new[](size_t size, const char* file, const char* function, int line);

void* operator new(std::size_t size, void* ptr, const char* /*file*/, const char* /*function*/, int /*line*/)
{
    return ::operator new(size, ptr);
}

void operator delete(void* pMemory, void* ptr, const char* /*file*/, const char* /*function*/, int /*line*/) throw()
{
    ::operator delete(pMemory, ptr);
}
#ifndef NO_PLACEMENT_DELETE
void operator delete(void* pointer, const char* file, const char* function, int line);
void operator delete[](void* pointer, const char* file, const char* function, int line);
#endif // NO_PLACEMENT_DELETE
void operator delete[](void*);	// MSVC 6 requires this declaration

/* Macros */
#ifndef DEBUG_NEW_NO_NEW_REDEFINITION
#define new new(__FILE__, __FUNCTION__, __LINE__)
#define new(ptr) DEBUG_NEW(ptr)
#define DEBUG_NEW(ptr) new(ptr, __FILE__, __FUNCTION__, __LINE__)
//#define DEBUG_NEW(...) new(__VA_ARGS__, __FILE__,__FUNCTION__, __LINE__)
//#define debug_new new
#else
#define debug_new new(__FILE__, __FUNCTION__, __LINE__)
#endif // DEBUG_NEW_NO_NEW_REDEFINITION

#include <stdlib.h>

extern "C" void* zoa_malloc(size_t size, const char* file,const char* function, int line);
extern "C" void zoa_free(void* pointer);

#define malloc(s) zoa_malloc(s, __FILE__, __FUNCTION__, __LINE__)
#define free(p) zoa_free(p)

/* Control flags */
extern bool new_verbose_flag;	// default to false: no verbose information
extern bool new_autocheck_flag;	// default to true: call check_leaks() on exit

#else
#include <stdlib.h>

void* zoa_malloc(size_t size, const char* file, const char* function, int line);
void zoa_free(void* pointer);

#define malloc(s) zoa_malloc(s, __FILE__,  __FUNCTION__,__LINE__)
#define free(p) zoa_free(p)

#endif // __cplusplus

#endif // _DEBUG_NEW_H
