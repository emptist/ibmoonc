///|
// IB MoonBit API Wrapper - C/Native Target
// Demonstrates basic usage of ibmoonc library with C FFI

///|
fn main {
  println("IB MoonBit API Wrapper - C/Native Target")
  println("=====================================")
  println("")
  println("This project provides a MoonBit wrapper for Interactive Brokers")
  println("TWS/Gateway API with C/Native FFI socket implementation.")
  println("")
  println("Features:")
  println("  - Full IB API support (market data, orders, account data)")
  println("  - C/Native FFI socket implementation")
  println("  - High-level API wrapper for easy integration")
  println("  - Comprehensive error handling")
  println("")
  println("Usage:")
  println("  1. Build: moon build --target c")
  println("  2. Run examples in the package root")
  println("  3. See README.md for detailed documentation")
  println("")
  println("Note: This is a C/Native-specific target. For other targets,")
  println("      see ibmoonjs (JavaScript/Node.js) or ibmoonwa (WebAssembly).")
  println("")
  println("Native Performance:")
  println("  - Direct POSIX socket access")
  println("  - Best performance for server-side applications")
  println("  - Suitable for high-frequency trading systems")
}
