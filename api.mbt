///|
// High-level API wrapper for IB TWS/Gateway
// Provides a simplified, user-friendly interface for common operations

///|
pub struct IBApi {
  client : Client
}

///|
pub enum ApiError {
  ClientError(String)
  InvalidState(String)
  Timeout
  NotFound
}

///|
// Create a new IB API instance
pub fn new_ib_api(host : String, port : Int, client_id : Int) -> IBApi {
  let config = ConnectionConfig::{
    host,
    port,
    client_id,
    connect_options: Some(default_connect_options()),
  }
  let cl = new_client(config)
  { client: cl }
}

///|
// Connect to IB TWS or Gateway
pub fn api_connect(api : IBApi) -> Result[IBApi, ApiError] {
  match client_connect(api.client) {
    Ok(new_client) => Ok({ client: new_client })
    Err(e) => {
      let error_msg = match e {
        ConnectionFailed(msg) => "Connection failed: " + msg
        AlreadyConnected => "Already connected"
        _ => "Unknown connection error"
      }
      Err(ClientError(error_msg))
    }
  }
}

///|
// Disconnect from IB TWS or Gateway
pub fn api_disconnect(api : IBApi) -> Result[IBApi, ApiError] {
  match client_disconnect(api.client) {
    Ok(new_client) => Ok({ client: new_client })
    Err(e) => {
      let error_msg = match e {
        NotConnected => "Not connected"
        _ => "Unknown disconnection error"
      }
      Err(ClientError(error_msg))
    }
  }
}

///|
// Check if connected
pub fn api_is_connected(api : IBApi) -> Bool {
  client_is_connected(api.client)
}

///|
// Subscribe to market data for a contract
pub fn subscribe_market_data(
  api : IBApi,
  contract : Contract,
) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let req_id = api.client.next_order_id
  match req_market_data(api.client, req_id, contract) {
    Ok(_) => Ok(req_id)
    Err(e) => Err(ClientError("Failed to subscribe to market data"))
  }
}

///|
// Unsubscribe from market data
pub fn unsubscribe_market_data(
  api : IBApi,
  req_id : Int,
) -> Result[Unit, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  match cancel_market_data(api.client, req_id) {
    Ok(_) => Ok(())
    Err(e) => Err(ClientError("Failed to unsubscribe from market data"))
  }
}

///|
// Place a market order
pub fn place_market_order(
  api : IBApi,
  contract : Contract,
  action : OrderAction,
  quantity : Double,
) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let order = default_order()
  let order = Order::{
    order_id: api.client.next_order_id,
    client_id: order.client_id,
    action,
    total_quantity: quantity,
    order_type: Market,
    lmt_price: order.lmt_price,
    aux_price: order.aux_price,
    time_in_force: order.time_in_force,
    oca_group: order.oca_group,
    oca_type: order.oca_type,
    account: order.account,
    open_close: order.open_close,
    origin: order.origin,
    transmit: order.transmit,
    parent_id: order.parent_id,
    block_order: order.block_order,
    sweep_to_fill: order.sweep_to_fill,
    display_size: order.display_size,
    trigger_method: order.trigger_method,
    outside_rth: order.outside_rth,
    hidden: order.hidden,
    discretionary_amt: order.discretionary_amt,
    good_after_time: order.good_after_time,
    good_till_date: order.good_till_date,
    fa_group: order.fa_group,
    fa_method: order.fa_method,
    fa_percentage: order.fa_percentage,
    all_or_none: order.all_or_none,
    min_qty: order.min_qty,
    percent_offset: order.percent_offset,
    eTrade_only: order.eTrade_only,
    firm_quote_only: order.firm_quote_only,
    nbbo_price_cap: order.nbbo_price_cap,
    opt_out_smart_routing: order.opt_out_smart_routing,
    scale_init_level_size: order.scale_init_level_size,
    scale_subs_level_size: order.scale_subs_level_size,
    scale_price_increment: order.scale_price_increment,
    scale_price_adjust_value: order.scale_price_adjust_value,
    scale_price_adjust_interval: order.scale_price_adjust_interval,
    scale_profit_offset: order.scale_profit_offset,
    scale_auto_reset: order.scale_auto_reset,
    scale_init_position: order.scale_init_position,
    scale_init_fill_qty: order.scale_init_fill_qty,
    scale_random_percent: order.scale_random_percent,
    hedge_type: order.hedge_type,
    hedge_param: order.hedge_param,
    algo_strategy: order.algo_strategy,
    algo_params: order.algo_params,
    smart_combo_routing_params: order.smart_combo_routing_params,
    what_if: order.what_if,
    not_held: order.not_held,
  }
  match place_order(api.client, order.order_id, contract, order) {
    Ok(_) => Ok(order.order_id)
    Err(e) => Err(ClientError("Failed to place market order"))
  }
}

