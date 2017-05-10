namespace :self do
  namespace :set do
    desc "Download companies summary"
    task :download_summary => [:environment] do
      SETCompanySummaryDownloader.new.run
    end

    desc "Extract companies summary"
    task :extract_summary => [:environment] do
      SETCompanySummaryExtractor.new.run
    end

    desc "Download companies statements"
    task :download_statements, [:quarter] => [:environment] do |t, args|
      args.with_defaults(:quarter => 'tmp')
      SETStatementDownloader.new(args.quarter).run
    end

    desc "Collect statements vocabularies"
    task :collect_vocabulary => [:environment] do
      StatementVocabularyCollector.new.run
    end

    desc "Update Companies"
    task :update_companies => [:environment] do
      Routine.new.update_companies
    end

    desc "Pull Stocks"
    task :pull_stocks => [:environment] do
      Routine.new.pull_stocks
    end

    desc "Pull Warrants"
    task :pull_warrants => [:environment] do
      Routine.new.pull_warrants
    end

    desc "Pull Derivative Warrants"
    task :pull_derivative_warrants => [:environment] do
      Routine.new.pull_derivative_warrants
    end

    desc "Pull ETFs"
    task :pull_etfs => [:environment] do
      Routine.new.pull_etfs
    end

    desc "Pull historical prices"
    task :pull_historical_prices => [:environment] do
      Routine.new.pull_historical_prices
    end

    desc "Pull intraday prices of monitored securities"
    task :pull_intraday_prices => [:environment] do
      Routine.new.pull_intraday_prices
    end

    desc "Pull index stocks"
    task :pull_index_stocks => [:environment] do
      Routine.new.pull_index_stocks
    end
  end
end


class SETCompanySummaryDownloader
  def initialize
    @logger = Logger.new(STDOUT)
  end

  # def run
  #   companies = []
  #   Company.all.each { |company| companies << company }

  #   threads = []
  #   companies.each do |company|
  #     threads << Thread.new(company) do |c|
  #       download(c, 'en', 'US')
  #       download(c, 'th', 'TH')
  #     end
  #   end
  #   threads.each { |t| t.join }
  # end

  def run
    companies = []
    Company.all.each { |company| companies << company }

    companies.each do |company|
      download(company, 'en', 'US')
      download(company, 'th', 'TH')
    end
  end

  def download(company, language='en', country='US')
    root_dir = File.join(Rails.root, 'db', 'seeds', 'set_summaries')
    Dir.mkdir root_dir unless Dir.exists? root_dir

    last_month = Time.now - 1.month
    year_dir = File.join(root_dir, last_month.year.to_s)
    Dir.mkdir year_dir unless Dir.exists? year_dir

    month_dir = File.join(year_dir, last_month.month.to_s)
    Dir.mkdir month_dir unless Dir.exists? month_dir

    lang_dir = File.join(month_dir, language)
    Dir.mkdir lang_dir unless Dir.exists? lang_dir

    company_file = File.join(lang_dir, "#{company.symbol}.html")
    unless File.exists?(company_file) && File.size(company_file) > 0
      url = "http://www.set.or.th/set/factsheet.do?symbol=#{CGI.escape(company.symbol)}&language=#{language}&country=#{country}"
      @logger.debug("#{company.symbol} (#{language}): fetching...")
      user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:32.0) Gecko/20100101 Firefox/32.0"
      open(company_file, 'w') { |file| file << open(url, "User-Agent" => user_agent).read }
      @logger.debug("#{company.symbol} (#{language}): saved\n")
    end
  end
end


