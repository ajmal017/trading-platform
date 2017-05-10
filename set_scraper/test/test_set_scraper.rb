require 'turn/autorun'

require_relative '../lib/set_scraper'


describe SETScraper do
  before do
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG
    @scraper = SETScraper.new(:logger => logger)
  end

  # describe "#initialize" do
  #   it "accepts logger as an options parameter" do
  #     log = Logger.new(STDOUT)
  #     log.level = Logger::WARN
  #     scraper = SETScraper.new(:logger => log)
  #     scraper.must_respond_to(:logger)
  #   end
  # end

  # describe "#get_stocks" do
  #   it "accepts prefix parameter as a string" do
  #     @scraper.get_stocks('A').first[:symbol].wont_be_nil
  #   end

  #   it "returns proper stocks array with specific prefixes" do
  #     @scraper.get_stocks(['A']).first[:symbol].wont_be_nil
  #   end
  # end

  # describe "#get_warrants" do
  #   it "works" do
  #     scraper = SETScraper.new(:language => 'th')
  #     scraper.get_warrants.first[:symbol].wont_be_nil
  #   end
  # end

  # describe "#get_devirative_warrants" do
  #   it "works" do
  #     @scraper.get_derivative_warrants.first[:symbol].wont_be_nil
  #   end
  # end

  # describe "#get_etfs" do
  #   it "works" do
  #     @scraper.get_etfs.first[:symbol].wont_be_nil
  #   end
  # end

  # describe "#get_realtime_price" do
  #   it "works" do
  #     @scraper.get_real_time_price('PTT', true).wont_be_empty
  #     @scraper.get_real_time_price('TASCO-W3', true, 'w').wont_be_empty
  #     @scraper.get_real_time_price('ADVA01CD', true, 'dw').wont_be_empty
  #   end
  # end

  # describe "#get_historical_prices" do
  #   it "works" do
  #     prices = @scraper.get_historical_prices('TASCO-W3')
  #     prices.wont_be_empty
  #     prices.size.must_be :>, 1
  #   end
  # end

  # describe "#get_statement" do
  #   it "works" do
  #     @scraper.get_statement('PTT', 'income').wont_be_empty
  #   end
  # end

  # describe "#get_warrant_profile" do
  #   it "works" do
  #     @scraper.get_warrant_profile('TASCO-W3').wont_be_empty
  #     # puts @scraper.get_warrant_profile('TASCO-W3')
  #   end
  # end

  describe "#get_index" do
    it "works" do
      @scraper.get_index_stocks('set50').wont_be_empty
    end
  end
end
