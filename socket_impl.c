// C implementation for TCP sockets using POSIX sockets
// This file provides the actual socket operations for the FFI
//
// Supports:
// - POSIX sockets (Linux, macOS, Unix)
// - Winsock (Windows)

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "ws2_32.lib")
typedef int socklen_t;
#else
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#define INVALID_SOCKET -1
#define SOCKET_ERROR -1
typedef int SOCKET;
#endif

// Error codes matching MoonBit enum
#define ERROR_NONE 0
#define ERROR_CONNECTION_REFUSED 1
#define ERROR_TIMEOUT 2
#define ERROR_CLOSED 3
#define ERROR_INVALID_SOCKET 4
#define ERROR_UNKNOWN 5

// Maximum number of active sockets
#define MAX_SOCKETS 256

// Socket storage
static SOCKET sockets[MAX_SOCKETS];
static int socket_count = 0;
static int next_socket_id = 1;

// Initialize Winsock on Windows
#ifdef _WIN32
static int winsock_initialized = 0;
static void init_winsock(void) {
    if (!winsock_initialized) {
        WSADATA wsa_data;
        if (WSAStartup(MAKEWORD(2, 2), &wsa_data) == 0) {
            winsock_initialized = 1;
        }
    }
}
#endif

// Store socket and return ID
static int store_socket(SOCKET sock) {
#ifdef _WIN32
    init_winsock();
#endif
    
    if (socket_count >= MAX_SOCKETS) {
        return -1;
    }
    
    int socket_id = next_socket_id++;
    int idx = socket_id % MAX_SOCKETS;
    sockets[idx] = sock;
    socket_count++;
    
    return socket_id;
}

// Find socket by ID
static SOCKET find_socket(int socket_id) {
    int idx = socket_id % MAX_SOCKETS;
    return sockets[idx];
}

// Remove socket from storage
static void remove_socket(int socket_id) {
    int idx = socket_id % MAX_SOCKETS;
    if (sockets[idx] != INVALID_SOCKET) {
#ifdef _WIN32
        closesocket(sockets[idx]);
#else
        close(sockets[idx]);
#endif
        sockets[idx] = INVALID_SOCKET;
        socket_count--;
    }
}

// Get error code from errno
static int get_socket_error(void) {
#ifdef _WIN32
    int err = WSAGetLastError();
    switch (err) {
        case WSAECONNREFUSED:
            return ERROR_CONNECTION_REFUSED;
        case WSAETIMEDOUT:
            return ERROR_TIMEOUT;
        case WSAECONNRESET:
        case WSAECONNABORTED:
            return ERROR_CLOSED;
        default:
            return ERROR_UNKNOWN;
    }
#else
    switch (errno) {
        case ECONNREFUSED:
            return ERROR_CONNECTION_REFUSED;
        case ETIMEDOUT:
            return ERROR_TIMEOUT;
        case ECONNRESET:
        case EPIPE:
            return ERROR_CLOSED;
        default:
            return ERROR_UNKNOWN;
    }
#endif
}

// Connect to a TCP socket
// Returns: { success: int, value: int, error: int }
void ibmoon_socket_connect(const char* host, int port, int timeout_ms, 
                         int* out_success, int* out_value, int* out_error) {
    SOCKET sock;
    struct sockaddr_in addr;
    
#ifdef _WIN32
    init_winsock();
#endif
    
    // Create socket
    sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock == INVALID_SOCKET) {
        *out_success = 0;
        *out_value = 0;
        *out_error = ERROR_UNKNOWN;
        return;
    }
    
    // Set socket to non-blocking for timeout support
#ifdef _WIN32
    unsigned long mode = 1;
    ioctlsocket(sock, FIONBIO, &mode);
#else
    int flags = fcntl(sock, F_GETFL, 0);
    fcntl(sock, F_SETFL, flags | O_NONBLOCK);