class SETCompanySummaryExtractor
  attr_accessor :doc, :industries

  def initialize
    @logger = Logger.new(STDOUT)

    @industries = {'Medium-Sized Enterprise' => 0}
    Industry.all.each { |obj| @industries.update(obj.name => obj.id) }
  end

  def run
    Company.all.each do |company|
      if true
        read(company)
        _industry_id = get_industry
        company.industry_id = _industry_id
        Stock.where(symbol: company.symbol).update_all(industry_id: _industry_id)

        read(company, 'th')
        company.name_th = get_name
      else
        read(company)
        company.industry_id = get_industry
        _desc = get_description
        _skip_desc = (_desc =~ /^Effective/) == 0 ? true : false
        company.description = _desc unless _skip_desc
        company.website = get_website
        company.established_at = get_established_date

        read(company, 'th')
        company.name_th = get_name
        company.description_th = get_description unless _skip_desc
      end
      company.save
    end
  end

  def fetch(company, language='en', country='US')
    url = "http://www.set.or.th/set/factsheet.do?symbol=#{CGI.escape(company.symbol)}&language=#{language}&country=#{country}"
    @logger.debug("#{company.symbol}: fetching...")
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:32.0) Gecko/20100101 Firefox/32.0"
    if language == 'th'
      @doc = Nokogiri::HTML(open(url, "User-Agent" => user_agent), nil, 'tis-620')
    else
      @doc = Nokogiri::HTML(open(url, "User-Agent" => user_agent))
    end
  end

  def read(company, language='en')
    @logger.debug("#{company.symbol} (#{language}): reading...")

    last_month = Time.now - 1.month
    root_dir = File.join(Rails.root, 'db', 'seeds', 'set_summaries')
    year_dir = File.join(root_dir, last_month.year.to_s)
    month_dir = File.join(year_dir, last_month.month.to_s)
    lang_dir = File.join(month_dir, language)
    company_file = File.join(lang_dir, "#{company.symbol}.html")
    if File.exists? company_file
      @logger.debug(">>> #{company.symbol} (#{language}): reading...")
      if language == 'th'
        @doc = Nokogiri::HTML(File.open(company_file), nil, 'utf-8')
      else
        @doc = Nokogiri::HTML(File.open(company_file))
      end
    end
  end

  def get_name
    @doc.xpath('//td[@class="factsheet-heading2"]')[0].text.strip
  end

  def get_industry
    _doc = @doc.xpath('//td[@class="factsheet-noline"]')[0]
    industry = (_doc.nil? ? '' : _doc.text.split('/').last)
    industry_id = nil
    if industries.keys.include? industry
      industry_id = industries[industry]
      @logger.debug("get industry - succeeded")
    else
      if industry == 'Companies Under Rehabilitation'
        @logger.debug("get industry - failed - Companies Under Rehabilitation")
        industry_id = -1
      else
        @logger.debug("get industry - failed - Not Found")
        industry_id = -2
      end
    end
    industry_id
  end

  def get_description
    @logger.debug("get description")
    table = @doc.xpath('//table[@class="factsheet"]')
    case table.length
    when 18, 20, 21, 22
      _doc = table[2].xpath('.//td[@class="factsheet"]')
    when 23
      _doc = table[3].xpath('.//td[@class="factsheet"]')
    else
      _doc = nil
    end
    _doc.nil? ? nil : _doc.text.strip
  end

  def get_website
    @logger.debug("get website")
    website = ''
    (6..10).each do |row|
      if @doc.xpath('//table[@class="factsheet"]')[1].xpath("./tr[#{row}]/td[1]").text == 'URL'
        website = @doc.xpath('//table[@class="factsheet"]')[1].xpath("./tr[#{row}]/td[2]/a").text
        break
      end
    end
    website = website.downcase.strip.gsub('http://', '')
    website.empty? ? nil : website
  end

  def get_established_date
    @logger.debug("get established date")
    _doc = ''
    (7..11).each do |row|
      if @doc.xpath('//table[@class="factsheet"]')[1].xpath("./tr[#{row}]/td[1]").text == 'Establish Date'
        _doc = @doc.xpath('//table[@class="factsheet"]')[1].xpath("./tr[#{row}]/td[2]")
        break
      end
    end
    return nil if _doc.empty?

    case _doc.text.length
    when 1
      nil
    when 4
      Date.strptime(_doc.text, '%Y')
    when 6, 7
      Date.strptime(_doc.text, '%m/%Y')
    else
      if _doc.text.split('/').first == '00'
        Date.strptime(_doc.text.split('/').last, '%Y')
      else
        Date.strptime(_doc.text, '%d/%m/%Y')
      end
    end
  end

  def get_listed_date
    @logger.debug("get listed date")
    if @doc.xpath('//table[@class="factsheet"]')[1].xpath('./tr[7]/td[1]').text == 'Establish Date'
      _doc = @doc.xpath('//table[@class="factsheet"]')[1].xpath('./tr[7]/td[4]')
    elsif @doc.xpath('//table[@class="factsheet"]')[1].xpath('./tr[8]/td[1]').text == 'Establish Date'
      _doc = @doc.xpath('//table[@class="factsheet"]')[1].xpath('./tr[8]/td[4]')
    end
    Date.strptime(_doc.text, '%d %b %Y')
  end
end


