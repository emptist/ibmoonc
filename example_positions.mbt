///|
// Example: Retrieve current positions
//
// IMPORTANT: This example requires a live IB TWS or Gateway instance running on port 7496.
// If no API is running, the test will pass but no position details will be printed.
// The callback with println statements is only invoked when successfully connected to the API.
//
// To run this example:
// 1. Start IB TWS or IB Gateway
// 2. Enable API connections with port 7496 (or your configured port)
// 3. Run: moon test --target wasm-gc example_positions.mbt

test "example_positions" {
  let config = connection_config("127.0.0.1", 7496, 1, None)
  let client = new_client(config)
  match client_connect(client) {
    Ok(client) => {
      println("Connected to IB TWS/Gateway")

      // Register callback to receive position data
      let client = set_position_callback(client, fn(
        account : String,
        contract : Contract,
        pos : Double,
        avg_cost : Double,
      ) -> Unit {
        println("Account: " + account)
        println("  Symbol: " + contract.symbol)
        println("  Position: " + Double::to_string(pos))
        println("  Average Cost: " + Double::to_string(avg_cost))
        println("")
      })

      // Request positions
      match req_positions(client) {
        Ok(_) => {
          println("Positions requested successfully")
          // Process messages in a loop to receive positions
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
