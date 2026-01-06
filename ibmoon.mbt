///|
// IB TWS/Gateway API Wrapper for MoonBit
// This module provides a comprehensive interface to Interactive Brokers' API

///|
// Connection configuration
pub struct ConnectionConfig {
  host : String
  port : Int
  client_id : Int
  connect_options : ConnectOptions?
}

///|
pub fn default_connection_config() -> ConnectionConfig {
  { host: "127.0.0.1", port: 7497, client_id: 1, connect_options: None }
}

///|
pub fn connection_config(
  host : String,
  port : Int,
  client_id : Int,
  connect_options : ConnectOptions?,
) -> ConnectionConfig {
  { host, port, client_id, connect_options }
}

///|
pub struct ConnectOptions {
  read_only : Bool
  reconnect_attempts : Int
  reconnect_delay_ms : Int
}

///|
pub fn default_connect_options() -> ConnectOptions {
  { read_only: false, reconnect_attempts: 3, reconnect_delay_ms: 1000 }
}

///|
// Connection state
pub enum ConnectionState {
  Disconnected
  Connecting
  Connected
  Disconnecting
  Error(String)
}

///|
// Contract types
pub enum SecType {
  Stock
  Option
  Future
  Forex
  Bond
  CFD
  FutureOption
  MutualFund
  Warrant
  StructuredProduct
  Index
  Commodity
}

///|
pub fn sec_type_to_string(st : SecType) -> String {
  match st {
    Stock => "STK"
    Option => "OPT"
    Future => "FUT"
    Forex => "CASH"
    Bond => "BOND"
    CFD => "CFD"
    FutureOption => "FOP"
    MutualFund => "FUND"
    Warrant => "IOPT"
    StructuredProduct => "IKS"
    Index => "IND"
    Commodity => "CMDTY"
  }
}

///|
pub fn string_to_sec_type(s : String) -> SecType? {
  match s {
    "STK" => Some(Stock)
    "OPT" => Some(Option)
    "FUT" => Some(Future)
    "CASH" => Some(Forex)
    "BOND" => Some(Bond)
    "CFD" => Some(CFD)
    "FOP" => Some(FutureOption)
    "FUND" => Some(MutualFund)
    "IOPT" => Some(Warrant)
    "IKS" => Some(StructuredProduct)
    "IND" => Some(Index)
    "CMDTY" => Some(Commodity)
    _ => None
  }
}

///|
// Contract details
pub struct Contract {
  con_id : Int
  symbol : String
  sec_type : SecType
  last_trade_date_or_contract_month : String
  strike : Double
  right : String
  multiplier : String
  exchange : String
  primary_exchange : String
  currency : String
  local_symbol : String
  trading_class : String
  include_expired : Bool
  sec_id_type : String
  sec_id : String
}

///|
pub fn default_contract() -> Contract {
  {
    con_id: 0,
    symbol: "",
    sec_type: Stock,
    last_trade_date_or_contract_month: "",
    strike: 0.0,
    right: "",
    multiplier: "",
    exchange: "SMART",
    primary_exchange: "",
    currency: "USD",
    local_symbol: "",
    trading_class: "",
    include_expired: false,
    sec_id_type: "",
    sec_id: "",
  }
}

///|
// Order types
pub enum OrderType {
  Market
  Limit
  Stop
  StopLimit
  MarketOnClose
  LimitOnClose
  MarketOnOpen
  LimitOnOpen
  Trail
  TrailLimit
  Relative
  Pegged
}

///|
pub fn order_type_to_string(ot : OrderType) -> String {
  match ot {
    Market => "MKT"
    Limit => "LMT"
    Stop => "STP"
    StopLimit => "STP LMT"
    MarketOnClose => "MOC"
    LimitOnClose => "LOC"
    MarketOnOpen => "MOP"
    LimitOnOpen => "LOO"
    Trail => "TRAIL"
    TrailLimit => "TRAIL LIMIT"
    Relative => "REL"
    Pegged => "PEG"
  }
}

///|
// Time in force
pub enum TimeInForce {
  Day
  GTC
  OPG
  IOC
  FOK
  GTX
  GTD
}

///|
pub fn time_in_force_to_string(tif : TimeInForce) -> String {
  match tif {
    Day => "DAY"
    GTC => "GTC"
    OPG => "OPG"
    IOC => "IOC"
    FOK => "FOK"
    GTX => "GTX"
    GTD => "GTD"
  }
}

///|
// Order action
pub enum OrderAction {
  Buy
  Sell
  SSHORT
  SSHORTX
}

///|
pub fn order_action_to_string(oa : OrderAction) -> String {
  match oa {
    Buy => "BUY"
    Sell => "SELL"
    SSHORT => "SSHORT"
    SSHORTX => "SSHORTX"
  }
}

