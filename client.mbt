///|
// IB API Client - Main connection and request manager
// Provides the high-level interface for interacting with IB TWS/Gateway

///|
pub struct Client {
  config : ConnectionConfig
  state : ConnectionState
  socket : Socket?
  server_version : Int
  connection_time : Int64?
  next_order_id : Int
  // Callbacks
  on_error : ((ErrorCode, String) -> Unit)?
  on_tick_price : ((Int, TickType, Double, Int64) -> Unit)?
  on_tick_size : ((Int, TickType, Int) -> Unit)?
  on_order_status : ((
    Int,
    String,
    Double,
    Double,
    Double,
    Int,
    Int,
    Double,
    Int,
    String,
  ) -> Unit)?
  on_open_order : ((Int, Contract, Order, OrderState) -> Unit)?
  on_execution : ((Int, Contract, Execution) -> Unit)?
  on_account_summary : ((Int, String, String, String, String) -> Unit)?
  on_position : ((String, Contract, Double, Double) -> Unit)?
  on_historical_data : ((Int, String, HistoricalDataBar) -> Unit)?
  on_managed_accounts : ((String) -> Unit)?
}

///|
pub enum ClientError {
  ConnectionFailed(String)
  NotConnected
  AlreadyConnected
  SendError(String)
  ReceiveError(String)
  InvalidParameter(String)
}

///|
pub fn new_client(config : ConnectionConfig) -> Client {
  {
    config,
    state: Disconnected,
    socket: None,
    server_version: 0,
    connection_time: None,
    next_order_id: 0,
    on_error: None,
    on_tick_price: None,
    on_tick_size: None,
    on_order_status: None,
    on_open_order: None,
    on_execution: None,
    on_account_summary: None,
    on_position: None,
    on_historical_data: None,
    on_managed_accounts: None,
  }
}

///|
// Connect to IB TWS or Gateway
pub fn client_connect(client : Client) -> Result[Client, ClientError] {
  match client.state {
    Connected => Err(AlreadyConnected)
    _ => {
      let addr = { host: client.config.host, port: client.config.port }
      match connect(addr, 10000) {
        Ok(sock) => {
          // Send initial handshake
          let enc = new_encoder(1024)
          let enc = write_int(enc, client.config.client_id)
          let enc = write_int(enc, 2) // API version
          let enc = write_int(enc, 0) // client code
          match send(sock, get_bytes(enc)) {
            Ok(_) =>
              // Read server version
              match receive(sock, 4, 10000) {
                Ok(buffer) =>
                  match read_int(new_decoder(buffer)) {
                    Ok((server_version, _)) => {
                      let new_client = {
                        config: client.config,
                        state: Connected,
                        socket: Some(sock),
                        server_version,
                        connection_time: Some(get_current_time()),
                        next_order_id: 0,
                        on_error: client.on_error,
                        on_tick_price: client.on_tick_price,
                        on_tick_size: client.on_tick_size,
                        on_order_status: client.on_order_status,
                        on_open_order: client.on_open_order,
                        on_execution: client.on_execution,
                        on_account_summary: client.on_account_summary,
                        on_position: client.on_position,
                        on_historical_data: client.on_historical_data,
                        on_managed_accounts: client.on_managed_accounts,
                      }
                      Ok(new_client)
                    }
                    Err(_) =>
                      Err(ConnectionFailed("Failed to read server version"))
                  }
                Err(_) =>
                  Err(ConnectionFailed("Failed to receive server version"))
              }
            Err(e) => Err(ConnectionFailed("Failed to send handshake"))
          }
        }
        Err(e) => Err(ConnectionFailed("Connection failed"))
      }
    }
  }
}

///|
// Disconnect from IB TWS or Gateway
pub fn client_disconnect(client : Client) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) =>
      match close(sock) {
        Ok(_) => {
          let new_client = {
            config: client.config,
            state: Disconnected,
            socket: None,
            server_version: 0,
            connection_time: None,
            next_order_id: client.next_order_id,
            on_error: client.on_error,
            on_tick_price: client.on_tick_price,
            on_tick_size: client.on_tick_size,
            on_order_status: client.on_order_status,
            on_open_order: client.on_open_order,
            on_execution: client.on_execution,
            on_account_summary: client.on_account_summary,
            on_position: client.on_position,
            on_historical_data: client.on_historical_data,
            on_managed_accounts: client.on_managed_accounts,
          }
          Ok(new_client)
        }
        Err(e) => Err(SendError("Failed to close socket"))
      }
    None => Err(NotConnected)
  }
}

