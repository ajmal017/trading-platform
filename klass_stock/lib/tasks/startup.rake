require 'csv'


namespace :self do
  desc 'Import all database seeds'
  task :import => [:environment, :clean, :import_sectors, :import_industries]
  # task :import => [:environment, :clean, :import_sectors, :import_industries, :import_companies, :import_stocks]
  task :clean do
    Rake::Task['db:drop'].execute
    Rake::Task['db:create'].execute
    Rake::Task['db:schema:load'].execute
  end
  task :import_sectors => [:environment] do
    file = File.open(File.join(Rails.root, 'db', 'seeds', 'sectors.json'), 'r')
    ActiveSupport::JSON.decode(file.read).each do |sector|
      Sector.create(sector)
    end
  end
  task :import_industries => [:environment] do
    file = File.open(File.join(Rails.root, 'db', 'seeds', 'industries.json'), 'r')
    ActiveSupport::JSON.decode(file.read).each do |industry|
      Industry.create(industry)
    end
  end
  task :import_companies => [:environment] do
    file = File.join(Rails.root, 'db', 'seeds', 'companies.json')
    if File.exists?(file)
      file = File.open(file, 'r')
      ActiveSupport::JSON.decode(file.read).each do |company|
        # company.delete('listed_at')
        # company['industry_id'] = -1 unless company['industry_id']
        # company['website'] = company['website'].downcase if company['website']
        Company.create(company)
      end
    else
      puts "File not found."
    end
  end
  task :import_stocks => [:environment] do
    file = File.join(Rails.root, 'db', 'seeds', 'stocks.json')
    if File.exists?(file)
      file = File.open(file, 'r')
      ActiveSupport::JSON.decode(file.read).each do |stock|
        Stock.create(stock)
      end
    else
      puts "File not found."
    end
  end


  desc 'Export all database seeds'
  task :export => [:environment, :export_sectors, :export_industries, :export_companies, :export_stocks]
  task :export_sectors => [:environment] do
    file = File.open(File.join(Rails.root, 'db', 'seeds', 'sectors.json'), 'w')
    file.write(ActiveSupport::JSON.encode(Sector.select([:name, :symbol, :name_th])
                                                .order(:symbol)))
  end
  task :export_industries => [:environment] do
    file = File.open(File.join(Rails.root, 'db', 'seeds', 'industries.json'), 'w')
    file.write(ActiveSupport::JSON.encode(Industry.select([:sector_id, :name, :symbol, :name_th])
                                                  .order(:sector_id, :symbol)))
  end
  task :export_companies => [:environment] do
    file = File.open(File.join(Rails.root, 'db', 'seeds', 'companies.json'), 'w')
    file.write(ActiveSupport::JSON.encode(Company.select([:industry_id, :market, :symbol, :name, :name_th,
                                                          :description, :description_th, :website,
                                                          :established_at])
                                                  .order(:symbol)))
  end
  task :export_stocks => [:environment] do
    file = File.open(File.join(Rails.root, 'db', 'seeds', 'stocks.json'), 'w')
    file.write(ActiveSupport::JSON.encode(Stock.select([:industry_id, :company_id, :symbol, :market])
                                                .order(:symbol)))
  end
  task :export_vocabularies => [:environment] do
    file = File.open(File.join(Rails.root, 'db', 'seeds', 'vocabularies.json'), 'w')
    file.write(ActiveSupport::JSON.encode(Vocabulary.select([:code, :en, :th]).order(:id)))
  end


  desc "Extract End-of-Day CSVs"
  task :extract_eod_csv, [:target_file] => [:environment]  do |t, args|
    EODCSVExtractor.new(args.target_file).run
  end
end


class EODCSVExtractor
  attr_accessor :target_file

  def initialize(target_file)
    @logger = Logger.new(STDOUT)
    @target_file = target_file
  end

  def run
    if File.exists?(target_file)
      if File.file?(target_file)
        @logger.debug("Extracting... #{target_file}")
        CSV.foreach(target_file, :headers => true) do |row|
          Quote.create(
            :symbol => row[0],
            :date => row[1],
            :open => row[2],
            :high => row[3],
            :low => row[4],
            :close => row[5],
            :volume => row[6]
          )
        end
      else
        Dir.foreach(target_file).sort.each do |file|
          file = "#{target_file}/#{file}"
          if File.exists?(file) && File.file?(file)
            @logger.debug("Extracting... #{file}")
            CSV.foreach(file, :headers => true) do |row|
              Quote.create(
                :symbol => row[0],
                :date => row[1],
                :open => row[2],
                :high => row[3],
                :low => row[4],
                :close => row[5],
                :volume => row[6]
              )
            end
          end
        end
      end
    end
  end
end