///|
// Order details
pub struct Order {
  order_id : Int
  client_id : Int
  action : OrderAction
  total_quantity : Double
  order_type : OrderType
  lmt_price : Double
  aux_price : Double
  time_in_force : TimeInForce
  oca_group : String
  oca_type : Int
  account : String
  open_close : String
  origin : Int
  transmit : Bool
  parent_id : Int
  block_order : Bool
  sweep_to_fill : Bool
  display_size : Int
  trigger_method : Int
  outside_rth : Bool
  hidden : Bool
  discretionary_amt : Double
  good_after_time : String
  good_till_date : String
  fa_group : String
  fa_method : String
  fa_percentage : String
  all_or_none : Bool
  min_qty : Int
  percent_offset : Double
  eTrade_only : Bool
  firm_quote_only : Bool
  nbbo_price_cap : Double
  opt_out_smart_routing : Bool
  scale_init_level_size : Int
  scale_subs_level_size : Int
  scale_price_increment : Double
  scale_price_adjust_value : Double
  scale_price_adjust_interval : Int
  scale_profit_offset : Double
  scale_auto_reset : Bool
  scale_init_position : Int
  scale_init_fill_qty : Int
  scale_random_percent : Bool
  hedge_type : String
  hedge_param : String
  algo_strategy : String
  algo_params : Array[(String, String)]
  smart_combo_routing_params : Array[(String, String)]
  what_if : Bool
  not_held : Bool
}

///|
pub fn default_order() -> Order {
  {
    order_id: 0,
    client_id: 0,
    action: Buy,
    total_quantity: 0.0,
    order_type: Market,
    lmt_price: 0.0,
    aux_price: 0.0,
    time_in_force: Day,
    oca_group: "",
    oca_type: 0,
    account: "",
    open_close: "O",
    origin: 0,
    transmit: true,
    parent_id: 0,
    block_order: false,
    sweep_to_fill: false,
    display_size: 0,
    trigger_method: 0,
    outside_rth: false,
    hidden: false,
    discretionary_amt: 0.0,
    good_after_time: "",
    good_till_date: "",
    fa_group: "",
    fa_method: "",
    fa_percentage: "",
    all_or_none: false,
    min_qty: 0,
    percent_offset: 0.0,
    eTrade_only: false,
    firm_quote_only: false,
    nbbo_price_cap: 0.0,
    opt_out_smart_routing: false,
    scale_init_level_size: 0,
    scale_subs_level_size: 0,
    scale_price_increment: 0.0,
    scale_price_adjust_value: 0.0,
    scale_price_adjust_interval: 0,
    scale_profit_offset: 0.0,
    scale_auto_reset: false,
    scale_init_position: 0,
    scale_init_fill_qty: 0,
    scale_random_percent: false,
    hedge_type: "",
    hedge_param: "",
    algo_strategy: "",
    algo_params: [],
    smart_combo_routing_params: [],
    what_if: false,
    not_held: false,
  }
}

///|
// Tick types
pub enum TickType {
  BidSize
  BidPrice
  AskPrice
  AskSize
  LastPrice
  LastSize
  High
  Low
  Volume
  Close
  BidOptionComputation
  AskOptionComputation
  LastOptionComputation
  ModelOption
  Open
  Low13Week
  High13Week
  Low26Week
  High26Week
  Low52Week
  High52Week
  AvgVolume
  OpenInterest
  OptionHistoricalVol
  OptionImpliedVol
  OptionBidExch
  OptionAskExch
  OptionCallOpenInterest
  OptionPutOpenInterest
  OptionCallVolume
  OptionPutVolume
  IndexFuturePremium
  BidExch
  AskExch
  AuctionVolume
  AuctionPrice
  AuctionImbalance
  MarkPrice
  BidEFPComputation
  AskEFPComputation
  LastEFPComputation
  OpenEFPComputation
  HighEFPComputation
  LowEFPComputation
  CloseEFPComputation
  LastTimestamp
  Shortable
  FundamentalRatios
  RTVolume
  HALTED
  BidYield
  AskYield
  LastYield
  CustOptionComputation
  TradeCount
  TradeRate
  VolumeRate
  LastRTHTrade
  RT_HistoricalVol
  IBDividends
  BondFactorMultipliers
  RT_TradeVolume
  RT_TradeRate
}

///|
// Tick data
pub struct TickData {
  tick_type : TickType
  price : Double
  size : Int
  timestamp : Int64
}

///|
// Market depth
pub struct MarketDepth {
  position : Int
  market_maker : String
  operation : Int
  side : Int
  price : Double
  size : Double
}

///|
// Order state
pub struct OrderState {
  status : String
  init_margin : String
  maint_margin : String
  equity_with_loan : String
  commission : Double
  min_commission : Double
  max_commission : Double
  commission_currency : String
  warning_text : String
}

