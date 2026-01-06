# IB MoonBit API Wrapper - C/Native Target

**Purpose**: This is the C/Native target-specific implementation of the IB TWS/Gateway API wrapper for MoonBit.

## Why This Project Exists?

Due to a MoonBit language limitation, the main [ibmoon](../ibmoon) project cannot use target-specific FFI implementations when building with explicit targets. This project provides a working C/Native implementation that uses the C FFI layer directly.

**See the [main ibmoon project](../ibmoon) for complete documentation on the FFI limitation and why multiple target-specific projects are needed.**

## Features

- **Target**: C/Native
- **FFI Implementation**: Uses POSIX sockets for socket operations
- **Use Case**: Native applications, high-performance systems
- **Performance**: Best performance for I/O-bound operations

## Installation

```bash
# Add this project as a dependency in your moon.pkg.json
{
  "import": [
    {
      "path": "../ibmoonc",
      "alias": "ibmoon"
    }
  ]
}
```

## Building

```bash
# Build for C/Native target
moon build --target c

# Run tests
moon test --target c
```

## Usage

```moonbit
import "ibmoon"

// Create client
let config = ibmoon::connection_config("127.0.0.1", 7496, 1, None)
let client = ibmoon::new_client(config)

// Connect
match ibmoon::client_connect(client) {
  Ok(client) => {
    println("Connected to IB TWS/Gateway")
    
    // Set up callbacks
    let client = ibmoon::set_managed_accounts_callback(client, fn(accounts : String) {
      println("Accounts: " + accounts)
    })
    
    // Request managed accounts
    match ibmoon::req_managed_accounts(client) {
      Ok(_) => {
        // Process messages
        for i = 0; i < 10; i = i + 1 {
          ibmoon::client_process_messages(client)
        }
      }
      Err(e) => ()
    }
    
    // Disconnect
    ibmoon::client_disconnect(client)
  }
  Err(e) => {
    println("Failed to connect")
  }
}
```

## Running Examples

```bash
# Run managed accounts example
moon run --target c cmd/main/example_managed_accounts

# Run account summary example
moon run --target c cmd/main/example_account_summary

# Run positions example
moon run --target c cmd/main/example_positions
```

## Prerequisites

- **C Compiler**: Required for native compilation (GCC, Clang, or compatible)
- **POSIX System**: Linux, macOS, or other POSIX-compliant systems
- **IB TWS or IB Gateway**: Must be running and configured with API access
- **API Port**: Default is 7496 for paper trading, 7497 for live trading
- **API Connections**: Must be enabled in TWS/Gateway settings

## Testing with Live IB API

To test with a live IB API:

1. Start IB TWS or IB Gateway
2. Enable API connections on port 7496
3. Ensure client ID is not already in use
4. Run integration test:

```bash
moon test --target c
```

## Architecture

### Socket Layer
- **File**: `socket.mbt`
- **FFI File**: `socket_impl.c`
- **Implementation**: Uses POSIX sockets for TCP connections

### Core Files
All core IB API files are included:
- `api.mbt` - High-level API wrapper
- `client.mbt` - Connection and client management
- `decoder.mbt` - Message decoding
- `encoder.mbt` - Message encoding
- `handlers.mbt` - Message handlers for callbacks
- `protocol.mbt` - Message protocol definitions
- `socket.mbt` - Socket abstraction layer
- `ibmoon.mbt` - Main package interface

## C/Native-Specific Notes

- **Runtime**: Native C runtime
- **POSIX Sockets**: Direct socket access for maximum performance
- **Error Handling**: C errors are converted to MoonBit `Result` types
- **Socket Lifecycle**: Sockets are managed manually, must be closed explicitly
- **Platform**: Requires POSIX-compliant operating system (Linux, macOS, BSD, etc.)

## Performance Characteristics

- **Latency**: Lowest among all targets (direct native execution)
- **Memory**: Efficient memory management
- **CPU**: Native execution without JIT overhead
- **I/O**: Direct socket access with minimal abstraction

## Limitations

- **Platform**: Only POSIX-compliant systems (Linux, macOS, BSD)
- **Windows**: Not currently supported (would need Win32 socket implementation)
- **Manual Memory Management**: Requires careful socket lifecycle management

## Related Projects

- **[ibmoon](../ibmoon)** - Main project with complete documentation
- **[ibmoonjs](../ibmoonjs)** - JavaScript/Node.js target for server-side applications
- **[ibmoonwa](../ibmoonwa)** - WebAssembly target for browser environments

## License

Apache-2.0 - See [LICENSE](LICENSE) file for details

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Support

- **Documentation**: See [ibmoon/docs](../ibmoon/docs) for comprehensive documentation
- **Issues**: Report issues in the main [ibmoon](../ibmoon) repository
- **FFI Details**: See [ibmoon/docs/FFI_INTEGRATION_GUIDE.md](../ibmoon/docs/FFI_INTEGRATION_GUIDE.md)