require 'logger'
require 'yaml'


namespace :self do
  namespace :setsmart do
    desc 'Scrape stock data from SET-Smart'
    task :scrape => :environment do
      scraper = SETSmartScraper.new(:logger => Logger.new(STDOUT))
      quotes = scraper.scrape('/home/ss/a/dev/db/setsmart.3650days.from20120724')
    end

    # desc 'Save data in a memory to disk'
    # task :persist => :environment do
    #   SETSmartPersistence.new.run
    # end
  end
end

class SETSmartScraper
  def initialize(options={})
    if options[:logger]
      @@logger = options[:logger]
    else
      @@logger = Logger.new(STDOUT)
      @@logger.level = Logger::WARN
    end
  end

  def scrape(root_dir)
    unless Dir.exists? root_dir
      @@logger.error('The directory does not exist.')
      return {}
    end

    begin
      redis = Redis.new
      redis.ping
    rescue
      @@logger.error('Cannot connect to the Redis server.')
      return {}
    end

    Dir.glob("#{root_dir}/*.tmp") do |_file|
      @@logger.debug("Reading... #{File.basename(_file)}")

      File.open(_file) do |f|
        str = f.read
        date = str.match(/(?<date>\d{2}\/\d{2}\/\d{4})\&nbsp;To/)[:date]
        date = Date.strptime(date, '%d/%m/%Y').strftime('%Y%m%d')

        begin
          str_quotes = str.match(/\[\s+(?<q>\[.+\])\s+\]/)[:q].to_s.gsub('],[', ']zz[').split('zz')
          str_quotes.each do |str_quote|
            str_quote.gsub!(/(\,)(\S)/, "\\1 \\2")
            tmp = {}
            values = YAML::load(str_quote)
            keys = [:industry_id, :industry, :symbol, :prior, :open, :high, :low, :close, :change,
              :percent_change, :average, :bid, :offer, :volume, :value, :mktcap, :pe, :pbv, :bvps,
              :dvdyield, :turnover, :shares, :par]
            keys.zip(values) { |k, v| tmp.update(k.to_sym => v) }

            quote = {}
            quote[:date] = date
            quote[:symbol] = tmp[:symbol]
            quote[:open] = tmp[:open].to_f.round(2)
            quote[:high] = tmp[:high].to_f.round(2)
            quote[:low] = tmp[:low].to_f.round(2)
            quote[:close] = tmp[:close].to_f.round(2)
            quote[:change] = tmp[:change].to_f.round(2)
            quote[:percent_change] = tmp[:percent_change].to_f.round(2)
            quote[:volume] = tmp[:volume].to_s.gsub('.', '').to_i * 100
            quote[:value] = tmp[:value].to_s.gsub('.', '').to_i

            # quote[:dvdyield] = quote[:dvdyield].to_f.round(2)
            # quote[:mktcap] = quote[:mktcap].to_f.round(6)
            # quote[:turnover] = quote[:turnover].to_f.round(4)
            # quote[:shares] = quote[:shares].to_f.round(4)
            # quote[:par] = quote[:par].to_f.round(2)
            # quote[:pe] = quote[:pe].to_f < 0 ? 0 : quote[:pe].to_f
            # quote[:pbv] = quote[:pbv].to_f < 0 ? 0 : quote[:pbv].to_f
            # quote[:bvps] = quote[:bvps].to_f < 0 ? 0 : quote[:bvps].to_f
            # quote[:average] = quote[:average].to_f.round(2)

            key = "#{quote[:date]}#{quote[:symbol]}"
            unless redis.exists(key)
              redis.set(key, quote)
              redis.rpush('quote_keys', key)
            end
          end
        rescue
          @@logger.debug("Rescued: #{File.basename(_file)}\n")
        end
      end
    end
    {:length => redis.llen('quote_keys')}
  end

end

# class SETSmartPersistence
#   def initialize
#     @log = Logger.new(STDOUT)
#   end

#   def run
#     persist
#   end

#   def persist
#     redis = Redis.new
#     redis.keys.each do |k|
#       quote = JSON.parse(redis.get(k))
#       quote['date'] = Date.strptime(quote['date'], '%Y%m%d')
#       # Quote.create(quote)
#       @log.debug("Saved: #{k}")
#     end
#   end
# end
