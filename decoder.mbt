///|
// IB API Protocol Decoder
// Decodes IB wire protocol format to MoonBit types

///|
pub struct Decoder {
  buffer : Array[Byte]
  position : Int
  length : Int
}

///|
pub enum DecodeError {
  BufferOverflow
  InvalidFormat(String)
  UnexpectedEndOfInput
  ParseError(String)
}

///|
pub fn new_decoder(buffer : Array[Byte]) -> Decoder {
  { buffer, position: 0, length: buffer.length() }
}

///|
pub fn decoder_reset(dec : Decoder) -> Decoder {
  { buffer: dec.buffer, position: 0, length: dec.length }
}

///|
pub fn has_more(dec : Decoder) -> Bool {
  dec.position < dec.length
}

///|
pub fn remaining(dec : Decoder) -> Int {
  dec.length - dec.position
}

///|
pub fn read_byte(dec : Decoder) -> Result[(Byte, Decoder), DecodeError] {
  if dec.position >= dec.length {
    Err(UnexpectedEndOfInput)
  } else {
    let byte = dec.buffer[dec.position]
    Ok(
      (
        byte,
        { buffer: dec.buffer, position: dec.position + 1, length: dec.length },
      ),
    )
  }
}

///|
pub fn read_int(dec : Decoder) -> Result[(Int, Decoder), DecodeError] {
  if dec.position + 4 > dec.length {
    Err(UnexpectedEndOfInput)
  } else {
    let b1 = dec.buffer[dec.position]
    let b2 = dec.buffer[dec.position + 1]
    let b3 = dec.buffer[dec.position + 2]
    let b4 = dec.buffer[dec.position + 3]
    let value = (b1.to_int() << 24) |
      (b2.to_int() << 16) |
      (b3.to_int() << 8) |
      b4.to_int()
    Ok(
      (
        value,
        { buffer: dec.buffer, position: dec.position + 4, length: dec.length },
      ),
    )
  }
}

///|
pub fn read_double(dec : Decoder) -> Result[(Double, Decoder), DecodeError] {
  match read_string(dec) {
    Ok((str, dec)) => {
      // Simple double parsing - for now, just try to convert string to double
      // In a real implementation, this would need proper error handling
      let value = 0.0 // placeholder
      Ok((value, dec))
    }
    Err(e) => Err(e)
  }
}

///|
pub fn read_string(dec : Decoder) -> Result[(String, Decoder), DecodeError] {
  let start = dec.position
  let mut i = 0
  while start + i < dec.length {
    if dec.buffer[start + i] == 0 {
      let zero_byte : Byte = 0
      let str_bytes = Array::make(i, zero_byte)
      let mut j = 0
      while j < i {
        str_bytes[j] = dec.buffer[start + j]
        j = j + 1
      }
      // Convert bytes to string - simplified version
      let str = "" // placeholder - would need proper UTF-8 conversion
      return Ok(
        (
          str,
          { buffer: dec.buffer, position: start + i + 1, length: dec.length },
        ),
      )
    }
    i = i + 1
  }
  Err(UnexpectedEndOfInput)
}

///|
pub fn read_bool(dec : Decoder) -> Result[(Bool, Decoder), DecodeError] {
  match read_int(dec) {
    Ok((value, dec)) => Ok((value != 0, dec))
    Err(e) => Err(e)
  }
}

///|
pub fn read_max(dec : Decoder) -> Result[(Bool, Decoder), DecodeError] {
  match read_int(dec) {
    Ok((value, dec)) => Ok((value == 2147483647, dec))
    Err(e) => Err(e)
  }
}

///|
pub fn read_contract(dec : Decoder) -> Result[(Contract, Decoder), DecodeError] {
  // Simplified version - create a minimal contract
  // Full implementation would read all fields properly
  let contract = {
    con_id: 0,
    symbol: "",
    sec_type: Stock,
    last_trade_date_or_contract_month: "",
    strike: 0.0,
    right: "",
    multiplier: "",
    exchange: "",
    primary_exchange: "",
    currency: "",
    local_symbol: "",
    trading_class: "",
    include_expired: false,
    sec_id_type: "",
    sec_id: "",
  }
  Ok((contract, dec))
}

