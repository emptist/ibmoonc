///|
// Socket abstraction layer for IB MoonBit API - C/Native Target
// This file provides C/Native-specific socket implementation using FFI

pub struct Socket {
  socket_id : Int
}

///|
pub struct Address {
  host : String
  port : Int
}

///|
pub enum SocketError {
  ConnectionRefused
  Timeout
  Closed
  Other(String)
}

///|
pub fn SocketError::to_string(self : SocketError) -> String {
  match self {
    ConnectionRefused => "ConnectionRefused"
    Timeout => "Timeout"
    Closed => "Closed"
    Other(msg) => "Other(" + msg + ")"
  }
}

// C/Native FFI implementations
// Actual implementations are in socket_impl.c
// These stubs provide informative error messages until C FFI is fully implemented

///|
pub fn connect(
  _addr : Address,
  _timeout_ms : Int,
) -> Result[Socket, SocketError] {
  // C FFI implementation would call socket_impl.c functions
  // For now, return informative error
  Err(Other("C FFI not yet implemented - see socket.mbt for details"))
}

///|
pub fn send(_sock : Socket, _data : Array[Byte]) -> Result[Unit, SocketError] {
  // C FFI implementation would call socket_impl.c functions
  // For now, return informative error
  Err(Other("C FFI not yet implemented - see socket.mbt for details"))
}

///|
pub fn receive(
  _sock : Socket,
  _length : Int,
  _timeout_ms : Int,
) -> Result[Array[Byte], SocketError] {
  // C FFI implementation would call socket_impl.c functions
  // For now, return informative error
  Err(Other("C FFI not yet implemented - see socket.mbt for details"))
}

///|
pub fn close(_sock : Socket) -> Result[Unit, SocketError] {
  // C FFI implementation would call socket_impl.c functions
  // For now, return informative error
  Err(Other("C FFI not yet implemented - see socket.mbt for details"))
}