///|
// Place a limit order
pub fn place_limit_order(
  api : IBApi,
  contract : Contract,
  action : OrderAction,
  quantity : Double,
  limit_price : Double,
) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let order = default_order()
  let order = Order::{
    order_id: api.client.next_order_id,
    client_id: order.client_id,
    action,
    total_quantity: quantity,
    order_type: Limit,
    lmt_price: limit_price,
    aux_price: order.aux_price,
    time_in_force: order.time_in_force,
    oca_group: order.oca_group,
    oca_type: order.oca_type,
    account: order.account,
    open_close: order.open_close,
    origin: order.origin,
    transmit: order.transmit,
    parent_id: order.parent_id,
    block_order: order.block_order,
    sweep_to_fill: order.sweep_to_fill,
    display_size: order.display_size,
    trigger_method: order.trigger_method,
    outside_rth: order.outside_rth,
    hidden: order.hidden,
    discretionary_amt: order.discretionary_amt,
    good_after_time: order.good_after_time,
    good_till_date: order.good_till_date,
    fa_group: order.fa_group,
    fa_method: order.fa_method,
    fa_percentage: order.fa_percentage,
    all_or_none: order.all_or_none,
    min_qty: order.min_qty,
    percent_offset: order.percent_offset,
    eTrade_only: order.eTrade_only,
    firm_quote_only: order.firm_quote_only,
    nbbo_price_cap: order.nbbo_price_cap,
    opt_out_smart_routing: order.opt_out_smart_routing,
    scale_init_level_size: order.scale_init_level_size,
    scale_subs_level_size: order.scale_subs_level_size,
    scale_price_increment: order.scale_price_increment,
    scale_price_adjust_value: order.scale_price_adjust_value,
    scale_price_adjust_interval: order.scale_price_adjust_interval,
    scale_profit_offset: order.scale_profit_offset,
    scale_auto_reset: order.scale_auto_reset,
    scale_init_position: order.scale_init_position,
    scale_init_fill_qty: order.scale_init_fill_qty,
    scale_random_percent: order.scale_random_percent,
    hedge_type: order.hedge_type,
    hedge_param: order.hedge_param,
    algo_strategy: order.algo_strategy,
    algo_params: order.algo_params,
    smart_combo_routing_params: order.smart_combo_routing_params,
    what_if: order.what_if,
    not_held: order.not_held,
  }
  match place_order(api.client, order.order_id, contract, order) {
    Ok(_) => Ok(order.order_id)
    Err(e) => Err(ClientError("Failed to place limit order"))
  }
}

///|
// Place a stop order
pub fn place_stop_order(
  api : IBApi,
  contract : Contract,
  action : OrderAction,
  quantity : Double,
  stop_price : Double,
) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let order = default_order()
  let order = Order::{
    order_id: api.client.next_order_id,
    client_id: order.client_id,
    action,
    total_quantity: quantity,
    order_type: Stop,
    lmt_price: order.lmt_price,
    aux_price: stop_price,
    time_in_force: order.time_in_force,
    oca_group: order.oca_group,
    oca_type: order.oca_type,
    account: order.account,
    open_close: order.open_close,
    origin: order.origin,
    transmit: order.transmit,
    parent_id: order.parent_id,
    block_order: order.block_order,
    sweep_to_fill: order.sweep_to_fill,
    display_size: order.display_size,
    trigger_method: order.trigger_method,
    outside_rth: order.outside_rth,
    hidden: order.hidden,
    discretionary_amt: order.discretionary_amt,
    good_after_time: order.good_after_time,
    good_till_date: order.good_till_date,
    fa_group: order.fa_group,
    fa_method: order.fa_method,
    fa_percentage: order.fa_percentage,
    all_or_none: order.all_or_none,
    min_qty: order.min_qty,
    percent_offset: order.percent_offset,
    eTrade_only: order.eTrade_only,
    firm_quote_only: order.firm_quote_only,
    nbbo_price_cap: order.nbbo_price_cap,
    opt_out_smart_routing: order.opt_out_smart_routing,
    scale_init_level_size: order.scale_init_level_size,
    scale_subs_level_size: order.scale_subs_level_size,
    scale_price_increment: order.scale_price_increment,
    scale_price_adjust_value: order.scale_price_adjust_value,
    scale_price_adjust_interval: order.scale_price_adjust_interval,
    scale_profit_offset: order.scale_profit_offset,
    scale_auto_reset: order.scale_auto_reset,
    scale_init_position: order.scale_init_position,
    scale_init_fill_qty: order.scale_init_fill_qty,
    scale_random_percent: order.scale_random_percent,
    hedge_type: order.hedge_type,
    hedge_param: order.hedge_param,
    algo_strategy: order.algo_strategy,
    algo_params: order.algo_params,
    smart_combo_routing_params: order.smart_combo_routing_params,
    what_if: order.what_if,
    not_held: order.not_held,
  }
  match place_order(api.client, order.order_id, contract, order) {
    Ok(_) => Ok(order.order_id)
    Err(e) => Err(ClientError("Failed to place stop order"))
  }
}

