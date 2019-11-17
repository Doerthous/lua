/*******************************************************************************

  Copyright © 2019

  Permission is hereby granted, free of charge, to any person obtaining a copy 
  of this software and associated documentation files (the “Software”), to deal 
  in the Software without restriction, including without limitation the rights 
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell 
  copies of the Software, and to permit persons to whom the Software is 
  furnished to do so, subject to the following conditions:

  1. Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
  2. Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

  The above copyright notice and this permission notice shall be included in 
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
  SOFTWARE.

  Author: doerthous <doerthous@gmail.com>

*******************************************************************************/

#include "tick_ms.h"


#ifndef _TICK_MS_WIN32_
  #ifndef USE_FTIME
    #define USE_TIME
    #include <time.h>
  #else
    #include <sys/timeb.h>
  #endif
#endif



uint32_t tick_ms(void)
{
  #ifdef USE_FTIME
    struct timeb t;

    ftime(&t);  

    return t.time*1000 + t.millitm;  
  #elif defined(USE_TIME)
    clock_t t;

    t = clock();

    return t / CLOCKS_PER_SEC * 1000;
  #elif defined(_TICK_MS_WIN32_)
    LARGE_INTEGER time;
    LARGE_INTEGER freq;

    QueryPerformanceFrequency(&freq); 
    QueryPerformanceCounter(&time);

    time.QuadPart *= 1000;
    time.QuadPart /= freq.QuadPart;

    return (uint32_t)time.QuadPart;
  #endif
}
