require 'cgi'
require 'open-uri'

require 'nokogiri'
require 'turn/autorun'

require_relative '../lib/quote_real_time_pricing'


describe QuoteRealTimePricing do
  before do
    symbol = 'TRUE'
    url = "http://marketdata.set.or.th/mkt/stockquotation.do?symbol=#{CGI.escape(symbol)}&language=en&country=US"
    doc = Nokogiri::HTML(open(url))
    @quote = QuoteRealTimePricing.new(doc)
  end

  # describe "#scrape" do
  #   it "works" do
  #     @quote.scrape(true, false)
  #     puts @quote.instance_variables.inject({}) { |hash, var|
  #       hash[var[1..-1].to_sym] = @quote.instance_variable_get(var)
  #       hash
  #     }
  #   end
  # end

  def test_get_bid_price
    @quote.get_bid_price.wont_be_nil
    puts "Bid: #{@quote.get_bid_price} / Offer: #{@quote.get_offer_price}"
  end
end
