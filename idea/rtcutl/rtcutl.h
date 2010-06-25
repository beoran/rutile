/**
* RTCUTL is a Real Timeenamble C utility Library, for now, mainly for 
* use on POSIX-ish platforms like Linux, but some parts are 
* portable already.
*
* Focus is on the ability of all functionality to work well with 
* statical allocation, so use in real-time applications is possible.
*
* The library requires a C compiler that supports the following C99
* features:
* 1) // style short comments
* 2) Presence of <stdint.h>
*   
*/

#ifndef _RTCUTL_H_
#define _RTCUTL_H_

/** Fake booleans in case they're not defined yet. */
#ifndef TRUE
#define TRUE (1)
#endif

#ifndef FALSE
#define FALSE (!TRUE)
#endif

// These headers are portable
#include "queue.h"
#include "array.h"
#include "bybuf.h"
#include "stick.h"


// These headers are POSIX or Linux specific.
#include "fiso.h"
#include "log.h"
#include "realtime.h"










#endif