#endif
    
    // Setup address
    memset(&addr, 0, sizeof(addr));
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    
    if (inet_pton(AF_INET, host, &addr.sin_addr) <= 0) {
        // Invalid address
#ifdef _WIN32
        closesocket(sock);
#else
        close(sock);
#endif
        *out_success = 0;
        *out_value = 0;
        *out_error = ERROR_UNKNOWN;
        return;
    }
    
    // Attempt to connect
    int result = connect(sock, (struct sockaddr*)&addr, sizeof(addr));
    
    if (result == SOCKET_ERROR) {
#ifdef _WIN32
        int err = WSAGetLastError();
        if (err != WSAEWOULDBLOCK) {
            closesocket(sock);
            *out_success = 0;
            *out_value = 0;
            *out_error = get_socket_error();
            return;
        }
#else
        if (errno != EINPROGRESS) {
            close(sock);
            *out_success = 0;
            *out_value = 0;
            *out_error = get_socket_error();
            return;
        }
#endif
        
        // Wait for connection with timeout
        if (timeout_ms > 0) {
            fd_set write_fds;
            FD_ZERO(&write_fds);
            FD_SET(sock, &write_fds);
            
            struct timeval tv;
            tv.tv_sec = timeout_ms / 1000;
            tv.tv_usec = (timeout_ms % 1000) * 1000;
            
            result = select((int)sock + 1, NULL, &write_fds, NULL, &tv);
            
            if (result <= 0) {
                // Timeout or error
#ifdef _WIN32
                closesocket(sock);
#else
                close(sock);
#endif
                *out_success = 0;
                *out_value = 0;
                *out_error = (result == 0) ? ERROR_TIMEOUT : ERROR_UNKNOWN;
                return;
            }
            
            // Check if connection succeeded
            int error = 0;
            socklen_t len = sizeof(error);
            getsockopt(sock, SOL_SOCKET, SO_ERROR, (char*)&error, &len);
            
            if (error != 0) {
#ifdef _WIN32
                closesocket(sock);
#else
                close(sock);
#endif
                *out_success = 0;
                *out_value = 0;
                *out_error = ERROR_CONNECTION_REFUSED;
                return;
            }
        }
    }
    
    // Set back to blocking mode
#ifdef _WIN32
    mode = 0;
    ioctlsocket(sock, FIONBIO, &mode);
#else
    flags = fcntl(sock, F_GETFL, 0);
    fcntl(sock, F_SETFL, flags & ~O_NONBLOCK);
#endif
    
    // Store socket
    int socket_id = store_socket(sock);
    if (socket_id < 0) {
#ifdef _WIN32
        closesocket(sock);
#else
        close(sock);
#endif
        *out_success = 0;
        *out_value = 0;
        *out_error = ERROR_UNKNOWN;
        return;
    }
    
    *out_success = 1;
    *out_value = socket_id;
    *out_error = ERROR_NONE;
}

// Send data through socket
// Returns: { success: int, value: int, error: int }
void ibmoon_socket_send(int socket_id, const unsigned char* data, int length,
                      int* out_success, int* out_value, int* out_error) {
    SOCKET sock = find_socket(socket_id);
    
    if (sock == INVALID_SOCKET) {
        *out_success = 0;
        *out_value = 0;
        *out_error = ERROR_INVALID_SOCKET;
        return;
    }
    
    int bytes_sent = send(sock, (const char*)data, length, 0);
    
    if (bytes_sent == SOCKET_ERROR) {
        *out_success = 0;
        *out_value = 0;
        *out_error = get_socket_error();
        return;
    }
    
    *out_success = 1;
    *out_value = bytes_sent;
    *out_error = ERROR_NONE;
}

// Receive data from socket
// Returns: { success: int, value: int, error: int }
void ibmoon_socket_receive(int socket_id, unsigned char* buffer, int buffer_len, int timeout_ms,
                          int* out_success, int* out_value, int* out_error) {
    SOCKET sock = find_socket(socket_id);
    
    if (sock == INVALID_SOCKET) {
        *out_success = 0;
        *out_value = 0;
        *out_error = ERROR_INVALID_SOCKET;
        return;
    }
    
    // Set timeout if specified
    if (timeout_ms > 0) {
#ifdef _WIN32
        DWORD timeout = timeout_ms;
        setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, (const char*)&timeout, sizeof(timeout));
#else
        struct timeval tv;
        tv.tv_sec = timeout_ms / 1000;
        tv.tv_usec = (timeout_ms % 1000) * 1000;
        setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO, &tv, sizeof(tv));
#endif
    }
    
    int bytes_received = recv(sock, (char*)buffer, buffer_len, 0);
    
    if (bytes_received == SOCKET_ERROR) {
        *out_success = 0;
        *out_value = 0;
        *out_error = get_socket_error();
        return;
    }
    
    if (bytes_received == 0) {
        // Connection closed
        *out_success = 0;
        *out_value = 0;
        *out_error = ERROR_CLOSED;
        return;
    }
    
    *out_success = 1;
    *out_value = bytes_received;
    *out_error = ERROR_NONE;
}

// Close socket
// Returns: { success: int, value: int, error: int }
void ibmoon_socket_close(int socket_id,
                       int* out_success, int* out_value, int* out_error) {
    SOCKET sock = find_socket(socket_id);
    
    if (sock == INVALID_SOCKET) {
        *out_success = 0;
        *out_value = 0;
        *out_error = ERROR_INVALID_SOCKET;
        return;
    }
    
    remove_socket(socket_id);
    
    *out_success = 1;
    *out_value = 0;
    *out_error = ERROR_NONE;
}