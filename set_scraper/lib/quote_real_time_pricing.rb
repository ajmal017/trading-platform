class QuoteRealTimePricing
  def initialize(doc)
    tables = doc.xpath('//tr[@class="yellowline"]/../../table')
    @@table1_rows = tables[0].xpath('./tr')
    @@table2_rows = tables[1].xpath('./tr')
    @@table3_rows = tables[2].xpath('./tr')
    @@table4_rows = tables[3].xpath('./tr') rescue nil
  end

  def scrape(all_data=false, security_type=nil)
    if all_data
      get_bid_price
      get_bid_volume
      get_offer_price
      get_offer_volume
      get_last_update
      get_market_status
      get_last
      get_change
      get_percent_change
      get_prior
      get_open
      get_high
      get_low
      get_volume
      get_value
      get_average_price
      get_par
      get_ceiling
      get_floor
      if security_type == 'w' || security_type == 'dw'
        get_expiration_date(security_type)
      end
    else
      get_bid_price
      get_bid_volume
      get_offer_price
      get_offer_volume
      get_last_update
      get_market_status
      get_last
    end
  end

  def get_bid_price
    _tmp = @@table1_rows[3].xpath('./td')[1].text.split('/')
    @bid_price = _tmp[0].strip.to_f
  end

  def get_bid_volume
    _tmp = @@table1_rows[3].xpath('./td')[1].text.split('/')
    @bid_volume = _tmp[1].gsub(',', '').gsub(/\W+/, '').to_i
  end

  def get_offer_price
    _tmp = @@table1_rows[5].xpath('./td')[1].text.split('/')
    @offer_price = _tmp[0].strip.to_f
  end

  def get_offer_volume
    _tmp = @@table1_rows[5].xpath('./td')[1].text.split('/')
    @offer_volume = _tmp[1].gsub(',', '').gsub(/\W+/, '').to_i
  end

  def get_last_update
    _tmp = @@table2_rows[0].xpath('./td').text
    @last_update = /Last Update (?<last_update>.+)/.match(_tmp)[:last_update].strip
    @last_update = DateTime.strptime(@last_update, '%d %b %Y %H:%M:%S')
  end

  def get_market_status
    _tmp = @@table2_rows[0].xpath('./td').text
    @market_status = /Market Status : (?<market_status>.+)/.match(_tmp)[:market_status].strip
  end

  def get_last
    @last = @@table2_rows[7].xpath('./td')[1].text.strip.to_f
  end

  def get_change
    @change = @@table2_rows[9].xpath('./td')[1].text.strip.to_f
  end

  def get_percent_change
    @percent_change = @@table2_rows[11].xpath('./td')[1].text.strip.to_f
  end

  def get_prior
    @prior = @@table2_rows[13].xpath('./td')[1].text.strip.to_f
  end

  def get_open
    @open = @@table2_rows[15].xpath('./td')[1].text.strip.to_f
  end

  def get_high
    @high = @@table2_rows[17].xpath('./td')[1].text.strip.to_f
  end

  def get_low
    @low = @@table2_rows[19].xpath('./td')[1].text.strip.to_f
  end

  def get_volume
    @volume = @@table2_rows[21].xpath('./td')[1].text.strip.gsub(',', '').to_i
  end

  def get_value
    @value = @@table2_rows[23].xpath('./td')[1].text.strip.gsub(',', '').to_i * 1000
  end

  def get_average_price
    @average_price = @@table2_rows[25].xpath('./td')[1].text.strip.to_f
  end

  def get_par
    @par = @@table3_rows[3].xpath('./td')[1].text.strip
    @par = @par == '-' ? '-' : @par.to_f
  end

  def get_ceiling
    @ceiling = @@table3_rows[5].xpath('./td')[1].text.strip.to_f
  end

  def get_floor
    @floor = @@table3_rows[7].xpath('./td')[1].text.strip.to_f
  end

  def get_expiration_date(stype)
    if @@table4_rows
      if stype == 'w'
        @exercise_price = @@table4_rows[3].xpath('./td')[1].text.strip.to_f
        @exercise_ratio = @@table4_rows[5].xpath('./td')[1].text.strip.gsub(/\s/, '')
        @expiration_date = @@table4_rows[7].xpath('./td')[1].text.strip
        @expiration_date = Date.strptime(@expiration_date, '%d/%m/%Y')
      elsif stype == 'dw'
        @last_trading_date = @@table4_rows[3].xpath('./td')[1].text.strip
        @last_trading_date = Date.strptime(@last_trading_date, '%d/%m/%Y')
        @expiration_date = @@table4_rows[5].xpath('./td')[1].text.strip
        @expiration_date = Date.strptime(@expiration_date, '%d/%m/%Y')
      end
    end
  end
end