class SETStatementDownloader
  attr_accessor :quarter

  def initialize(quarter)
    @logger = Logger.new(STDOUT)
    @quarter = quarter
  end

  # def run
  #   threads = []
  #   Company.all.each do |_company|
  #     threads << Thread.new(_company) do |company|
  #       download(company, quarter)
  #       sleep(10)
  #     end
  #   end
  #   threads.each { |t| t.join }
  # end

  def run
    Company.all.each do |company|
      download(company, quarter)
    end
  end

  def download(company, quarter)
    root_dir = File.join(Rails.root, 'db', 'seeds', 'set_statements')
    Dir.mkdir root_dir unless Dir.exists? root_dir

    quarter_dir = File.join(root_dir, quarter)
    Dir.mkdir quarter_dir unless Dir.exists? quarter_dir

    %w{ highlight balance income cashflow }.each do |smt_type|
      statement_dir = File.join(quarter_dir, smt_type)
      Dir.mkdir statement_dir unless Dir.exists? statement_dir

      company_file = File.join(statement_dir, "#{company.symbol}.html")
      unless File.exists?(company_file) && File.size(company_file) > 0
        if smt_type == 'highlight'
          url = "http://www.set.or.th/set/companyhighlight.do?symbol=#{CGI.escape(company.symbol)}&language=en&country=US"
        else
          url = "http://www.set.or.th/set/companyfinance.do?type=#{smt_type}&symbol=#{CGI.escape(company.symbol)}&language=en&country=US"
        end
        @logger.debug("#{company.symbol} (#{smt_type}): fetching...")

        user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:32.0) Gecko/20100101 Firefox/32.0"
        open(company_file, 'w') { |file| file << open(url, "User-Agent" => user_agent).read }
        @logger.debug("#{company.symbol} (#{smt_type}): saved\n")
      end
    end
  end
end


class StatementVocabularyCollector
  attr_accessor :doc, :redis

  def initialize
    @logger = Logger.new(STDOUT)
    @redis = Redis.new
  end

  def run
    threads = []
    Company.offset(0).limit(50).each do |_company|
      %w{ balance income cashflow }.each do |_smt_type|
        threads << Thread.new(_company, _smt_type) do |company, smt_type|
          read(company, smt_type)
          keys = collect

          fetch(company, smt_type, 'th', 'TH')
          values = collect

          keys.each_with_index do |k, idx|
            unless redis.get(k)
              redis.set(keys[idx], values[idx])
              @logger.debug "#{keys[idx]} <=> #{values[idx]}"
            end
          end
        end
      end
    end
    threads.each { |t| t.join }
  end

  def read(company, smt_type, language='en')
    root_dir = File.join(Rails.root, 'db', 'seeds', 'set_statements')
    quarter_dir = File.join(root_dir, '2012_3')
    statement_dir = File.join(quarter_dir, smt_type)
    company_file = File.join(statement_dir, "#{company.symbol}.html")
    if File.exists? company_file
      @logger.debug(">>> #{company.symbol} (#{language}): reading...")
      if language == 'th'
        @doc = Nokogiri::HTML(File.open(company_file), nil, 'utf-8')
      else
        @doc = Nokogiri::HTML(File.open(company_file))
      end
    end
  end

  def fetch(company, smt_type, language='en', country='US')
    url = "http://www.set.or.th/set/companyfinance.do?type=#{smt_type}&symbol=#{CGI.escape(company.symbol)}&language=#{language}&country=#{country}"
    @logger.debug("#{company.symbol} (#{smt_type} / #{language}): fetching...")
    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.9; rv:32.0) Gecko/20100101 Firefox/32.0"
    if language == 'th'
      @doc = Nokogiri::HTML(open(url, "User-Agent" => user_agent), nil, 'tis-620')
    else
      @doc = Nokogiri::HTML(open(url, "User-Agent" => user_agent))
    end
  end

  def collect
    vocabs = []
    _doc = @doc.xpath('//table[@class="bodytext"]/tr')
    _doc.each do |tr|
      text = tr.xpath('./td')[1].text rescue ''
      vocabs << text.strip.gsub(/^[[:space:]]+/, '') unless text.empty?
    end
    vocabs
  end
end


