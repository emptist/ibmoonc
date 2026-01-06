///|
// IB API Protocol Encoder
// Encodes MoonBit types to IB wire protocol format

///|
pub struct Encoder {
  buffer : Array[Byte]
  position : Int
}

///|
pub fn new_encoder(initial_capacity : Int) -> Encoder {
  let zero_byte : Byte = 0
  { buffer: Array::make(initial_capacity, zero_byte), position: 0 }
}

///|
pub fn reset(enc : Encoder) -> Encoder {
  { buffer: enc.buffer, position: 0 }
}

///|
pub fn ensure_capacity(enc : Encoder, required : Int) -> Encoder {
  if enc.buffer.length() - enc.position < required {
    let new_capacity = (enc.buffer.length() * 2).max(enc.position + required)
    let zero_byte : Byte = 0
    let new_buffer = Array::make(new_capacity, zero_byte)
    let mut i = 0
    while i < enc.position {
      new_buffer[i] = enc.buffer[i]
      i = i + 1
    }
    { buffer: new_buffer, position: enc.position }
  } else {
    enc
  }
}

///|
pub fn write_byte(enc : Encoder, value : Byte) -> Encoder {
  let enc = ensure_capacity(enc, 1)
  enc.buffer[enc.position] = value
  { buffer: enc.buffer, position: enc.position + 1 }
}

///|
pub fn write_int(enc : Encoder, value : Int) -> Encoder {
  let enc = ensure_capacity(enc, 4)
  enc.buffer[enc.position] = (value >> 24).to_byte()
  enc.buffer[enc.position + 1] = (value >> 16).to_byte()
  enc.buffer[enc.position + 2] = (value >> 8).to_byte()
  enc.buffer[enc.position + 3] = value.to_byte()
  { buffer: enc.buffer, position: enc.position + 4 }
}

///|
pub fn write_double(enc : Encoder, value : Double) -> Encoder {
  // Write double as string with null terminator
  let str = value.to_string()
  let enc = ensure_capacity(enc, str.length() + 1)
  let mut i = 0
  while i < str.length() {
    enc.buffer[enc.position + i] = str[i].to_byte()
    i = i + 1
  }
  let zero_byte : Byte = 0
  enc.buffer[enc.position + str.length()] = zero_byte // null terminator
  { buffer: enc.buffer, position: enc.position + str.length() + 1 }
}

///|
pub fn write_string(enc : Encoder, value : String) -> Encoder {
  if value == "" {
    let zero_byte : Byte = 0
    write_byte(enc, zero_byte) // empty string is just null terminator
  } else {
    let enc = ensure_capacity(enc, value.length() + 1)
    let mut i = 0
    while i < value.length() {
      enc.buffer[enc.position + i] = value[i].to_byte()
      i = i + 1
    }
    let zero_byte : Byte = 0
    enc.buffer[enc.position + value.length()] = zero_byte // null terminator
    { buffer: enc.buffer, position: enc.position + value.length() + 1 }
  }
}

///|
pub fn write_bool(enc : Encoder, value : Bool) -> Encoder {
  if value {
    write_int(enc, 1)
  } else {
    write_int(enc, 0)
  }
}

///|
pub fn write_max(enc : Encoder) -> Encoder {
  write_int(enc, 2147483647) // INT_MAX
}

///|
pub fn write_contract(enc : Encoder, contract : Contract) -> Encoder {
  let enc = write_int(enc, contract.con_id)
  let enc = write_string(enc, contract.symbol)
  let enc = write_string(enc, sec_type_to_string(contract.sec_type))
  let enc = write_string(enc, contract.last_trade_date_or_contract_month)
  let enc = write_double(enc, contract.strike)
  let enc = write_string(enc, contract.right)
  let enc = write_string(enc, contract.multiplier)
  let enc = write_string(enc, contract.exchange)
  let enc = write_string(enc, contract.primary_exchange)
  let enc = write_string(enc, contract.currency)
  let enc = write_string(enc, contract.local_symbol)
  let enc = write_string(enc, contract.trading_class)
  let enc = write_bool(enc, contract.include_expired)
  let enc = write_string(enc, contract.sec_id_type)
  write_string(enc, contract.sec_id)
}

