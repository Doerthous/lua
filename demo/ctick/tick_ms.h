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

#ifndef TICK_MS_H_
#define TICK_MS_H_

#include <stdint.h>

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32) || defined(__WIN32__)
  #define _TICK_MS_WIN32_
#elif defined(__CYGWIN32__) || defined(__CYGWIN__)
  #define _TICK_MS_CYGWIN32_
#else
  #error "Not support platform!"
#endif

#ifdef _TICK_MS_WIN32_
  #include <windows.h>
#endif

uint32_t tick_ms(void);

#endif /* TICK_MS_H_ */