class Routine
  def initialize
    @logger = Logger.new(STDOUT)
  end

  def update_companies
    SETScraper.new.get_stocks.each do |stock|
      company = Company.where(:symbol => stock[:symbol]).first
      if company
        changed = false
        if company.name != stock[:company]
          company.name = stock[:company]
          changed = true
        end
        if company.market != stock[:market]
          company.market = stock[:market]
          changed = true
        end
        company.save if changed
      end
    end

    SETScraper.new({:language => 'th', :country => 'TH'}).get_stocks.each do |stock|
      company = Company.where(:symbol => stock[:symbol]).first
      if company && company.name_th != stock[:company]
        company.name_th = stock[:company]
        company.save
      end
    end
  end

  def pull_stocks
    stocks1 = Stock.active
    stocks2 = SETScraper.new.get_stocks

    _stocks1, _stocks2 = [], []
    stocks1.each { |s| _stocks1 << s[:symbol] }
    stocks2.each { |s| _stocks2 << s[:symbol] }
    added_stocks = _stocks2 - _stocks1
    removed_stocks = _stocks1 - _stocks2

    if added_stocks.size == 0 && removed_stocks.size == 0
      @logger.info('Stocks are up-to-date.')
      return
    end

    added_stocks.sort.each do |stock|
      stock = stocks2.find { |s| s[:symbol] == stock }
      company = Company.where(:name => stock[:company]).first
      if company
        @logger.info("\nThe company has changed their symbol from '#{company.symbol}' to '#{stock[:symbol]}'\n")

        Stock.where(:symbol => company.symbol).update_all(:symbol => stock[:symbol])

        company.symbol = stock[:symbol]
        company.save
      else
        company = Company.where(:symbol => stock[:symbol]).first
        if company
          @logger.info("\nThe company has changed their name\n from '#{company.name}'\n to '#{stock[:company]}'\n")
          company.name = stock[:company]
          company.save
        else
          company = Company.create(:symbol => stock[:symbol], :name => stock[:company], :market => stock[:market])
          Stock.create(:company_id => company.id, :symbol => stock[:symbol], :market => stock[:market])
          @logger.debug("Added #{stock[:symbol]}")
        end
      end
    end

    removed_stocks.each do |stock|
      company = Stock.where(:symbol => stock).first.company
      if company
        stock2 = stocks2.find { |s| s[:company] == company.name }
        unless stock2
          Stock.where(:symbol => stock, :active => true).update_all(:active => false)
          @logger.debug("Removed #{stock}")
        end
      end
    end
  end

  def pull_warrants
    warrants1 = Warrant.active
    warrants2 = SETScraper.new.get_warrants

    _warrants1, _warrants2 = [], []
    warrants1.each { |w| _warrants1 << w[:symbol] }
    warrants2.each { |w| _warrants2 << w[:symbol] }
    added_warrants = _warrants2 - _warrants1
    removed_warrants = _warrants1 - _warrants2

    if added_warrants.size == 0 && removed_warrants.size == 0
      @logger.info('Warrants are up-to-date.')
      return
    end

    added_warrants.each do |w|
      symbol = w.split('-')[0..-2].join('-')
      company = Company.where(:symbol => symbol).first
      if company
        Warrant.create(:company_id => company.id, :symbol => w)
        @logger.debug("Added #{w}")
      else
        @logger.info("Can't add #{w}, the company might change their symbol.")
      end
    end

    removed_warrants.each do |w|
      symbol = w.split('-')[0..-2].join('-')
      company = Company.where(:symbol => symbol).first
      if company
        Warrant.where(:symbol => w).first.update_attributes(:active => false)
        @logger.debug("Removed #{w}")
      else
        @logger.info("Can't remove #{w}, the company might change their symbol.")
      end
    end
  end

  def pull_derivative_warrants
    warrants1 = DerivativeWarrant.active
    warrants2 = SETScraper.new.get_derivative_warrants

    _warrants1, _warrants2 = [], []
    warrants1.each { |w| _warrants1 << w[:symbol] }
    warrants2.each { |w| _warrants2 << w[:symbol] }
    added_warrants = _warrants2 - _warrants1
    removed_warrants = _warrants1 - _warrants2

    if added_warrants.size == 0 && removed_warrants.size == 0
      @logger.info('DWs are up-to-date.')
      return
    end

    added_warrants.each do |w|
      w = warrants2.find { |_w| _w[:symbol] == w }
      company = Company.where(:symbol => w[:company]).first
      if company
        DerivativeWarrant.create(:company_id => company.id, :symbol => w[:symbol],
                                 :dw_type => w[:dw_type], :issuer => w[:issuer])
        @logger.debug("Added #{w[:symbol]}")
      else
        @logger.info("Can't add #{w[:symbol]}, the company might change their symbol.")
      end
    end

    removed_warrants.each do |w|
      w = warrants1.find { |_w| _w.symbol == w }
      company = Company.find(w.company_id) rescue nil
      if company
        DerivativeWarrant.where(:symbol => w.symbol).first.update_attributes(:active => false)
        @logger.debug("Removed #{w.symbol}")
      else
        @logger.info("Can't remove #{w.symbol}, the company might change their symbol.")
      end
    end
  end

  def pull_etfs
    etfs1 = ETF.active
    etfs2 = SETScraper.new.get_etfs

    _etfs1, _etfs2 = [], []
    etfs1.each { |e| _etfs1 << e[:symbol] }
    etfs2.each { |e| _etfs2 << e[:symbol] }
    added_etfs = _etfs2 - _etfs1
    removed_etfs = _etfs1 - _etfs2

    if added_etfs.size == 0 && removed_etfs.size == 0
      @logger.info('ETFs are up-to-date.')
      return
    end

    added_etfs.each do |e|
      e = etfs2.find { |_e| _e[:symbol] == e }
      ETF.create(:symbol => e[:symbol], :name => e[:name])
      @logger.debug("Added #{e[:symbol]}")
    end

    removed_etfs.each do |e|
      e= etfs1.find { |_e| _e.symbol == e }
      ETF.where(:symbol => e.symbol).first.update_attributes(:active => false)
      @logger.debug("Removed #{e.symbol}")
    end
  end

  def pull_historical_prices
    (Stock.active + DerivativeWarrant.active + ETF.active).each do |quote|
      page = 0
      while true
        up_to_date = false
        prices = SETScraper.new.get_historical_prices(quote[:symbol], page)
        prices[0..-2].each do |price|
          if Quote.where(:date => price[:date], :symbol => price[:symbol]).first
            up_to_date = true
            break
          else
            Quote.create(price)
            @logger.debug("Saved: #{price[:date]} | #{price[:symbol]}")
          end
        end
        break if up_to_date || !prices.last[:has_next_page?]
        page = page + 1
      end
    end
  end

  def pull_intraday_prices
    now = Time.now.utc + 7.hours
    hour = now.hour
    min = now.min
    return unless !(now.saturday? || now.sunday?) &&
                  (hour == 9 && min >= 55) || hour == 10 || hour == 11 || (hour == 12 && min <= 30) ||
                  (hour == 14 && min >= 25) || hour == 15 || (hour == 16 && min <= 30)

    MonitoredSecurity.active.each do |s|
      sleep 1
      price = SETScraper.new.get_real_time_price(s.symbol)
      if price[:last] && price[:last] > 0 && price[:market_status] =~ /^Open.*/
        @logger.debug price[:last_update]
        IntradayQuote.create(:symbol => s.symbol, :datetime => price[:last_update],
                              :last_price => price[:last], :bid_price => price[:bid_price],
                              :bid_volume => price[:bid_volume], :offer_price => price[:offer_price],
                              :offer_volume => price[:offer_volume])
      end
    end

    # now = Time.now - 10.hours
    # 400.times do
    #   price = rand(7.0..9.0).round(2)
    #   IntradayQuote.create(:symbol => 'TRUE', :datetime => now, :price => price)
    #   now += 1.minute
    # end
  end

  def pull_index_stocks
    set50_stocks = Stock.set50.map { |s| s.symbol }
    set100_stocks = Stock.set100.map { |s| s.symbol }
    sethd_stocks = Stock.sethd.map { |s| s.symbol }

    %w{ SET50 SET100 SETHD }.each do |index|
      index_stocks = SETScraper.new.get_index_stocks(index)

      case index
      when 'SET50'
        added_stocks = index_stocks - set50_stocks
        removed_stocks = set50_stocks - index_stocks
      when 'SET100'
        added_stocks = index_stocks - set100_stocks
        removed_stocks = set100_stocks - index_stocks
      when 'SETHD'
        added_stocks = index_stocks - sethd_stocks
        removed_stocks = sethd_stocks - index_stocks
      end

      added_stocks.each do |symbol|
        stock = Stock.where(:symbol => symbol).first
        if stock
          case index
          when 'SET50'
            stock.set50 = true
            stock.save
            @logger.debug("Add #{symbol} to SET50")
          when 'SET100'
            stock.set100 = true
            stock.save
            @logger.debug("Add #{symbol} to SET100")
          when 'SETHD'
            stock.sethd = true
            stock.save
            @logger.debug("Add #{symbol} to SETHD")
          end
        end
      end

      removed_stocks.each do |symbol|
        stock = Stock.where(:symbol => symbol).first
        if stock
          case index
          when 'SET50'
            stock.set50 = false
            stock.save
            @logger.debug("Remove #{symbol} from SET50")
          when 'SET100'
            stock.set100 = false
            stock.save
            @logger.debug("Remove #{symbol} from SET100")
          when 'SETHD'
            stock.sethd = false
            stock.save
            @logger.debug("Remove #{symbol} from SETHD")
          end
        end
      end

    end
  end
end
