# IB MoonBit API Wrapper - C/Native Target

**Purpose**: This is the C/Native target-specific implementation of IB TWS/Gateway API wrapper for MoonBit.

## Why This Project Exists?

Due to a MoonBit language limitation, the main [ibmoon](../ibmoon) project cannot use target-specific FFI implementations when building with explicit targets. This project provides a working C/Native implementation that uses C FFI layer directly.

**See the [main ibmoon project](../ibmoon) for complete documentation on the FFI limitation and why multiple target-specific projects are needed.**

## Features

- **Target**: C/Native
- **FFI Implementation**: Uses POSIX sockets for network operations
- **Use Case**: Native applications, high-performance scenarios
- **Performance**: Best performance with native code execution

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
# Build for C target
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

- **C Compiler**: GCC or Clang required for native compilation
- **POSIX System**: Linux, macOS, or Windows with WSL
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
- **Platform Support**: Linux, macOS, Windows (via WSL)

### Core Files
All core IB API files are included:
- `types.mbt` - Data types for contracts, orders, etc.
- `orders.mbt` - Order types and helpers
- `protocol.mbt` - Message protocol definitions
- `encoder.mbt` - Message encoding
- `decoder.mbt` - Message decoding
- `client.mbt` - Connection and client management
- `api.mbt` - High-level API wrapper
- `handlers.mbt` - Message handlers for callbacks

## C-Specific Notes

- **Runtime**: Native execution, no JavaScript runtime required
- **Performance**: Best performance with direct native code execution
- **Memory Management**: Manual memory management for socket operations
- **Error Handling**: C errors are converted to MoonBit `Result` types
- **Socket Lifecycle**: Sockets must be explicitly closed to prevent resource leaks

## Platform Support

### Linux
- Full support with POSIX sockets
- Recommended for production deployments

### macOS
- Full support with BSD sockets
- Tested and verified

### Windows
- Limited support via WSL (Windows Subsystem for Linux)
- Native Windows support requires Win32 socket implementation

## Performance Characteristics

- **Connection Speed**: Fast (native TCP)
- **Message Throughput**: High (no JavaScript overhead)
- **Memory Usage**: Low (no V8 runtime)
- **CPU Usage**: Efficient (native code execution)

## Limitations

- **Windows Native**: Not supported without WSL
- **Cross-Platform**: Requires platform-specific builds
- **Binary Size**: Larger than WebAssembly targets

## Related Projects

- **[ibmoon](../ibmoon)** - Main project with complete documentation
- **[ibmoonjs](../ibmoonjs)** - JavaScript/Node.js target for server-side apps
- **[ibmoonwa](../ibmoonwa)** - WebAssembly target for browser environments

## License

Apache-2.0 - See [LICENSE](LICENSE) file for details

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.

## Support

- **Documentation**: See [ibmoon/docs](../ibmoon/docs) for comprehensive documentation
- **Issues**: Report issues in the main [ibmoon](../ibmoon) repository
- **FFI Details**: See [ibmoon/docs/FFI_INTEGRATION_GUIDE.md](../ibmoon/docs/FFI_INTEGRATION_GUIDE.md)