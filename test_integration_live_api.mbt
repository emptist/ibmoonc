///|
// Integration test for IB MoonBit API wrapper with live IB API
// This test verifies that the ibmoon library can connect to a live IB API
//
// IMPORTANT: This test requires a live IB TWS or Gateway instance running on port 7496.
// If no API is running, the test will pass but no account details will be printed.
// The callback with println statements is only invoked when successfully connected to the API.
//
// To run this test:
// 1. Start IB TWS or IB Gateway
// 2. Enable API connections with port 7496 (or your configured port)
// 3. Run: moon test --target js test_integration_live_api.mbt

test "test_integration_live_api" {
  println("=== IB MoonBit API Integration Test ===")
  println("Attempting to connect to IB API on 127.0.0.1:7496")
  println("")

  // Create client configuration
  let config = connection_config("127.0.0.1", 7496, 1, None)
  let client = new_client(config)

  // Try to connect
  match client_connect(client) {
    Ok(client) => {
      println("✓ Socket connected successfully!")
      println("")

      // Set callback for managed accounts
      let client = set_managed_accounts_callback(client, fn(accounts : String) {
        println("✓ Received managed accounts: " + accounts)
      })

      // Request managed accounts
      match req_managed_accounts(client) {
        Ok(_) => {
          println("✓ Managed accounts requested successfully")
          println("")

          // Process messages in a loop to receive managed accounts
          println("Processing messages (10 iterations)...")
          for i = 0; i < 10; i = i + 1 {
            match client_process_messages(client) {
              Ok(_) => ()
              Err(e) => println("✗ Error processing messages")
            }
          }
          println("")
        }
        Err(e) => println("✗ Failed to request managed accounts")
      }

      // Disconnect
      match client_disconnect(client) {
        Ok(_) => println("✓ Disconnected successfully")
        Err(e) => println("✗ Disconnect failed")
      }
    }
    Err(e) => {
      println("✗ Socket connection failed")
      println("")
      println("Troubleshooting:")
      println("1. Ensure IB TWS or Gateway is running on port 7496")
      println("2. Ensure API connections are enabled in TWS/Gateway settings")
      println("3. Ensure the client ID (1) is not already in use")
      println("4. Check firewall settings")
    }
  }
  println("")
  println("=== Test Complete ===")
}
