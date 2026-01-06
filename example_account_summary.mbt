///|
// Example: Retrieve account financial summary
//
// IMPORTANT: This example requires a live IB TWS or Gateway instance running on port 7496.
// If no API is running, the test will pass but no account details will be printed.
// The callback with println statements is only invoked when successfully connected to the API.
//
// To run this example:
// 1. Start IB TWS or IB Gateway
// 2. Enable API connections with port 7496 (or your configured port)
// 3. Run: moon test --target wasm-gc example_account_summary.mbt

test "example_account_summary" {
  let config = connection_config("127.0.0.1", 7496, 1, None)
  let client = new_client(config)
  match client_connect(client) {
    Ok(client) => {
      println("Connected to IB TWS/Gateway")

      // Register callback to receive account summary data
      let client = set_account_summary_callback(client, fn(
        _req_id : Int,
        account : String,
        tag : String,
        value : String,
        currency : String,
      ) -> Unit {
        println("Account: " + account)
        println("  Tag: " + tag)
        println("  Value: " + value)
        println("  Currency: " + currency)
        println("")
      })

      // Request account summary with common financial metrics
      let tags = "TotalCashValue,NetLiquidation,AvailableFunds,GrossPositionValue,ExcessLiquidity"
      match req_account_summary(client, 1, "All", tags) {
        Ok(_) => {
          println("Account summary requested successfully")
          // Process messages in a loop to receive account summary
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
