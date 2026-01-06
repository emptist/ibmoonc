///|
// Example: Retrieve all account IDs associated with your login session
//
// IMPORTANT: This example requires a live IB TWS or Gateway instance running on port 7496.
// If no API is running, the test will pass but no account details will be printed.
// The callback with println statements is only invoked when successfully connected to the API.
//
// To run this example:
// 1. Start IB TWS or IB Gateway
// 2. Enable API connections with port 7496 (or your configured port)
// 3. Run: moon test --target wasm-gc example_managed_accounts.mbt

test "example_managed_accounts" {
  let config = connection_config("127.0.0.1", 7496, 1, None)
  let client = new_client(config)
  match client_connect(client) {
    Ok(client) => {
      println("Connected to IB TWS/Gateway")

      // Register callback to receive managed accounts
      let client = set_managed_accounts_callback(client, fn(
        accounts_list : String,
      ) -> Unit {
        println("")
        println("=" + "=".repeat(60))
        println("MANAGED ACCOUNTS")
        println("=" + "=".repeat(60))
        println("")
        println("Account List: " + accounts_list)
        println("")
        println("Account Details:")
        println("  The accounts are comma-separated in the list above")
        println("  Each account ID can be used for account-specific operations")
        println("")
        println("=" + "=".repeat(60))
        println("")
      })

      // Request managed accounts
      match req_managed_accounts(client) {
        Ok(_) => {
          println("Managed accounts requested successfully")
          // Process messages in a loop to receive managed accounts
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
