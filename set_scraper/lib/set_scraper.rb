require 'cgi'
require 'date'
require 'logger'
require 'open-uri'

require 'nokogiri'

require_relative './quote_real_time_pricing'


class SETScraper
  def initialize(options={})
    if options[:logger]
      @@logger = options[:logger]
    else
      @@logger = Logger.new(STDOUT)
      @@logger.level = Logger::INFO
    end
    @@language = options[:language] || 'en'
    @@country = options[:country] || 'US'
  end

  def get_stocks(prefixes=[])
    stocks = []
    prefixes = ['NUMBER'].concat(('A'..'Z').to_a) if prefixes.empty?
    prefixes = [prefixes] if prefixes.instance_of?(String)

    threads = []
    prefixes.each do |prefix|
      threads << Thread.new(prefix) do |_prefix|
        url = "http://www.set.or.th/set/commonslookup.do?prefix=#{_prefix}&language=#{@@language}&country=#{@@country}"
        doc = fetch(url)
        rows = doc.xpath('//tr[@class="bggrey1"]/../tr[@valign="top"]') rescue nil
        if rows
          rows.each do |row|
            stocks << {:symbol => row.xpath('./td')[0].text.strip,
                       :company => row.xpath('./td')[1].text.strip,
                       :market => row.xpath('./td')[2].text.strip}
          end
        end
      end
    end
    threads.each { |t| t.join }
    stocks
  end

  def get_warrants
    warrants = []
    url = "http://www.set.or.th/set/warrantslookup.do?language=#{@@language}&country=#{@@country}"
    doc = fetch(url)
    rows = doc.xpath('//tr[@class="bggrey1"]/../tr[@valign="top"]') rescue nil
    if rows
      rows.each do |row|
        warrants << {:symbol => row.xpath('./td')[0].text.strip,
                     :company => row.xpath('./td')[1].text.strip,
                     :market => row.xpath('./td')[2].text.strip}
      end
    end
    warrants
  end

  def get_derivative_warrants
    warrants = []
    url = "http://www.set.or.th/set/othertypeslookup.do?language=#{@@language}&country=#{@@country}"
    doc = fetch(url)
    rows = doc.xpath('//tr[@class="bggrey1"]')[2].xpath('../tr[@valign="top"]') rescue nil
    if rows
      rows.each do |row|
        _tmp = row.xpath('./td')[1].text.gsub(/\s+/, '')
        _tmp = /^(?<dw_type>.+)Warrantson(?<company>.+)issuedby(?<issuer>.+)#/.match(_tmp)
        warrants << {:symbol => row.xpath('./td')[0].text.strip,
                     :dw_type => _tmp[:dw_type].downcase,
                     :company => _tmp[:company],
                     :issuer => _tmp[:issuer]}
      end
    end
    warrants
  end

  def get_etfs
    etfs = []
    url = "http://www.set.or.th/set/othertypeslookup.do?language=#{@@language}&country=#{@@country}"
    doc = fetch(url)
    rows = doc.xpath('//tr[@class="bggrey1"]')[1].xpath('../tr[@valign="top"]') rescue nil
    if rows
      rows.each do |row|
        etfs << {:symbol => row.xpath('./td')[0].text.strip, :name => row.xpath('./td')[1].text.strip}
      end
    end
    etfs
  end

  def get_statement(symbol, statement)
    return {} unless %w{ balance income cashflow }.include?(statement)
    stmt_items = {}
    url = "http://www.set.or.th/set/companyfinance.do?type=#{statement}&symbol=#{CGI.escape(symbol)}&language=#{@@language}&country=#{@@country}"
    doc = fetch(url)
    meta_table = doc.xpath('//table[@class="bodytext"]/../table')[2] rescue nil
    if meta_table
      meta_table.xpath('.//table').each do |tb|
        [tb.xpath('./tr')[2], tb.xpath('./tr')[4]].each do |row|
          k = row.xpath('./td')[0].text
          v = row.xpath('./td')[1].text.gsub(/\s+/, ' ')
          if k.empty?
            k = 'File'
            v = row.xpath('./td')[1].xpath('./a/@href').text
          end
          stmt_items.update(k => v)
        end
      end
    end

    rows = doc.xpath('//table[@class="bodytext"]')[0].xpath('./tr') rescue nil
    if rows
      rows[4..-1].each do |row|
        if row.xpath('./td')[1]
          k = row.xpath('./td')[1].text.strip.gsub(/^[[:space:]]+/, '')
          v = row.xpath('./td')[2].text.strip.gsub(',', '').to_f rescue nil
          stmt_items.update(k => v) unless v.nil?
        end
      end
    end
    stmt_items
  end

  def get_real_time_price(symbol, all_data=false, security_type=nil)
    url = "http://marketdata.set.or.th/mkt/stockquotation.do?symbol=#{CGI.escape(symbol)}&language=#{@@language}&country=#{@@country}"
    doc = fetch(url)
    begin
      quote = QuoteRealTimePricing.new(doc)
      quote.scrape(all_data, security_type)
      quote.instance_variables.inject({}) { |hash, var|
        hash[var[1..-1].to_sym] = quote.instance_variable_get(var)
        hash
      }
    rescue
      {}
    end
  end

  def get_historical_prices(symbol, page=0)
    prices = []
    url = "http://www.set.or.th/set/historicaltrading.do?symbol=#{CGI.escape(symbol)}&page=#{page}&language=#{@@language}&country=#{@@country}&type=trading"
    doc = fetch(url)
    rows = doc.xpath('//tr[@class="bggrey1"]/../tr[@align="right"]') rescue nil
    if rows
      rows.each do |row|
        date = row.xpath('./td')[0].text.strip
        date = Date.strptime(date, '%d/%m/%Y').strftime('%Y%m%d')
        open = row.xpath('./td')[1].text.strip.to_f
        high = row.xpath('./td')[2].text.strip.to_f
        low = row.xpath('./td')[3].text.strip.to_f
        close = row.xpath('./td')[4].text.strip.to_f
        change = row.xpath('./td')[5].text.strip.to_f
        percent_change = row.xpath('./td')[6].text.strip.to_f
        volume = row.xpath('./td')[7].text.strip.gsub(',', '').to_i
        value = row.xpath('./td')[8].text.strip.gsub(/[,\.]/, '').to_i * 10

        prices << {
          :date => date,
          :symbol => symbol,
          :open => open,
          :high => high,
          :low => low,
          :close => close,
          :change => change,
          :percent_change => percent_change,
          :volume => volume,
          :value => value
        } if open > 0
      end
      has_next_page = !(/icon-next\.gif/.match(doc.to_s).nil?)
      prices << {:has_next_page? => has_next_page}
    end
    prices
  end

  def get_index_stocks(index)
    index.upcase!
    return [] unless %w{ SET50 SET100 SETHD }.include?(index)

    symbols = []
    url = "http://marketdata.set.or.th/mkt/sectorquotation.do?sector=#{index}&langauge=#{@@language}&country=#{@@country}"
    doc = fetch(url)
    rows = doc.xpath('//td[@class="yellowline"]')[1].xpath('../../tr') rescue nil
    if rows
      _rows = []
      rows[5..-1].each_with_index { |row, idx| _rows << row if idx.even? }
      _rows.each do |row|
        symbols << row.xpath('./td')[0].text.strip
      end
    end
    symbols
  end

  private

  def fetch(url)
    begin
      @@logger.debug("Fetching... #{url}\n")
      user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:32.0) Gecko/20100101 Firefox/32.0"
      if @@language == 'th'
        doc = Nokogiri::HTML(open(url, "User-Agent" => user_agent), nil, 'tis-620')
      else
        doc = Nokogiri::HTML(open(url, "User-Agent" => user_agent))
      end
      doc
    rescue
      nil
    end
  end

end
