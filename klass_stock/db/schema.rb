# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 119) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: true do |t|
    t.integer "industry_id"
    t.string  "market"
    t.string  "symbol"
    t.string  "name"
    t.string  "name_th"
    t.text    "description"
    t.text    "description_th"
    t.string  "website"
    t.date    "established_at"
  end

  add_index "companies", ["industry_id"], name: "index_companies_on_industry_id", using: :btree
  add_index "companies", ["market"], name: "index_companies_on_market", using: :btree
  add_index "companies", ["symbol"], name: "index_companies_on_symbol", using: :btree

  create_table "deals", force: true do |t|
    t.integer  "portfolio_id"
    t.string   "symbol"
    t.datetime "bought_at"
    t.float    "bought_price"
    t.datetime "sold_at"
    t.float    "sold_price"
    t.integer  "volume"
    t.float    "realized_pl"
    t.float    "percent_pl"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "deals", ["portfolio_id", "created_at"], name: "index_deals_on_portfolio_id_and_created_at", using: :btree
  add_index "deals", ["portfolio_id", "symbol", "created_at"], name: "index_deals_on_portfolio_id_and_symbol_and_created_at", using: :btree
  add_index "deals", ["portfolio_id", "symbol"], name: "index_deals_on_portfolio_id_and_symbol", using: :btree
  add_index "deals", ["portfolio_id"], name: "index_deals_on_portfolio_id", using: :btree
  add_index "deals", ["symbol"], name: "index_deals_on_symbol", using: :btree

  create_table "derivative_warrants", force: true do |t|
    t.integer "company_id"
    t.string  "symbol"
    t.string  "dw_type"
    t.string  "issuer"
    t.date    "trading_date"
    t.date    "last_trading_date"
    t.date    "expiration_date"
    t.boolean "active",            default: true
  end

  add_index "derivative_warrants", ["active"], name: "index_derivative_warrants_on_active", using: :btree
  add_index "derivative_warrants", ["company_id"], name: "index_derivative_warrants_on_company_id", using: :btree
  add_index "derivative_warrants", ["dw_type"], name: "index_derivative_warrants_on_dw_type", using: :btree
  add_index "derivative_warrants", ["issuer"], name: "index_derivative_warrants_on_issuer", using: :btree
  add_index "derivative_warrants", ["symbol"], name: "index_derivative_warrants_on_symbol", using: :btree

  create_table "etfs", force: true do |t|
    t.string  "symbol"
    t.string  "name"
    t.boolean "active", default: true
  end

  add_index "etfs", ["active"], name: "index_etfs_on_active", using: :btree
  add_index "etfs", ["symbol"], name: "index_etfs_on_symbol", using: :btree

  create_table "fraction_trades", force: true do |t|
    t.integer "portfolio_id", default: 1
    t.string  "symbol"
    t.integer "volume",       default: 1000
    t.boolean "f1",           default: false
    t.boolean "f2",           default: false
    t.boolean "f3",           default: false
    t.boolean "f4",           default: false
    t.boolean "f5",           default: false
    t.boolean "f6",           default: false
    t.boolean "f7",           default: false
    t.boolean "f8",           default: false
    t.boolean "f9",           default: false
    t.boolean "f10",          default: false
    t.boolean "active",       default: true
  end

  add_index "fraction_trades", ["active"], name: "index_fraction_trades_on_active", using: :btree
  add_index "fraction_trades", ["portfolio_id", "symbol", "active"], name: "index_fraction_trades_on_portfolio_id_and_symbol_and_active", using: :btree
  add_index "fraction_trades", ["portfolio_id"], name: "index_fraction_trades_on_portfolio_id", using: :btree
  add_index "fraction_trades", ["symbol", "active"], name: "index_fraction_trades_on_symbol_and_active", using: :btree
  add_index "fraction_trades", ["symbol"], name: "index_fraction_trades_on_symbol", using: :btree

  create_table "in_hand_securities", force: true do |t|
    t.integer "portfolio_id"
    t.string  "symbol"
    t.integer "sum_volume",   default: 0
    t.float   "sum_price",    default: 0.0
  end

  add_index "in_hand_securities", ["portfolio_id", "sum_volume"], name: "index_in_hand_securities_on_portfolio_id_and_sum_volume", using: :btree
  add_index "in_hand_securities", ["portfolio_id", "symbol"], name: "index_in_hand_securities_on_portfolio_id_and_symbol", using: :btree
  add_index "in_hand_securities", ["portfolio_id"], name: "index_in_hand_securities_on_portfolio_id", using: :btree
  add_index "in_hand_securities", ["symbol"], name: "index_in_hand_securities_on_symbol", using: :btree

  create_table "industries", force: true do |t|
    t.integer "sector_id"
    t.string  "name"
    t.string  "symbol"
    t.string  "name_th"
  end

  add_index "industries", ["sector_id"], name: "index_industries_on_sector_id", using: :btree

  create_table "intraday_quotes", force: true do |t|
    t.datetime "datetime"
    t.string   "symbol"
    t.float    "last_price"
    t.float    "bid_price"
    t.integer  "bid_volume"
    t.float    "offer_price"
    t.integer  "offer_volume"
  end

  add_index "intraday_quotes", ["symbol", "datetime"], name: "index_intraday_quotes_on_symbol_and_datetime", using: :btree
  add_index "intraday_quotes", ["symbol"], name: "index_intraday_quotes_on_symbol", using: :btree

  create_table "monitored_securities", force: true do |t|
    t.string  "symbol"
    t.date    "last_trading_date"
    t.boolean "s1",                default: false
    t.boolean "s2",                default: false
    t.boolean "s3",                default: false
    t.boolean "active",            default: true
  end

  add_index "monitored_securities", ["active"], name: "index_monitored_securities_on_active", using: :btree
  add_index "monitored_securities", ["s1"], name: "index_monitored_securities_on_s1", using: :btree
  add_index "monitored_securities", ["s2"], name: "index_monitored_securities_on_s2", using: :btree
  add_index "monitored_securities", ["s3"], name: "index_monitored_securities_on_s3", using: :btree
  add_index "monitored_securities", ["symbol"], name: "index_monitored_securities_on_symbol", using: :btree

  create_table "orders", force: true do |t|
    t.integer  "portfolio_id"
    t.string   "symbol"
    t.datetime "datetime"
    t.float    "price"
    t.integer  "volume"
    t.string   "side"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "orders", ["created_at"], name: "index_orders_on_created_at", using: :btree
  add_index "orders", ["datetime"], name: "index_orders_on_datetime", using: :btree
  add_index "orders", ["portfolio_id", "side"], name: "index_orders_on_portfolio_id_and_side", using: :btree
  add_index "orders", ["portfolio_id", "symbol", "side"], name: "index_orders_on_portfolio_id_and_symbol_and_side", using: :btree
  add_index "orders", ["portfolio_id", "symbol"], name: "index_orders_on_portfolio_id_and_symbol", using: :btree
  add_index "orders", ["portfolio_id"], name: "index_orders_on_portfolio_id", using: :btree
  add_index "orders", ["symbol"], name: "index_orders_on_symbol", using: :btree

  create_table "portfolios", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.boolean  "active",     default: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "portfolios", ["user_id", "active"], name: "index_portfolios_on_user_id_and_active", using: :btree
  add_index "portfolios", ["user_id"], name: "index_portfolios_on_user_id", using: :btree

  create_table "pre_orders", force: true do |t|
    t.string  "symbol"
    t.string  "side"
    t.integer "volume"
    t.float   "price"
    t.boolean "active", default: true
  end

  add_index "pre_orders", ["active"], name: "index_pre_orders_on_active", using: :btree

  create_table "quotes", force: true do |t|
    t.date    "date"
    t.string  "symbol"
    t.float   "open"
    t.float   "high"
    t.float   "low"
    t.float   "close"
    t.decimal "volume"
    t.decimal "value"
    t.float   "change"
    t.float   "percent_change"
  end

  add_index "quotes", ["date", "symbol"], name: "index_quotes_on_date_and_symbol", using: :btree
  add_index "quotes", ["date"], name: "index_quotes_on_date", using: :btree
  add_index "quotes", ["symbol"], name: "index_quotes_on_symbol", using: :btree

  create_table "sectors", force: true do |t|
    t.string "name"
    t.string "symbol"
    t.string "name_th"
  end

  create_table "step_trades", force: true do |t|
    t.integer "portfolio_id", default: 1
    t.string  "symbol"
    t.integer "volume",       default: 500
    t.integer "max_step",     default: 100
    t.integer "current_step", default: 0
    t.float   "ref_buy",      default: 0.0
    t.float   "ref_sell",     default: 0.0
    t.boolean "active",       default: true
  end

  add_index "step_trades", ["active"], name: "index_step_trades_on_active", using: :btree
  add_index "step_trades", ["portfolio_id", "symbol", "active"], name: "index_step_trades_on_portfolio_id_and_symbol_and_active", using: :btree
  add_index "step_trades", ["portfolio_id"], name: "index_step_trades_on_portfolio_id", using: :btree
  add_index "step_trades", ["symbol", "active"], name: "index_step_trades_on_symbol_and_active", using: :btree
  add_index "step_trades", ["symbol"], name: "index_step_trades_on_symbol", using: :btree

  create_table "stocks", force: true do |t|
    t.integer "industry_id"
    t.integer "company_id"
    t.string  "symbol"
    t.string  "market"
    t.date    "trading_date"
    t.boolean "active",       default: true
    t.boolean "set50"
    t.boolean "set100"
    t.boolean "sethd"
  end

  add_index "stocks", ["active"], name: "index_stocks_on_active", using: :btree
  add_index "stocks", ["company_id"], name: "index_stocks_on_company_id", using: :btree
  add_index "stocks", ["industry_id"], name: "index_stocks_on_industry_id", using: :btree
  add_index "stocks", ["market"], name: "index_stocks_on_market", using: :btree
  add_index "stocks", ["set100"], name: "index_stocks_on_set100", using: :btree
  add_index "stocks", ["set50"], name: "index_stocks_on_set50", using: :btree
  add_index "stocks", ["sethd"], name: "index_stocks_on_sethd", using: :btree
  add_index "stocks", ["symbol"], name: "index_stocks_on_symbol", using: :btree

  create_table "warrants", force: true do |t|
    t.integer "company_id"
    t.string  "symbol"
    t.float   "exercise_price"
    t.string  "exercise_ratio"
    t.date    "trading_date"
    t.date    "expiration_date"
    t.boolean "active",          default: true
  end

  add_index "warrants", ["active"], name: "index_warrants_on_active", using: :btree
  add_index "warrants", ["company_id"], name: "index_warrants_on_company_id", using: :btree
  add_index "warrants", ["symbol"], name: "index_warrants_on_symbol", using: :btree

  create_table "zone_trades", force: true do |t|
    t.integer "portfolio_id", default: 1
    t.string  "symbol"
    t.integer "volume",       default: 1000
    t.integer "zones",        default: 5
    t.integer "available",    default: 0
    t.float   "ref_buy",      default: 0.0
    t.float   "ref_sell",     default: 0.0
    t.boolean "active",       default: true
  end

  add_index "zone_trades", ["active"], name: "index_zone_trades_on_active", using: :btree
  add_index "zone_trades", ["portfolio_id", "symbol", "active"], name: "index_zone_trades_on_portfolio_id_and_symbol_and_active", using: :btree
  add_index "zone_trades", ["portfolio_id"], name: "index_zone_trades_on_portfolio_id", using: :btree
  add_index "zone_trades", ["symbol", "active"], name: "index_zone_trades_on_symbol_and_active", using: :btree
  add_index "zone_trades", ["symbol"], name: "index_zone_trades_on_symbol", using: :btree

end
