KlassStock::Application.routes.draw do
  get 'launchpad' => 'launchpad#index'

  get 'charts' => 'charts#index', as: 'charts'
  get 'charts/:symbol' => 'charts#show', as: 'show_chart'

  match 'monitored-securities' => 'monitored_securities#index', via: [:get, :post, :delete],
                                                                as: 'monitored_securities'
  get 'intraday-quotes/create' => 'intraday_quotes#create'

  match 'step-trades' => 'step_trades#index', via: [:get, :post], as: 'step_trades'
  match 'step-trades/:symbol' => 'step_trades#show', via: [:get, :post], as: 'show_step_trade'
  match 'fraction-trades' => 'fraction_trades#index', via: [:get, :post], as: 'fraction_trades'
  match 'fraction-trades/:symbol' => 'fraction_trades#show', via: [:get, :post],
                                                             as: 'show_fraction_trade'
  match 'zone-trades' => 'zone_trades#index', via: [:get, :post], as: 'zone_trades'
  match 'zone-trades/:symbol' => 'zone_trades#show', via: [:get, :post], as: 'show_zone_trade'

  match 'pre-orders' => 'pre_orders#index', via: [:get, :post, :patch, :delete], as: 'pre_orders'

  get 'daily-trends' => 'daily_trends#index', as: 'daily_trends'
  get 'daily-trends/:date' => 'daily_trends#index'

  resources :portfolios do
    get 'disable', on: :member
    get 'enable', on: :member
    get 'deals', on: :member
    get 'deals/:symbol' => 'portfolios#deals', on: :member

    resources :orders
  end

  match '/' => 'welcome#index', via: [:get, :post]
  get '/logout' => 'welcome#logout'
end
