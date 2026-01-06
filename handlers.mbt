///|
// IB API Message Handlers
// Processes incoming messages from TWS/Gateway and invokes callbacks

///|
pub struct HandlerResult {
  consumed_bytes : Int
  processed : Bool
}

///|
// Parse and handle a single message
pub fn handle_message(
  buffer : Array[Byte],
  client : Client,
) -> Result[(Client, Int), String] {
  let dec = new_decoder(buffer)

  // Read message type ID
  match read_int(dec) {
    Ok((msg_id, dec)) => {
      // Handle based on message type
      let (client, consumed) = match msg_id {
        1 => handle_tick_price(dec, client)
        2 => handle_tick_size(dec, client)
        4 => handle_tick_generic(dec, client)
        5 => handle_tick_string(dec, client)
        6 => handle_tick_efp(dec, client)
        8 => handle_tick_snapshot_end(dec, client)
        9 => handle_market_data_type(dec, client)
        12 => handle_tick_option_computation(dec, client)
        45 => handle_tick_by_tick(dec, client)
        46 => handle_tick_req_params(dec, client)
        47 => handle_tick_news(dec, client)
        3 => handle_order_status(dec, client)
        5 => handle_open_order(dec, client)
        9 => handle_execution_detail(dec, client)
        10 => handle_commission_report(dec, client)
        4 => handle_error(dec, client)
        6 => handle_current_time(dec, client)
        7 => handle_account_value(dec, client)
        8 => handle_portfolio_value(dec, client)
        9 => handle_account_update_time(dec, client)
        10 => handle_account_download_end(dec, client)
        11 => handle_next_valid_id(dec, client)
        14 => handle_contract_data(dec, client)
        15 => handle_managed_accounts(dec, client)
        17 => handle_contract_data_end(dec, client)
        18 => handle_open_order_end(dec, client)
        19 => handle_account_download_end(dec, client)
        20 => handle_execution_detail_end(dec, client)
        49 => handle_tick_option_computation(dec, client)
        50 => handle_tick_generic(dec, client)
        51 => handle_tick_string(dec, client)
        52 => handle_tick_efp(dec, client)
        54 => handle_market_data_type(dec, client)
        55 => handle_tick_snapshot_end(dec, client)
        56 => handle_tick_by_tick(dec, client)
        57 => handle_tick_req_params(dec, client)
        58 => handle_tick_news(dec, client)
        61 => handle_position(dec, client)
        62 => handle_position_end(dec, client)
        63 => handle_account_summary(dec, client)
        64 => handle_account_summary_end(dec, client)
        65 => handle_position_multi(dec, client)
        66 => handle_position_multi_end(dec, client)
        67 => handle_account_update_multi(dec, client)
        68 => handle_account_update_multi_end(dec, client)
        69 => handle_security_definition_option_parameter(dec, client)
        70 => handle_security_definition_option_parameter_end(dec, client)
        71 => handle_soft_dollar_tiers(dec, client)
        72 => handle_family_codes(dec, client)
        73 => handle_symbol_samples(dec, client)
        74 => handle_market_depth_exchanges(dec, client)
        75 => handle_tick_req_params(dec, client)
        76 => handle_smart_components(dec, client)
        77 => handle_news_article(dec, client)
        78 => handle_tick_news(dec, client)
        79 => handle_news_providers(dec, client)
        80 => handle_historical_news(dec, client)
        81 => handle_historical_news_end(dec, client)
        82 => handle_head_timestamp(dec, client)
        83 => handle_histogram_data(dec, client)
        84 => handle_historical_data_update(dec, client)
        85 => handle_reroute_market_data(dec, client)
        86 => handle_reroute_market_depth(dec, client)
        87 => handle_market_rule(dec, client)
        88 => handle_pnl(dec, client)
        89 => handle_pnl_single(dec, client)
        90 => handle_historical_ticks(dec, client)
        91 => handle_historical_ticks_bid_ask(dec, client)
        92 => handle_historical_ticks_last(dec, client)
        93 => handle_tick_by_tick(dec, client)
        94 => handle_order_bound(dec, client)
        95 => handle_completed_order(dec, client)
        96 => handle_completed_orders_end(dec, client)
        97 => handle_replace_fa_end(dec, client)
        98 => handle_wsh_meta_data(dec, client)
        99 => handle_wsh_event_data(dec, client)
        100 => handle_user_info(dec, client)
        _ => handle_unknown_message(msg_id, dec, client)
      }
      Ok((client, consumed))
    }
    Err(e) => Err("Failed to read message ID")
  }
}

