namespace :self do
  namespace :backtest do
    desc "Run backtesting"
    task :run, [:name, :symbol, :strategy, :ma_type, :from, :to] => [:environment] do |t, args|
      args.with_defaults(:strategy => '10ma_co', :ma_type => :sma, :from => '2008-01-01')
      BacktestingService.run(args.name, args.symbol, args.strategy, args.ma_type, args.from, args.to)
      # DerivativeWarrant.where(active: false).order(:symbol).each do |dw|
      #   name = "#{dw.symbol}-1-5-100"
      #   BacktestingService.run(name, dw.symbol, 'spread')
      # end
    end

    # namespace :gotop do
    #   desc "Go Top"
    #   task :run, [:symbol] => [:environment] do |t, args|
    #     GoTop.run(args.symbol)
    #     # DerivativeWarrant.where(:active => false).order(:symbol).each do |dw|
    #     #   GoTop.run(dw.symbol)
    #     # end
    #   end
    # end
  end
end
