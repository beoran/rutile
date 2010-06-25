/*
* Logging functionality. Uses the system log on Linux.
*/

#ifndef _LOG_H_
#define _LOG_H_

// Opens the connection to the system log.
void log_open(char * logname); 

// Closes connection to the system log. 
void log_close();

// Writes a debugging message to the system log. 
void log_debug(const char * message, ...); 

// Writes a notice message to the system log. 
void log_notice(const char * message, ...); 

// Writes a warning message to the system log. 
void log_warn(const char * message, ...); 

// Writes an error message to the system log. 
void log_error(const char * message, ...); 

// Writes a fatal error message to the system log. 
void log_fatal(const char * message, ...); 


#endif
