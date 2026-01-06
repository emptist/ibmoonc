///|
// Example: Basic connection and disconnection
//
// IMPORTANT: This example requires a live IB TWS or Gateway instance running on port 7496.
// If no API is running, the test will pass but no connection details will be printed.
// The callback with println statements is only invoked when successfully connected to the API.
//
// To run this example:
// 1. Start IB TWS or IB Gateway
// 2. Enable API connections with port 7496 (or your configured port)
// 3. Run: moon test --target wasm-gc example_connection.mbt

test "example_connection" {
  let config = connection_config("127.0.0.1", 7496, 1, None)
  let client = new_client(config)
  match client_connect(client) {
    Ok(client) => {
      println("Connected to IB TWS/Gateway")

      // Register error callback
      let client = set_error_callback(client, fn(
        _code : ErrorCode,
        msg : String,
      ) -> Unit {
        println("Error: " + msg)
      })

      // Request next valid order ID
      match req_ids(client, 1) {
        Ok(_) => {
          println("Order ID requested")
          // Process messages in a loop to receive order ID
          // We call it multiple times to ensure we get the response
          for i = 0; i < 10; i = i + 1 {
            match client_process_messages(client) {
              Ok(_) => ()
              Err(_) => ()
            }
          }
        }
        Err(_) => ()
      }
      match client_disconnect(client) {
        Ok(_) => ()
        Err(_) => ()
      }
    }
    Err(_) => ()
  }
}
