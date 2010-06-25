#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <unistd.h>
#include <sys/file.h>

#include "fiso.h"


// Casts a void pointer to a Fiso struct pointer
Fiso * fiso_cast(void * ptr) {
  return (Fiso *) ptr;
}


// Initialises the file of socket handler
Fiso * fiso_init(Fiso * f, char * name) {
  // if(!f) { return NULL; }
  f->handle     = FISO_HANDLE_NONE;
  f->error      = FISO_ERROR_NONE;
  f->name       = name;
  f->name_len   = strlen(name);
  f->poll.fd    = f->handle;    
  f->read_ready = FALSE;
  f->write_ready= FALSE;
  return f;
}

// Sets the handle of the fiso. ensyres that the poss is also updated.
Fiso * fiso_handle(Fiso *f, int handle) {
  f->handle   =    handle;
  f->poll.fd  = f->handle;
} 

// Sets the timeouts to use for reading the FISO when using polling
Fiso * fiso_read_wait(Fiso *f, long waits, long waitns) {
  f->read_wait_ns = waitns;
  f->read_wait_s  = waits;
} 

// Sets the timeouts to use for writing to the FISO when using polling
Fiso * fiso_write_wait(Fiso *f, long waits, long waitns) {
  f->write_wait_ns = waitns;
  f->write_wait_s  = waits;
} 


// Returns true if an error occurred before, false if not.
int fiso_failed(Fiso * f) {
  // if(!f) { return 1; }
  return f->error != FISO_ERROR_NONE;
}
 
// sets the for this fiso error from errno, after a function call with result
// result (that is negative of failiure). Also calls perror. 
Fiso * fiso_error_errno(Fiso * f, int result) {
  if (result == -1) {
    f->error = errno;
    perror("Fiso operation failed: "); 
    /* log_error(strerror(f->error)); */
  }
  return f;  
}  
 
// Tries a function that results a negative value in case of error, 
// and that stores the error in erno. Fetches errno if that is the case
// returns true if the call failed, false if not.
int fiso_try(Fiso * f, int error) {
  fiso_error_errno(f, error);
  // if(!f) { return 1; }
  return fiso_failed(f);
}

// Tries to get a socket for this fiso using the given 
// domain, type and protocol parameters
// returns self, modified 
Fiso * fiso_socket(Fiso *f, int domain, int type, int protocol) {
  fiso_handle(f, socket(domain, type, protocol));
  fiso_try(f, f->handle);
  return f;
}

// Tries to bind the fiso to the given address
Fiso * fiso_bind(Fiso *f, const struct sockaddr *my_addr, socklen_t addrlen) {
  fiso_try(f, bind(f->handle, my_addr, addrlen));
  return f;
}


// Polls the file and waits for swait s + (nwait) ns to see if 
// the fiso is ready for reading or writing.
// Sets the fiso's read_ready and write_ready, and perhaps also error on 
// error 
int fiso_poll(Fiso *f, int operation, long swait, long nwait) {
  int result;
  struct timespec timeout;
  
  if (operation & FISO_POLL_READ) {
    f->poll.events = POLLIN  | POLLPRI ; // | POLLRDHUP ???
    timeout.tv_sec  = f->read_wait_s;
    timeout.tv_nsec = f->read_wait_ns;
  }  
  if (operation & FISO_POLL_WRITE) {  
    f->poll.events = POLLOUT | POLLERR | POLLHUP | POLLNVAL;
    timeout.tv_sec  = f->write_wait_s;
    timeout.tv_nsec = f->write_wait_ns;
  }
  
  // Use ppoll because it's timeout is finer-grained than poll
  result = ppoll(&f->poll, 1, &timeout, NULL);
  // Get error from errno if needed 
  fiso_error_errno(f, result); 
  // negative or zero means not ready for reading or writing.  
  if (result < 1) {
    if (operation & FISO_POLL_READ) {       
      f->read_ready  = FALSE; 
    }
    if (operation & FISO_POLL_WRITE) {
      f->write_ready = FALSE;
    }  
    return 0;
  }
  // if we get here, we can read or write (or both) 
  if(f->poll.revents & POLLIN) {
      f->read_ready  = TRUE;
  }
  if(f->poll.revents & POLLOUT) {
      f->write_ready = TRUE;
  }
  return 1;
}


// Reads from the fiso into the buffer with the given size.
// return amount read, and also sets the fiso's error if need be
int fiso_read(Fiso * fiso, void *buf, size_t count) {
  int result;
  result = read(fiso->handle, buf, count); 
  fiso_error_errno(fiso, result);
  return result;
}

// Writes from the fiso using the given buffer with the given size.
// return amount written, and also sets the fiso's error if need be
int fiso_write(Fiso * fiso, void *buf, size_t count) {
  int result;
  result = write(fiso->handle, buf, count); 
  fiso_error_errno(fiso, result);
  return result;
}


// Locks a fiso file so no other processes can touch it.
Fiso * fiso_lock(Fiso * fiso) {
  int result;
  result = flock(fiso->handle , LOCK_EX | LOCK_NB);  
  fiso_error_errno(fiso, result);
  return fiso;
}  

// Unlocks a fiso file.
Fiso * fiso_unlock(Fiso * fiso) {
  int result;
  result    = flock(fiso->handle , LOCK_UN | LOCK_NB);  
  fiso_error_errno(fiso, result);
  return fiso;
}