///|
// Execution details
pub struct Execution {
  order_id : Int
  client_id : Int
  exec_id : String
  time : String
  account : String
  exchange : String
  side : String
  shares : Double
  price : Double
  perm_id : Int
  client_id_ref : Int
  order_ref : String
  ev_rule : String
  ev_multiplier : Double
  model_code : String
  last_liquidity : Int
}

///|
// Account summary
pub struct AccountSummary {
  account : String
  tag : String
  value : String
  currency : String
}

///|
// Portfolio item
pub struct PortfolioItem {
  account : String
  contract : Contract
  position : Double
  market_price : Double
  market_value : Double
  average_cost : Double
  unrealized_pnl : Double
  realized_pnl : String
  account_name : String
}

///|
// Historical data bar
pub enum BarSize {
  Sec1
  Sec5
  Sec15
  Sec30
  Min1
  Min2
  Min3
  Min5
  Min15
  Min30
  Hour1
  Day1
  Week1
  Month1
  Quarter1
  Year1
}

///|
pub fn bar_size_to_string(bs : BarSize) -> String {
  match bs {
    Sec1 => "1 secs"
    Sec5 => "5 secs"
    Sec15 => "15 secs"
    Sec30 => "30 secs"
    Min1 => "1 min"
    Min2 => "2 mins"
    Min3 => "3 mins"
    Min5 => "5 mins"
    Min15 => "15 mins"
    Min30 => "30 mins"
    Hour1 => "1 hour"
    Day1 => "1 day"
    Week1 => "1 week"
    Month1 => "1 month"
    Quarter1 => "1 quarter"
    Year1 => "1 year"
  }
}

///|
pub enum WhatToShow {
  Trades
  Midpoint
  Bid
  Ask
  BidAsk
  HistoricalVolatility
  OptionImpliedVolatility
  FeeRate
  AggregateVolume
}

///|
pub fn what_to_show_to_string(wts : WhatToShow) -> String {
  match wts {
    Trades => "TRADES"
    Midpoint => "MIDPOINT"
    Bid => "BID"
    Ask => "ASK"
    BidAsk => "BID_ASK"
    HistoricalVolatility => "HISTORICAL_VOLATILITY"
    OptionImpliedVolatility => "OPTION_IMPLIED_VOLATILITY"
    FeeRate => "FEE_RATE"
    AggregateVolume => "AGGREGATE_VOLUME"
  }
}

///|
// Historical data bar
pub struct HistoricalDataBar {
  date : String
  open : Double
  high : Double
  low : Double
  close : Double
  volume : Int
  bar_count : Int
  wap : Double
  has_gaps : Bool
}

///|
// Error codes
pub enum ErrorCode {
  NoError
  Unknown
  ConnectionRefused
  InvalidMessage
  ServerVersionNotSupported
  ClientAlreadyConnected
  ClientNotConnected
  InvalidConnectionId
  Unauthorized
  InvalidSymbol
  InvalidQuantity
  InvalidOrderType
  InvalidPrice
  InvalidTimeInForce
  InvalidExchange
  OrderRejected
  OrderCancelled
  UnknownError(Int)
}

///|
pub fn int_to_error_code(code : Int) -> ErrorCode {
  match code {
    0 => NoError
    502 => ConnectionRefused
    509 => ServerVersionNotSupported
    500 => ClientAlreadyConnected
    501 => ClientNotConnected
    506 => InvalidConnectionId
    507 => Unauthorized
    200 => InvalidSymbol
    201 => InvalidQuantity
    202 => InvalidOrderType
    203 => InvalidPrice
    204 => InvalidTimeInForce
    205 => InvalidExchange
    100 => OrderRejected
    202 => OrderCancelled
    _ => UnknownError(code)
  }
}

///|
pub fn error_code_to_string(ec : ErrorCode) -> String {
  match ec {
    NoError => "No error"
    Unknown => "Unknown error"
    ConnectionRefused => "Connection refused"
    InvalidMessage => "Invalid message"
    ServerVersionNotSupported => "Server version not supported"
    ClientAlreadyConnected => "Client already connected"
    ClientNotConnected => "Client not connected"
    InvalidConnectionId => "Invalid connection ID"
    Unauthorized => "Unauthorized"
    InvalidSymbol => "Invalid symbol"
    InvalidQuantity => "Invalid quantity"
    InvalidOrderType => "Invalid order type"
    InvalidPrice => "Invalid price"
    InvalidTimeInForce => "Invalid time in force"
    InvalidExchange => "Invalid exchange"
    OrderRejected => "Order rejected"
    OrderCancelled => "Order cancelled"
    UnknownError(code) => "Unknown error: " + code.to_string()
  }
}
