/**
* Sticks are static strings, a bit like pascal style strings.
* Unlike pascal style strings they can have different 
* lengths, but the length is determined at compile time.
* A Twig is a conccrete Stick that uses a buffer of 256 characters. 
*/

#ifndef _RTCUTL_STICK_H_
#define _RTCUTL_STICK_H_

struct Stick_;
typedef struct Stick_ Stick;

#include <stdlib.h>

struct Stick_ {
  char *  str;
  /** The static buffer pointed to. */
  size_t  len;
  /** The real length of the string. */
  size_t  cap;
  /** The capacity of the buffer. */
};

struct Twig_;
typedef struct Twig_ Twig;

#ifndef TWIG_CAPACITY
#define TWIG_CAPACITY 256
#endif

struct Twig_ {
  Stick stick;
  char  buffer[TWIG_CAPACITY];
};

/** Converts the stick to a \0 terminated C string. */
char * stick_cstr(Stick * stick); 

/** Initializes an empty stick. Returns NULL on failure, 
otherwise it returns stick.*/
Stick * stick_init(Stick * stick, char * buffer, size_t cap); 

/** Returns the capacity of the stick. */
size_t stick_cap(Stick * stick); 

/** Returns the length of the stick. This does include the 
final \0 character. */
size_t stick_len(Stick * stick); 

/** Returns the size of the stick. This does not include the 
final \0 character. */
size_t stick_size(Stick * stick); 

/** Copies up to len characters from a c string src into the stick from dst to dst, taking  capacity into consideration. If the dst has a too small capacity, the string will be truncated, and NULL will be returned. Otherwise, dst is returned. Len must take the final \0 character 
into consideration.
*/
Stick * stick_strncpy(Stick* dst, char *src, size_t len); 

/** Copies a c string src into the stick from dst to dst, taking  capacity into consideration. If the dst has a too small capacity, the string will be truncated, and NULL will be returned. Otherwise, dst is returned.
*/
Stick * stick_strcpy(Stick* dst, char *src);


/** Copies the stick from src to dst, taking length and capacity 
into consideration. If the dst has a too small capacity, the string 
will be truncated, and NULL will be returned. Otherwise, dst is returned.
*/
Stick * stick_copy(Stick* dst, Stick * src); 


/** 
Concatenates a stick src to the given stick dst.
This modifies dst. 
Returns NULL if there was not enough capacity and trunbcation took place.
Otherwise returns dst if all went well;
*/
Stick * stick_cat(Stick * dst, Stick * src); 

/**
* Truncates the stick to the given lentgth, which must be smaller than 
* the current length, but not 0, as the final \0 character must be kept 
* in mind. 
* Returns Null on argument errors, stick on success. 
*/
Stick * stick_trunc(Stick * stick, size_t len); 


/**
* Takes len characters from the string src, and copies them into 
* the string dst, starting at positions sstart in src and dstart in 
* dst.
* Returns NULL if dst has not enough capacity for the operation,
* or if any of the parameters was out of range, leaving src and 
* dst unchanged. 
*/
Stick * stick_xcopy(Stick * dst, Stick * src, 
                    size_t len, size_t sstart, size_t dstart); 


// Gets the first len characters from the left side of 
// the stick src and copies them to dst, which will be 
// truncated to length 1 first.  
Stick * stick_left(Stick * dst, Stick * src, size_t len);



#endif