///|
// Check if client is connected
pub fn client_is_connected(client : Client) -> Bool {
  match client.state {
    Connected => true
    _ => false
  }
}

///|
// Get connection state
pub fn get_state(client : Client) -> ConnectionState {
  client.state
}

///|
// Request market data
pub fn req_market_data(
  client : Client,
  req_id : Int,
  contract : Contract,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(4096)
      let enc = write_int(enc, 1) // Message type: REQ_MKT_DATA
      let enc = write_int(enc, req_id)
      let enc = write_contract(enc, contract)
      let enc = write_string(enc, "") // genericTickList
      let enc = write_bool(enc, false) // snapshot
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to send market data request"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Cancel market data
pub fn cancel_market_data(
  client : Client,
  req_id : Int,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 2) // Message type: CANCEL_MKT_DATA
      let enc = write_int(enc, req_id)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to cancel market data"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Place an order
pub fn place_order(
  client : Client,
  order_id : Int,
  contract : Contract,
  order : Order,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(4096)
      let enc = write_int(enc, 3) // Message type: PLACE_ORDER
      let enc = write_int(enc, order_id)
      let enc = write_contract(enc, contract)
      let enc = write_order(enc, order)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to place order"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Cancel an order
pub fn client_cancel_order(
  client : Client,
  order_id : Int,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 4) // Message type: CANCEL_ORDER
      let enc = write_int(enc, order_id)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to cancel order"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request all open orders
pub fn req_open_orders(client : Client) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 5) // Message type: REQ_OPEN_ORDERS
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request open orders"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request account updates
pub fn req_account_updates(
  client : Client,
  subscribe : Bool,
  account_code : String,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 6) // Message type: REQ_ACCOUNT_UPDATES
      let enc = write_bool(enc, subscribe)
      let enc = write_string(enc, account_code)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request account updates"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request execution details
pub fn req_executions(
  client : Client,
  req_id : Int,
  filter : ExecutionFilter,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(4096)
      let enc = write_int(enc, 7) // Message type: REQ_EXECUTIONS
      let enc = write_int(enc, req_id)
      let enc = write_int(enc, filter.client_id)
      let enc = write_string(enc, filter.account_code)
      let enc = write_string(enc, filter.time)
      let enc = write_string(enc, filter.symbol)
      let enc = write_string(enc, filter.sec_type)
      let enc = write_string(enc, filter.exchange)
      let enc = write_string(enc, filter.side)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request executions"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
pub struct ExecutionFilter {
  client_id : Int
  account_code : String
  time : String
  symbol : String
  sec_type : String
  exchange : String
  side : String
}

///|
pub fn default_execution_filter() -> ExecutionFilter {
  {
    client_id: 0,
    account_code: "",
    time: "",
    symbol: "",
    sec_type: "",
    exchange: "",
    side: "",
  }
}

///|
// Request IDs
pub fn req_ids(client : Client, num_ids : Int) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 8) // Message type: REQ_IDS
      let enc = write_int(enc, num_ids)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request IDs"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request contract details
pub fn req_contract_details(
  client : Client,
  req_id : Int,
  contract : Contract,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(4096)
      let enc = write_int(enc, 9) // Message type: REQ_CONTRACT_DETAILS
      let enc = write_int(enc, req_id)
      let enc = write_contract(enc, contract)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request contract details"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request market depth
pub fn req_market_depth(
  client : Client,
  req_id : Int,
  contract : Contract,
  num_rows : Int,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(4096)
      let enc = write_int(enc, 10) // Message type: REQ_MKT_DEPTH
      let enc = write_int(enc, req_id)
      let enc = write_contract(enc, contract)
      let enc = write_int(enc, num_rows)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request market depth"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Cancel market depth
pub fn cancel_market_depth(
  client : Client,
  req_id : Int,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 11) // Message type: CANCEL_MKT_DEPTH
      let enc = write_int(enc, req_id)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to cancel market depth"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request historical data
pub fn req_historical_data(
  client : Client,
  req_id : Int,
  contract : Contract,
  end_date_time : String,
  duration_str : String,
  bar_size : BarSize,
  what_to_show : WhatToShow,
  use_rth : Bool,
  format_date : Int,
  keep_up_to_date : Bool,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(4096)
      let enc = write_int(enc, 20) // Message type: REQ_HISTORICAL_DATA
      let enc = write_int(enc, req_id)
      let enc = write_contract(enc, contract)
      let enc = write_string(enc, end_date_time)
      let enc = write_string(enc, duration_str)
      let enc = write_string(enc, bar_size_to_string(bar_size))
      let enc = write_string(enc, what_to_show_to_string(what_to_show))
      let enc = write_int(enc, if use_rth { 1 } else { 0 })
      let enc = write_int(enc, format_date)
      let enc = write_bool(enc, keep_up_to_date)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request historical data"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request positions
pub fn req_positions(client : Client) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 59) // Message type: REQ_POSITIONS
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request positions"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request account summary
pub fn req_account_summary(
  client : Client,
  req_id : Int,
  group_name : String,
  tags : String,
) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(4096)
      let enc = write_int(enc, 63) // Message type: REQ_ACCOUNT_SUMMARY
      let enc = write_int(enc, req_id)
      let enc = write_string(enc, group_name)
      let enc = write_string(enc, tags)
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request account summary"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Request managed accounts
pub fn req_managed_accounts(client : Client) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) => {
      let enc = new_encoder(256)
      let enc = write_int(enc, 17) // Message type: REQ_MANAGED_ACCTS
      match send(sock, get_bytes(enc)) {
        Ok(_) => Ok(client)
        Err(e) => Err(SendError("Failed to request managed accounts"))
      }
    }
    None => Err(NotConnected)
  }
}