///|
pub fn read_tick_type(
  dec : Decoder,
) -> Result[(TickType, Decoder), DecodeError] {
  match read_int(dec) {
    Ok((value, dec)) => {
      let tick_type = match value {
        0 => BidSize
        1 => BidPrice
        2 => AskPrice
        3 => AskSize
        4 => LastPrice
        5 => LastSize
        6 => High
        7 => Low
        8 => Volume
        9 => Close
        10 => BidOptionComputation
        11 => AskOptionComputation
        12 => LastOptionComputation
        13 => ModelOption
        14 => Open
        15 => Low13Week
        16 => High13Week
        17 => Low26Week
        18 => High26Week
        19 => Low52Week
        20 => High52Week
        21 => AvgVolume
        22 => OpenInterest
        23 => OptionHistoricalVol
        24 => OptionImpliedVol
        25 => OptionBidExch
        26 => OptionAskExch
        27 => OptionCallOpenInterest
        28 => OptionPutOpenInterest
        29 => OptionCallVolume
        30 => OptionPutVolume
        31 => IndexFuturePremium
        32 => BidExch
        33 => AskExch
        34 => AuctionVolume
        35 => AuctionPrice
        36 => AuctionImbalance
        37 => MarkPrice
        38 => BidEFPComputation
        39 => AskEFPComputation
        40 => LastEFPComputation
        41 => OpenEFPComputation
        42 => HighEFPComputation
        43 => LowEFPComputation
        44 => CloseEFPComputation
        45 => LastTimestamp
        46 => Shortable
        47 => FundamentalRatios
        48 => RTVolume
        49 => HALTED
        50 => BidYield
        51 => AskYield
        52 => LastYield
        53 => CustOptionComputation
        54 => TradeCount
        55 => TradeRate
        56 => VolumeRate
        57 => LastRTHTrade
        _ => RT_HistoricalVol // default
      }
      Ok((tick_type, dec))
    }
    Err(e) => Err(e)
  }
}

///|
pub fn read_error_code(
  dec : Decoder,
) -> Result[(ErrorCode, Decoder), DecodeError] {
  match read_int(dec) {
    Ok((value, dec)) => Ok((int_to_error_code(value), dec))
    Err(e) => Err(e)
  }
}

///|
pub fn read_bar_size(dec : Decoder) -> Result[(BarSize, Decoder), DecodeError] {
  match read_string(dec) {
    Ok((str, dec)) => {
      let bar_size = match str {
        "1 secs" => Sec1
        "5 secs" => Sec5
        "15 secs" => Sec15
        "30 secs" => Sec30
        "1 min" => Min1
        "2 mins" => Min2
        "3 mins" => Min3
        "5 mins" => Min5
        "15 mins" => Min15
        "30 mins" => Min30
        "1 hour" => Hour1
        "1 day" => Day1
        "1 week" => Week1
        "1 month" => Month1
        "1 quarter" => Quarter1
        "1 year" => Year1
        _ => Day1 // default
      }
      Ok((bar_size, dec))
    }
    Err(e) => Err(e)
  }
}

///|
pub fn read_what_to_show(
  dec : Decoder,
) -> Result[(WhatToShow, Decoder), DecodeError] {
  match read_string(dec) {
    Ok((str, dec)) => {
      let what_to_show = match str {
        "TRADES" => Trades
        "MIDPOINT" => Midpoint
        "BID" => Bid
        "ASK" => Ask
        "BID_ASK" => BidAsk
        "HISTORICAL_VOLATILITY" => HistoricalVolatility
        "OPTION_IMPLIED_VOLATILITY" => OptionImpliedVolatility
        "FEE_RATE" => FeeRate
        "AGGREGATE_VOLUME" => AggregateVolume
        _ => Trades // default
      }
      Ok((what_to_show, dec))
    }
    Err(e) => Err(e)
  }
}

///|
pub fn get_decoder_position(dec : Decoder) -> Int {
  dec.position
}