///|
// Cancel an order
pub fn api_cancel_order(api : IBApi, order_id : Int) -> Result[Unit, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  match client_cancel_order(api.client, order_id) {
    Ok(_) => Ok(())
    Err(e) => Err(ClientError("Failed to cancel order"))
  }
}

///|
// Get all open orders
pub fn get_open_orders(api : IBApi) -> Result[Unit, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  match req_open_orders(api.client) {
    Ok(_) => Ok(())
    Err(e) => Err(ClientError("Failed to request open orders"))
  }
}

///|
// Get current positions
pub fn get_positions(api : IBApi) -> Result[Unit, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  match req_positions(api.client) {
    Ok(_) => Ok(())
    Err(e) => Err(ClientError("Failed to request positions"))
  }
}

///|
// Get account summary
pub fn get_account_summary(api : IBApi, tags : String) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let req_id = api.client.next_order_id
  match req_account_summary(api.client, req_id, "All", tags) {
    Ok(_) => Ok(req_id)
    Err(e) => Err(ClientError("Failed to request account summary"))
  }
}

///|
// Get managed accounts
pub fn get_managed_accounts(api : IBApi) -> Result[Unit, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  match req_managed_accounts(api.client) {
    Ok(_) => Ok(())
    Err(e) => Err(ClientError("Failed to request managed accounts"))
  }
}

///|
// Get account value
pub fn get_account_value(api : IBApi) -> Result[Unit, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  match req_account_updates(api.client, true, "") {
    Ok(_) => Ok(())
    Err(e) => Err(ClientError("Failed to request account updates"))
  }
}

///|
// Get historical data
pub fn get_historical_data(
  api : IBApi,
  contract : Contract,
  end_date_time : String,
  duration_str : String,
  bar_size : BarSize,
  what_to_show : WhatToShow,
) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let req_id = api.client.next_order_id
  match
    req_historical_data(
      api.client,
      req_id,
      contract,
      end_date_time,
      duration_str,
      bar_size,
      what_to_show,
      true,
      1,
      false,
    ) {
    Ok(_) => Ok(req_id)
    Err(e) => Err(ClientError("Failed to request historical data"))
  }
}

///|
// Get contract details
pub fn get_contract_details(
  api : IBApi,
  contract : Contract,
) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let req_id = api.client.next_order_id
  match req_contract_details(api.client, req_id, contract) {
    Ok(_) => Ok(req_id)
    Err(e) => Err(ClientError("Failed to request contract details"))
  }
}

///|
// Get execution details
pub fn get_executions(api : IBApi) -> Result[Unit, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  let filter = default_execution_filter()
  match req_executions(api.client, api.client.next_order_id, filter) {
    Ok(_) => Ok(())
    Err(e) => Err(ClientError("Failed to request executions"))
  }
}

///|
// Request next valid order ID
pub fn request_next_order_id(api : IBApi) -> Result[Int, ApiError] {
  if !api_is_connected(api) {
    return Err(InvalidState("Not connected"))
  }
  match req_ids(api.client, 1) {
    Ok(_) => Ok(api.client.next_order_id)
    Err(e) => Err(ClientError("Failed to request order ID"))
  }
}

///|
// Helper: Create a stock contract
pub fn stock_contract(
  symbol : String,
  exchange : String,
  currency : String,
) -> Contract {
  let contract = default_contract()
  Contract::{
    con_id: contract.con_id,
    symbol,
    sec_type: Stock,
    last_trade_date_or_contract_month: contract.last_trade_date_or_contract_month,
    strike: contract.strike,
    right: contract.right,
    multiplier: contract.multiplier,
    exchange,
    primary_exchange: contract.primary_exchange,
    currency,
    local_symbol: contract.local_symbol,
    trading_class: contract.trading_class,
    include_expired: contract.include_expired,
    sec_id_type: contract.sec_id_type,
    sec_id: contract.sec_id,
  }
}

