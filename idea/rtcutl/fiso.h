/*
* A unified file and socket handler struct and related functions. 
* For ease of use. 
*/

#ifndef _FISO_H_
#define _FISO_H_
 
#define FISO_ERROR_NONE  0
#define FISO_HANDLE_NONE -1

#include <sys/types.h>
#include <sys/socket.h>

#define _GNU_SOURCE
#include <poll.h>


/** Define Pseudo-booleans if not already available. */
#ifndef FALSE
#define FALSE 0
#endif

#ifndef TRUE
#define TRUE (!(FALSE))
#endif

 
struct Fiso_;
typedef struct Fiso_ Fiso;

struct Fiso_ {
  // Handle is the socket or file handle we are using.
  int     handle; 
  // Error is the last error encountered, if any. 
  int     error;
  // Name is the name of the socket or file.
  char   *name;
  // Length of name as reported by strlen(hance missing last 0)
  size_t  name_len; 
  // Error string 
  char  * errstr;
  // To enable polling the file or socket.     
  struct pollfd poll;
  // Timeout in ns for reading
  long read_wait_ns;
  // Timeout in s for reading
  long read_wait_s;
  // Timeout in ns for writing
  long write_wait_ns; 
  // Timeout in s for writing
  long write_wait_s;
  // Ready fior reading when using polling?
  int read_ready; 
  // Ready for writing when using polling?
  int write_ready;
  
};
 

// Initialises the file of socket handler.
Fiso * fiso_init(Fiso * f, char * name);


// Sets the handle of the fiso. ensyres that the poss is also updated.
Fiso * fiso_handle(Fiso *f, int handle);

// Sets the timeouts to use for reading the FISO when using polling
Fiso * fiso_read_wait(Fiso *f, long waits, long waitns);

// Sets the timeouts to use for writing to the FISO when using polling
Fiso * fiso_write_wait(Fiso *f, long waits, long waitns);

// Returns true if an error occiurred before, false if not.
int    fiso_failed(Fiso * f);
 
// Tries a function that results in error,
// returns true if the call failed, false if not.
int    fiso_try(Fiso * f, int error);

// Tries to get a socket for this fiso using the given 
// domain, type and protocol parameters
// returns self, modified 
Fiso * fiso_socket(Fiso *f, int domain, int type, int protocol);

// Tries to bind the fiso to the given address
Fiso * fiso_bind(Fiso *f, const struct sockaddr *my_addr, socklen_t addrlen);

enum { 
  FISO_POLL_READ   = 1,
  FISO_POLL_WRITE  = 2
};


#endif

