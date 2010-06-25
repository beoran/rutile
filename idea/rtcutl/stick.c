#include <stdlib.h>
#include <string.h>
#include "stick.h"


/** Calculates the length of the c string, including the final \0 character */
static size_t cstr_len(char * str) {  
  size_t result = 0;
  // advance string pointer until we see a 0 character 
  for ( ; (*str) != '\0' ; str++) {
    result++; 
  }
  // One more for the \0 character
  result++;
  return result;
}


/** Converts the stick to a \0 terminated C string. */
char * stick_cstr(Stick * stick) {
  return stick->str;
}


/** Initializes an empty stick. Returns NULL on failiure, 
otherwise it returns stick.*/
Stick * stick_init(Stick * stick, char * buffer, size_t cap) {
  if (!stick)   {  return NULL; }
  if (cap < 1)  {  return NULL; }
  if (!buffer)  {  return NULL; }
  stick->str    = buffer;
  stick->cap    = cap;
  stick->len    = 1;
  stick->str[0] = '\0'; 
  // Ensure null termination.
  return stick;
}

/** Returns the capacity of the stick. */
size_t stick_cap(Stick * stick) {
  return stick->cap;
}

/** Returns the length of the stick. This does include the 
final \0 character. */
size_t stick_len(Stick * stick) {
  return stick->len;
}

/** Returns the size of the stick. This does not include the 
final \0 character. */
size_t stick_size(Stick * stick) {
  return stick->len - 1;
}


/** Copies up to len characters from a c string src into the stick from dst to dst, taking  capacity into consideration. If the dst has a too small capacity, the string will be truncated, and NULL will be returned. Otherwise, dst is returned. Len must take the final \0 character 
into consideration.
*/
Stick * stick_strncpy(Stick* dst, char *src, size_t len) {
  int stop, index;
  stop = (dst->cap > len ? len : dst->cap);
  // since len includes the final \0, this should work perfectly.
  for (index = 0; index < stop; index ++) {
    dst->str[index] = src[index];
  }
  // Ensure \0 termination, even if this truncates the string.
  dst->str[index] = '\0';
  // for the case where dst->cap < len, return NULL to indicate this .  
  if (dst->cap < len) { 
    return NULL;
  }
  return dst;
}

/** Copies a c string src into the stick from dst to dst, taking  capacity into consideration. If the dst has a too small capacity, the string will be truncated, and NULL will be returned. Otherwise, dst is returned.
*/
Stick * stick_strcpy(Stick* dst, char *src) {
  int stop, index, len;
  len  = cstr_len(src);
  return stick_strncpy(dst, src, len);
}


/** Copies the stick from src to dst, taking length and capacity 
into consideration. If the dst has a too small capacity, the string 
will be truncated, and NULL will be returned. Otherwise, dst is returned.
*/
Stick * stick_copy(Stick* dst, Stick * src) {
  return stick_xcopy(src, dst, stick_len(src), 0, 0);
}



/* 
Concatenates a stick src to the given stick dst.
This modifies dst. 
Returns NULL if there was not enough capacity and trunbcation took place.
Otherwise returns dst if all went well;
*/
Stick * stick_cat(Stick * dst, Stick * src) {  
  return stick_xcopy(src, dst, stick_len(src), 0, stick_len(dst));
} 

/**
* Truncates the stick to the given lentgth, which must be smaller than 
* the current length, but not 0, as the final \0 character must be kept 
* in mind. 
* Returns Null on argument errors, stick on success. 
*/
Stick * stick_trunc(Stick * stick, size_t len) {
  if (len > stick->len)  { return NULL; }
  if (len < 0)           { return NULL; }
  stick->len = len; // set length
  stick->str[stick->len] = '\0'; // zero terminate 
  return stick;
}


/**
* Takes len characters from the string src, and copies them into 
* the string dst, starting at positions sstart in src and dstart in 
* dst.
* Returns NULL if dst has not enough capacity for the operation,
* or if any of the parameters was out of range, leaving src and 
* dst unchanged. 
*/
Stick * stick_xcopy(Stick * dst, Stick * src, 
                    size_t len, size_t sstart, size_t dstart) {
  int index, stop;
  if (dstart >= dst->cap) { return NULL; }
  if (sstart >= src->cap) { return NULL; }
  if ((dstart + len) > dst->cap) { return NULL; }
  if ((sstart + len) > src->cap) { return NULL; }
  for (index = 0; index < len; index ++) {
    dst->str[index + dstart] = src->str[index + sstart];
  }
  dst->str[index + dstart] = '\0';
  // Ensure null termination.
  return dst;
}  


// Gets the first len characters from the left side of 
// the stick src and copies them to dst, which will be 
// truncated to length 1 first.  
Stick * stick_left(Stick * dst, Stick * src, size_t len) {
  stick_trunc(dst, 1);
  return stick_xcopy(dst, src, len, 0, 0);
}


Twig * twig_init(Twig * twig, char * str) {
  int size;
  stick_init(&twig->stick, twig->buffer, TWIG_CAPACITY); 
  stick_strcpy(&twig->stick, str);
}