///|
// Handle TickPrice message (message ID 1)
pub fn handle_tick_price(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_tick_type(dec) {
        Ok((tick_type, dec)) =>
          match read_double(dec) {
            Ok((price, dec)) =>
              match read_int(dec) {
                Ok((size, dec)) =>
                  match read_int(dec) {
                    Ok((can_auto_execute, dec)) => {
                      // Invoke callback if set
                      match client.on_tick_price {
                        Some(callback) =>
                          callback(req_id, tick_type, price, size.to_int64())
                        None => ()
                      }
                      let consumed = get_decoder_position(dec)
                      (client, consumed)
                    }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickSize message (message ID 2)
pub fn handle_tick_size(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_tick_type(dec) {
        Ok((tick_type, dec)) =>
          match read_int(dec) {
            Ok((size, dec)) => {
              // Invoke callback if set
              match client.on_tick_size {
                Some(callback) => callback(req_id, tick_type, size)
                None => ()
              }
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickGeneric message (message ID 4)
pub fn handle_tick_generic(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_tick_type(dec) {
        Ok((tick_type, dec)) =>
          match read_double(dec) {
            Ok((value, dec)) => {
              // For now, treat generic ticks like price ticks
              match client.on_tick_price {
                Some(callback) => callback(req_id, tick_type, value, 0L)
                None => ()
              }
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickString message (message ID 5)
pub fn handle_tick_string(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_tick_type(dec) {
        Ok((tick_type, dec)) =>
          match read_string(dec) {
            Ok((value, dec)) => {
              // For string ticks, we could parse the value if it's numeric
              // For now, just consume the message
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickEFP message (message ID 6)
pub fn handle_tick_efp(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_tick_type(dec) {
        Ok((tick_type, dec)) =>
          match read_double(dec) {
            Ok((basis_points, dec)) =>
              match read_string(dec) {
                Ok((formatted_basis_points, dec)) =>
                  match read_double(dec) {
                    Ok((implied_future, dec)) =>
                      match read_int(dec) {
                        Ok((hold_days, dec)) =>
                          match read_string(dec) {
                            Ok((future_last_trade_date, dec)) =>
                              match read_double(dec) {
                                Ok((dividend_impact, dec)) =>
                                  match read_double(dec) {
                                    Ok((dividends_to_expiration, dec)) => {
                                      let consumed = get_decoder_position(dec)
                                      (client, consumed)
                                    }
                                    Err(_) => (client, 0)
                                  }
                                Err(_) => (client, 0)
                              }
                            Err(_) => (client, 0)
                          }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickSnapshotEnd message (message ID 8)
pub fn handle_tick_snapshot_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle MarketDataType message (message ID 9)
pub fn handle_market_data_type(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((market_data_type, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickOptionComputation message (message ID 12)
pub fn handle_tick_option_computation(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_tick_type(dec) {
        Ok((tick_type, dec)) =>
          match read_int(dec) {
            Ok((model_price, dec)) =>
              match read_double(dec) {
                Ok((implied_volatility, dec)) => {
                  let consumed = get_decoder_position(dec)
                  (client, consumed)
                }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickByTick message (message ID 45)
pub fn handle_tick_by_tick(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((tick_type, dec)) =>
          match read_int(dec) {
            Ok((time, dec)) => {
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickReqParams message (message ID 46)
pub fn handle_tick_req_params(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_double(dec) {
        Ok((min_tick, dec)) =>
          match read_string(dec) {
            Ok((bbo_exchange, dec)) =>
              match read_int(dec) {
                Ok((snapshot_permissions, dec)) => {
                  let consumed = get_decoder_position(dec)
                  (client, consumed)
                }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle TickNews message (message ID 47)
pub fn handle_tick_news(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((time_stamp, dec)) =>
          match read_string(dec) {
            Ok((provider_code, dec)) =>
              match read_string(dec) {
                Ok((article_id, dec)) =>
                  match read_string(dec) {
                    Ok((headline, dec)) =>
                      match read_string(dec) {
                        Ok((extra_data, dec)) => {
                          let consumed = get_decoder_position(dec)
                          (client, consumed)
                        }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle OrderStatus message (message ID 3)
pub fn handle_order_status(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((order_id, dec)) =>
      match read_string(dec) {
        Ok((status, dec)) =>
          match read_double(dec) {
            Ok((filled, dec)) =>
              match read_double(dec) {
                Ok((remaining, dec)) =>
                  match read_double(dec) {
                    Ok((avg_fill_price, dec)) =>
                      match read_int(dec) {
                        Ok((perm_id, dec)) =>
                          match read_int(dec) {
                            Ok((parent_id, dec)) =>
                              match read_double(dec) {
                                Ok((last_fill_price, dec)) =>
                                  match read_int(dec) {
                                    Ok((client_id, dec)) =>
                                      match read_string(dec) {
                                        Ok((why_held, dec)) =>
                                          match read_double(dec) {
                                            Ok((mkt_cap_price, dec)) => {
                                              // Invoke callback if set
                                              match client.on_order_status {
                                                Some(callback) =>
                                                  callback(
                                                    order_id, status, filled, remaining,
                                                    avg_fill_price, perm_id, parent_id,
                                                    last_fill_price, client_id, why_held,
                                                  )
                                                None => ()
                                              }
                                              let consumed = get_decoder_position(
                                                dec,
                                              )
                                              (client, consumed)
                                            }
                                            Err(_) => (client, 0)
                                          }
                                        Err(_) => (client, 0)
                                      }
                                    Err(_) => (client, 0)
                                  }
                                Err(_) => (client, 0)
                              }
                            Err(_) => (client, 0)
                          }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle OpenOrder message (message ID 5)
pub fn handle_open_order(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((order_id, dec)) =>
      match read_contract(dec) {
        Ok((contract, dec)) => {
          // Simplified - would read full order and order state
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle ExecutionDetail message (message ID 9)
pub fn handle_execution_detail(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((order_id, dec)) =>
          match read_contract(dec) {
            Ok((contract, dec)) => {
              // Simplified - would read full execution details
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle CommissionReport message (message ID 10)
pub fn handle_commission_report(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_string(dec) {
    Ok((exec_id, dec)) =>
      match read_double(dec) {
        Ok((commission, dec)) =>
          match read_string(dec) {
            Ok((currency, dec)) =>
              match read_int(dec) {
                Ok((realized_pnl, dec)) =>
                  match read_string(dec) {
                    Ok((yield_name, dec)) =>
                      match read_int(dec) {
                        Ok((yield_price, dec)) => {
                          let consumed = get_decoder_position(dec)
                          (client, consumed)
                        }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle Error message (message ID 4)
pub fn handle_error(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((error_code, dec)) =>
      match read_int(dec) {
        Ok((req_id, dec)) =>
          match read_string(dec) {
            Ok((error_msg, dec)) => {
              // Convert error code to ErrorCode enum
              let code = int_to_error_code(error_code)
              // Invoke callback if set
              match client.on_error {
                Some(callback) => callback(code, error_msg)
                None => ()
              }
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle CurrentTime message (message ID 6)
pub fn handle_current_time(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((time, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle AccountValue message (message ID 7)
pub fn handle_account_value(dec : Decoder, client : Client) -> (Client, Int) {
  match read_string(dec) {
    Ok((key, dec)) =>
      match read_string(dec) {
        Ok((value, dec)) =>
          match read_string(dec) {
            Ok((currency, dec)) =>
              match read_string(dec) {
                Ok((account_name, dec)) => {
                  let consumed = get_decoder_position(dec)
                  (client, consumed)
                }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle PortfolioValue message (message ID 8)
pub fn handle_portfolio_value(dec : Decoder, client : Client) -> (Client, Int) {
  match read_contract(dec) {
    Ok((contract, dec)) =>
      match read_double(dec) {
        Ok((position, dec)) =>
          match read_double(dec) {
            Ok((market_price, dec)) =>
              match read_double(dec) {
                Ok((market_value, dec)) =>
                  match read_double(dec) {
                    Ok((average_cost, dec)) =>
                      match read_double(dec) {
                        Ok((unrealized_pnl, dec)) =>
                          match read_double(dec) {
                            Ok((realized_pnl, dec)) =>
                              match read_string(dec) {
                                Ok((account_name, dec)) => {
                                  let consumed = get_decoder_position(dec)
                                  (client, consumed)
                                }
                                Err(_) => (client, 0)
                              }
                            Err(_) => (client, 0)
                          }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle AccountUpdateTime message (message ID 9)
pub fn handle_account_update_time(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_string(dec) {
    Ok((timestamp, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle AccountDownloadEnd message (message ID 10)
pub fn handle_account_download_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_string(dec) {
    Ok((account_name, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle NextValidId message (message ID 11)
pub fn handle_next_valid_id(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((order_id, dec)) => {
      let new_client = {
        config: client.config,
        state: client.state,
        socket: client.socket,
        server_version: client.server_version,
        connection_time: client.connection_time,
        next_order_id: order_id,
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
      let consumed = get_decoder_position(dec)
      (new_client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle ManagedAccts message (message ID 15)
pub fn handle_managed_accounts(dec : Decoder, client : Client) -> (Client, Int) {
  match read_string(dec) {
    Ok((accounts_list, dec)) => {
      // Invoke callback if set
      match client.on_managed_accounts {
        Some(callback) => callback(accounts_list)
        None => ()
      }
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle ContractData message (message ID 14)
pub fn handle_contract_data(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_contract(dec) {
        Ok((contract, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle ContractDataEnd message (message ID 17)
pub fn handle_contract_data_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle OpenOrderEnd message (message ID 18)
pub fn handle_open_order_end(dec : Decoder, client : Client) -> (Client, Int) {
  let consumed = get_decoder_position(dec)
  (client, consumed)
}

///|
// Handle ExecutionDetailEnd message (message ID 20)
pub fn handle_execution_detail_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle Position message (message ID 61)
pub fn handle_position(dec : Decoder, client : Client) -> (Client, Int) {
  match read_string(dec) {
    Ok((account, dec)) =>
      match read_contract(dec) {
        Ok((contract, dec)) =>
          match read_double(dec) {
            Ok((pos, dec)) =>
              match read_double(dec) {
                Ok((avg_cost, dec)) => {
                  // Invoke callback if set
                  match client.on_position {
                    Some(callback) => callback(account, contract, pos, avg_cost)
                    None => ()
                  }
                  let consumed = get_decoder_position(dec)
                  (client, consumed)
                }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle PositionEnd message (message ID 62)
pub fn handle_position_end(dec : Decoder, client : Client) -> (Client, Int) {
  let consumed = get_decoder_position(dec)
  (client, consumed)
}

///|
// Handle AccountSummary message (message ID 63)
pub fn handle_account_summary(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((account, dec)) =>
          match read_string(dec) {
            Ok((tag, dec)) =>
              match read_string(dec) {
                Ok((value, dec)) =>
                  match read_string(dec) {
                    Ok((currency, dec)) => {
                      // Invoke callback if set
                      match client.on_account_summary {
                        Some(callback) =>
                          callback(req_id, account, tag, value, currency)
                        None => ()
                      }
                      let consumed = get_decoder_position(dec)
                      (client, consumed)
                    }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle AccountSummaryEnd message (message ID 64)
pub fn handle_account_summary_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle PositionMulti message (message ID 65)
pub fn handle_position_multi(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((account, dec)) =>
          match read_string(dec) {
            Ok((model_code, dec)) =>
              match read_contract(dec) {
                Ok((contract, dec)) =>
                  match read_double(dec) {
                    Ok((pos, dec)) =>
                      match read_double(dec) {
                        Ok((avg_cost, dec)) => {
                          let consumed = get_decoder_position(dec)
                          (client, consumed)
                        }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle PositionMultiEnd message (message ID 66)
pub fn handle_position_multi_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle AccountUpdateMulti message (message ID 67)
pub fn handle_account_update_multi(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((account, dec)) =>
          match read_string(dec) {
            Ok((model_code, dec)) =>
              match read_string(dec) {
                Ok((key, dec)) =>
                  match read_string(dec) {
                    Ok((value, dec)) =>
                      match read_string(dec) {
                        Ok((currency, dec)) => {
                          let consumed = get_decoder_position(dec)
                          (client, consumed)
                        }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle AccountUpdateMultiEnd message (message ID 68)
pub fn handle_account_update_multi_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle SecurityDefinitionOptionParameter message (message ID 69)
pub fn handle_security_definition_option_parameter(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((exchange, dec)) =>
          match read_int(dec) {
            Ok((underlying_con_id, dec)) =>
              match read_string(dec) {
                Ok((trading_class, dec)) =>
                  match read_string(dec) {
                    Ok((multiplier, dec)) =>
                      match read_string(dec) {
                        Ok((expirations, dec)) =>
                          match read_string(dec) {
                            Ok((strikes, dec)) => {
                              let consumed = get_decoder_position(dec)
                              (client, consumed)
                            }
                            Err(_) => (client, 0)
                          }
                        Err(_) => (client, 0)
                      }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle SecurityDefinitionOptionParameterEnd message (message ID 70)
pub fn handle_security_definition_option_parameter_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle SoftDollarTiers message (message ID 71)
pub fn handle_soft_dollar_tiers(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((n_tiers, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle FamilyCodes message (message ID 72)
pub fn handle_family_codes(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((n_codes, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle SymbolSamples message (message ID 73)
pub fn handle_symbol_samples(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((n_samples, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle MarketDepthExchanges message (message ID 74)
pub fn handle_market_depth_exchanges(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((n_exchanges, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle SmartComponents message (message ID 76)
pub fn handle_smart_components(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((n_components, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle NewsArticle message (message ID 77)
pub fn handle_news_article(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((article_type, dec)) =>
          match read_string(dec) {
            Ok((article_id, dec)) => {
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle NewsProviders message (message ID 79)
pub fn handle_news_providers(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((n_providers, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle HistoricalNews message (message ID 80)
pub fn handle_historical_news(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((time, dec)) =>
          match read_string(dec) {
            Ok((provider_code, dec)) =>
              match read_int(dec) {
                Ok((article_id, dec)) =>
                  match read_string(dec) {
                    Ok((headline, dec)) => {
                      let consumed = get_decoder_position(dec)
                      (client, consumed)
                    }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle HistoricalNewsEnd message (message ID 81)
pub fn handle_historical_news_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_bool(dec) {
        Ok((has_more, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle HeadTimestamp message (message ID 82)
pub fn handle_head_timestamp(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((head_timestamp, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle HistogramData message (message ID 83)
pub fn handle_histogram_data(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) => {
      // Simplified version - just consume the histogram data
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle HistoricalDataUpdate message (message ID 84)
pub fn handle_historical_data_update(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((bar_count, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle RerouteMktDataReq message (message ID 85)
pub fn handle_reroute_market_data(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((con_id, dec)) =>
          match read_string(dec) {
            Ok((exchange, dec)) => {
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle RerouteMktDepthReq message (message ID 86)
pub fn handle_reroute_market_depth(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((con_id, dec)) =>
          match read_string(dec) {
            Ok((exchange, dec)) => {
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle MarketRule message (message ID 87)
pub fn handle_market_rule(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((market_rule_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle PnL message (message ID 88)
pub fn handle_pnl(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_double(dec) {
        Ok((daily_pnl, dec)) =>
          match read_double(dec) {
            Ok((unrealized_pnl, dec)) =>
              match read_double(dec) {
                Ok((realized_pnl, dec)) => {
                  let consumed = get_decoder_position(dec)
                  (client, consumed)
                }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle PnLSingle message (message ID 89)
pub fn handle_pnl_single(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((pos, dec)) =>
          match read_double(dec) {
            Ok((daily_pnl, dec)) =>
              match read_double(dec) {
                Ok((unrealized_pnl, dec)) =>
                  match read_double(dec) {
                    Ok((realized_pnl, dec)) => {
                      let consumed = get_decoder_position(dec)
                      (client, consumed)
                    }
                    Err(_) => (client, 0)
                  }
                Err(_) => (client, 0)
              }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle HistoricalTicks message (message ID 90)
pub fn handle_historical_ticks(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((tick_count, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle HistoricalTicksBidAsk message (message ID 91)
pub fn handle_historical_ticks_bid_ask(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((tick_count, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle HistoricalTicksLast message (message ID 92)
pub fn handle_historical_ticks_last(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_int(dec) {
        Ok((tick_count, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle OrderBound message (message ID 94)
pub fn handle_order_bound(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((order_id, dec)) =>
      match read_int(dec) {
        Ok((api_client_id, dec)) =>
          match read_int(dec) {
            Ok((api_order_id, dec)) => {
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle CompletedOrder message (message ID 95)
pub fn handle_completed_order(dec : Decoder, client : Client) -> (Client, Int) {
  match read_contract(dec) {
    Ok((contract, dec)) =>
      match read_int(dec) {
        Ok((order_id, dec)) =>
          match read_int(dec) {
            Ok((order_type, dec)) => {
              let consumed = get_decoder_position(dec)
              (client, consumed)
            }
            Err(_) => (client, 0)
          }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle CompletedOrdersEnd message (message ID 96)
pub fn handle_completed_orders_end(
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  let consumed = get_decoder_position(dec)
  (client, consumed)
}

///|
// Handle ReplaceFAEnd message (message ID 97)
pub fn handle_replace_fa_end(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((text, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle WshMetaData message (message ID 98)
pub fn handle_wsh_meta_data(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((data_json, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle WshEventData message (message ID 99)
pub fn handle_wsh_event_data(dec : Decoder, client : Client) -> (Client, Int) {
  match read_int(dec) {
    Ok((req_id, dec)) =>
      match read_string(dec) {
        Ok((data_json, dec)) => {
          let consumed = get_decoder_position(dec)
          (client, consumed)
        }
        Err(_) => (client, 0)
      }
    Err(_) => (client, 0)
  }
}

///|
// Handle UserInfo message (message ID 100)
pub fn handle_user_info(dec : Decoder, client : Client) -> (Client, Int) {
  match read_string(dec) {
    Ok((white_branding_id, dec)) => {
      let consumed = get_decoder_position(dec)
      (client, consumed)
    }
    Err(_) => (client, 0)
  }
}

///|
// Handle unknown message type
pub fn handle_unknown_message(
  msg_id : Int,
  dec : Decoder,
  client : Client,
) -> (Client, Int) {
  // Log unknown message type
  // For now, just skip the message
  let consumed = get_decoder_position(dec)
  (client, consumed)
}