///|
// Set error callback
pub fn set_error_callback(
  client : Client,
  callback : (ErrorCode, String) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: Some(callback),
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set tick price callback
pub fn set_tick_price_callback(
  client : Client,
  callback : (Int, TickType, Double, Int64) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: Some(callback),
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set tick size callback
pub fn set_tick_size_callback(
  client : Client,
  callback : (Int, TickType, Int) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: Some(callback),
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set order status callback
pub fn set_order_status_callback(
  client : Client,
  callback : (
    Int,
    String,
    Double,
    Double,
    Double,
    Int,
    Int,
    Double,
    Int,
    String,
  ) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: Some(callback),
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set open order callback
pub fn set_open_order_callback(
  client : Client,
  callback : (Int, Contract, Order, OrderState) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: Some(callback),
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set execution callback
pub fn set_execution_callback(
  client : Client,
  callback : (Int, Contract, Execution) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: Some(callback),
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set account summary callback
pub fn set_account_summary_callback(
  client : Client,
  callback : (Int, String, String, String, String) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: Some(callback),
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set position callback
pub fn set_position_callback(
  client : Client,
  callback : (String, Contract, Double, Double) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: Some(callback),
    on_historical_data: client.on_historical_data,
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set historical data callback
pub fn set_historical_data_callback(
  client : Client,
  callback : (Int, String, HistoricalDataBar) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: Some(callback),
    on_managed_accounts: client.on_managed_accounts,
  }
}

///|
// Set managed accounts callback
pub fn set_managed_accounts_callback(
  client : Client,
  callback : (String) -> Unit,
) -> Client {
  {
    config: client.config,
    state: client.state,
    socket: client.socket,
    server_version: client.server_version,
    connection_time: client.connection_time,
    next_order_id: client.next_order_id,
    on_error: client.on_error,
    on_tick_price: client.on_tick_price,
    on_tick_size: client.on_tick_size,
    on_order_status: client.on_order_status,
    on_open_order: client.on_open_order,
    on_execution: client.on_execution,
    on_account_summary: client.on_account_summary,
    on_position: client.on_position,
    on_historical_data: client.on_historical_data,
    on_managed_accounts: Some(callback),
  }
}

///|
// Helper function to get current time (placeholder)
pub fn get_current_time() -> Int64 {
  // This should be implemented using system time
  // For now, return a placeholder value
  0L
}

///|
// Process incoming messages (should be called in a loop)
pub fn client_process_messages(client : Client) -> Result[Client, ClientError] {
  match client.socket {
    Some(sock) =>
      match receive(sock, 4096, 1000) {
        Ok(buffer) =>
          // Use handlers to process the message
          match handle_message(buffer, client) {
            Ok((new_client, consumed)) =>
              // Successfully processed the message
              // In a real implementation, we might have multiple messages in one buffer
              // and would need to handle them sequentially
              Ok(new_client)
            Err(msg) => {
              // Failed to process message
              match client.on_error {
                Some(callback) => callback(UnknownError(0), msg)
                None => ()
              }
              Ok(client)
            }
          }
        Err(e) =>
          // Timeout is expected when no data is available
          match e {
            Timeout => Ok(client)
            _ => Err(ReceiveError("Failed to receive message"))
          }
      }
    None => Err(NotConnected)
  }
}
