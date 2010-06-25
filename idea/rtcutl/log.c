/*
* Logging functionality, using syslog.
*
*/
#include <syslog.h>
#include <stdarg.h>

#include "log.h"

// Open the connection to the system log.
void log_open(char * logname) {
  openlog(logname, LOG_CONS | LOG_NDELAY | LOG_PERROR | LOG_PID, LOG_USER);
}


// Close connection to the system log. 
void log_close() {
  closelog();
}

// Writes a variable fomat message to the system log.
void log_write_va(int priority, const char * message, va_list ap) {
  vsyslog(priority | LOG_USER, message, ap);   
} 

// Writes a debugging message to the system log. 
void log_debug(const char * message, ...) {
  va_list ap;
  va_start(ap, message);
  log_write_va(LOG_DEBUG, message, ap);  
  va_end(ap);
}

// Writes a notice message to the system log. 
void log_notice(const char * message, ...) {
  va_list ap;
  va_start(ap, message);
  log_write_va(LOG_NOTICE, message, ap);  
  va_end(ap);
}

// Writes a warning message to the system log. 
void log_warn(const char * message, ...) {
  va_list ap;
  va_start(ap, message);
  log_write_va(LOG_WARNING, message, ap);  
  va_end(ap);
}

// Writes an error message to the system log. 
void log_error(const char * message, ...) {
  va_list ap;
  va_start(ap, message);
  log_write_va(LOG_ERR, message, ap);  
  va_end(ap);
}

// Writes a fatal error message to the system log. 
void log_fatal(const char * message, ...) {
  va_list ap;
  va_start(ap, message);
  log_write_va(LOG_CRIT, message, ap);  
  va_end(ap);
}