///|
pub fn write_order(enc : Encoder, order : Order) -> Encoder {
  let enc = write_int(enc, order.order_id)
  let enc = write_int(enc, order.client_id)
  let enc = write_int(enc, 1) // action (1 = BUY, 2 = SELL)
  let enc = write_int(enc, order.total_quantity.to_int())
  let enc = write_string(enc, order_type_to_string(order.order_type))
  let enc = write_double(enc, order.lmt_price)
  let enc = write_double(enc, order.aux_price)
  let enc = write_string(enc, time_in_force_to_string(order.time_in_force))
  let enc = write_string(enc, order.oca_group)
  let enc = write_int(enc, order.oca_type)
  let enc = write_string(enc, order.account)
  let enc = write_string(enc, order.open_close)
  let enc = write_int(enc, order.origin)
  let enc = write_bool(enc, order.transmit)
  let enc = write_int(enc, order.parent_id)
  let enc = write_bool(enc, order.block_order)
  let enc = write_bool(enc, order.sweep_to_fill)
  let enc = write_int(enc, order.display_size)
  let enc = write_int(enc, order.trigger_method)
  let enc = write_bool(enc, order.outside_rth)
  let enc = write_bool(enc, order.hidden)
  let enc = write_double(enc, order.discretionary_amt)
  let enc = write_string(enc, order.good_after_time)
  let enc = write_string(enc, order.good_till_date)
  let enc = write_string(enc, order.fa_group)
  let enc = write_string(enc, order.fa_method)
  let enc = write_string(enc, order.fa_percentage)
  let enc = write_bool(enc, order.all_or_none)
  let enc = write_int(enc, order.min_qty)
  let enc = write_double(enc, order.percent_offset)
  let enc = write_bool(enc, order.eTrade_only)
  let enc = write_bool(enc, order.firm_quote_only)
  let enc = write_double(enc, order.nbbo_price_cap)
  let enc = write_bool(enc, order.opt_out_smart_routing)
  let enc = write_int(enc, order.scale_init_level_size)
  let enc = write_int(enc, order.scale_subs_level_size)
  let enc = write_double(enc, order.scale_price_increment)
  let enc = write_double(enc, order.scale_price_adjust_value)
  let enc = write_int(enc, order.scale_price_adjust_interval)
  let enc = write_double(enc, order.scale_profit_offset)
  let enc = write_bool(enc, order.scale_auto_reset)
  let enc = write_int(enc, order.scale_init_position)
  let enc = write_int(enc, order.scale_init_fill_qty)
  let enc = write_bool(enc, order.scale_random_percent)
  let enc = write_string(enc, order.hedge_type)
  let enc = write_string(enc, order.hedge_param)
  let enc = write_string(enc, order.algo_strategy)
  let enc = write_int(enc, order.algo_params.length())
  let mut i = 0
  while i < order.algo_params.length() {
    let (key, value) = order.algo_params[i]
    let enc = write_string(enc, key)
    let enc = write_string(enc, value)
    i = i + 1
  }
  let enc = write_int(enc, order.smart_combo_routing_params.length())
  let mut j = 0
  while j < order.smart_combo_routing_params.length() {
    let (key, value) = order.smart_combo_routing_params[j]
    let enc = write_string(enc, key)
    let enc = write_string(enc, value)
    j = j + 1
  }
  let enc = write_bool(enc, order.what_if)
  write_bool(enc, order.not_held)
}

///|
pub fn get_bytes(enc : Encoder) -> Array[Byte] {
  let zero_byte : Byte = 0
  let result = Array::make(enc.position, zero_byte)
  let mut i = 0
  while i < enc.position {
    result[i] = enc.buffer[i]
    i = i + 1
  }
  result
}

///|
pub fn get_position(enc : Encoder) -> Int {
  enc.position
}