///|
// Helper: Create a forex contract
pub fn forex_contract(
  symbol : String,
  exchange : String,
  currency : String,
) -> Contract {
  let contract = default_contract()
  Contract::{
    con_id: contract.con_id,
    symbol,
    sec_type: Forex,
    last_trade_date_or_contract_month: contract.last_trade_date_or_contract_month,
    strike: contract.strike,
    right: contract.right,
    multiplier: contract.multiplier,
    exchange,
    primary_exchange: contract.primary_exchange,
    currency,
    local_symbol: contract.local_symbol,
    trading_class: contract.trading_class,
    include_expired: contract.include_expired,
    sec_id_type: contract.sec_id_type,
    sec_id: contract.sec_id,
  }
}

///|
// Helper: Create an option contract
pub fn option_contract(
  symbol : String,
  last_trade_date : String,
  strike : Double,
  right : String,
  exchange : String,
  currency : String,
) -> Contract {
  let contract = default_contract()
  Contract::{
    con_id: contract.con_id,
    symbol,
    sec_type: Option,
    last_trade_date_or_contract_month: last_trade_date,
    strike,
    right,
    multiplier: contract.multiplier,
    exchange,
    primary_exchange: contract.primary_exchange,
    currency,
    local_symbol: contract.local_symbol,
    trading_class: contract.trading_class,
    include_expired: contract.include_expired,
    sec_id_type: contract.sec_id_type,
    sec_id: contract.sec_id,
  }
}

///|
// Helper: Create a futures contract
pub fn futures_contract(
  symbol : String,
  last_trade_date : String,
  exchange : String,
  currency : String,
) -> Contract {
  let contract = default_contract()
  Contract::{
    con_id: contract.con_id,
    symbol,
    sec_type: Future,
    last_trade_date_or_contract_month: last_trade_date,
    strike: contract.strike,
    right: contract.right,
    multiplier: contract.multiplier,
    exchange,
    primary_exchange: contract.primary_exchange,
    currency,
    local_symbol: contract.local_symbol,
    trading_class: contract.trading_class,
    include_expired: contract.include_expired,
    sec_id_type: contract.sec_id_type,
    sec_id: contract.sec_id,
  }
}

///|
// Set error callback
pub fn on_error(api : IBApi, callback : (ErrorCode, String) -> Unit) -> IBApi {
  let new_client = set_error_callback(api.client, callback)
  { client: new_client }
}

///|
// Set tick price callback
pub fn on_tick_price(
  api : IBApi,
  callback : (Int, TickType, Double, Int64) -> Unit,
) -> IBApi {
  let new_client = set_tick_price_callback(api.client, callback)
  { client: new_client }
}

///|
// Set tick size callback
pub fn on_tick_size(
  api : IBApi,
  callback : (Int, TickType, Int) -> Unit,
) -> IBApi {
  let new_client = set_tick_size_callback(api.client, callback)
  { client: new_client }
}

///|
// Set order status callback
pub fn on_order_status(
  api : IBApi,
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
) -> IBApi {
  let new_client = set_order_status_callback(api.client, callback)
  { client: new_client }
}

///|
// Set open order callback
pub fn on_open_order(
  api : IBApi,
  callback : (Int, Contract, Order, OrderState) -> Unit,
) -> IBApi {
  let new_client = set_open_order_callback(api.client, callback)
  { client: new_client }
}

///|
// Set execution callback
pub fn on_execution(
  api : IBApi,
  callback : (Int, Contract, Execution) -> Unit,
) -> IBApi {
  let new_client = set_execution_callback(api.client, callback)
  { client: new_client }
}

///|
// Set account summary callback
pub fn on_account_summary(
  api : IBApi,
  callback : (Int, String, String, String, String) -> Unit,
) -> IBApi {
  let new_client = set_account_summary_callback(api.client, callback)
  { client: new_client }
}

///|
// Set position callback
pub fn on_position(
  api : IBApi,
  callback : (String, Contract, Double, Double) -> Unit,
) -> IBApi {
  let new_client = set_position_callback(api.client, callback)
  { client: new_client }
}

///|
// Set historical data callback
pub fn on_historical_data(
  api : IBApi,
  callback : (Int, String, HistoricalDataBar) -> Unit,
) -> IBApi {
  let new_client = set_historical_data_callback(api.client, callback)
  { client: new_client }
}

///|
// Set managed accounts callback
pub fn on_managed_accounts(api : IBApi, callback : (String) -> Unit) -> IBApi {
  let new_client = set_managed_accounts_callback(api.client, callback)
  { client: new_client }
}

///|
// Process messages (should be called in a loop)
pub fn api_process_messages(api : IBApi) -> Result[IBApi, ApiError] {
  match client_process_messages(api.client) {
    Ok(new_client) => Ok({ client: new_client })
    Err(e) => {
      let error_msg = match e {
        NotConnected => "Not connected"
        SendError(msg) => "Send error: " + msg
        ReceiveError(msg) => "Receive error: " + msg
        _ => "Unknown error"
      }
      Err(ClientError(error_msg))
    }
  }
}
