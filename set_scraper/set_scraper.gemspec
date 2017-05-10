Gem::Specification.new do |s|
  s.name        = 'set_scraper'
  s.version     = '0.0.1'
  s.date        = '2013-03-23'
  s.summary     = "Swissknife for the Stock Exchange of Thailand (SET)"
  s.description = "A crawler, spider, extractor, scraper, for the Stock Exchange of Thailand's website (http://www.set.or.th)"
  s.authors     = 'Surakarn Samkaew'
  s.email       = 'tonkla@gmail.com'
  s.files       = Dir.glob('lib/**/*.rb')

  s.required_ruby_version = '>= 2.1.2'
  s.required_rubygems_version = '>= 2.2.2'

  s.add_dependency 'nokogiri', '~> 1.6'
end
