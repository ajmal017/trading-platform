require 'json'
require 'net/http'

require 'em-websocket'
require 'pg'

require 'set_scraper'
require_relative './klass_trade/main'


EM.run {
  @channel = EM::Channel.new
  @sid = nil

  EM::WebSocket.run(host: "0.0.0.0", port: 8080) do |ws|
    ws.onopen {
      sid = @channel.subscribe { |msg| ws.send msg }
      @channel.unsubscribe(@sid) if @sid
      @sid = sid

      ws.onmessage { |msg|
        if msg == 'SAWASDEE'
          puts "Client #{@sid} connected"
          @connected = true
        end
      }

      ws.onclose {
        @channel.unsubscribe(@sid)
        @connected = false
      }
    }
  end

  @conn = PG.connect(host: 'localhost', port: 5432, dbname: 'klass_stock',
                     user: 'root', password: 'root') unless @conn

  @queues = []
  EM.add_periodic_timer(10) {
    now = Time.now.utc + 25200
    unless (now.hour == 12 and now.min >= 28) or (now.hour == 16 and now.min >= 28)
      KlassTrade::Main.run(@conn, ['s0', 's1', 's2']) {|signal| @queues << signal if signal} if @connected
    end
  }

  EM.add_periodic_timer(3) {
    now = Time.now.utc + 25200
    if @queues.size > 0
      signal = @queues.shift
      @channel.push JSON.dump(signal)

      http = Net::HTTP.new('localhost', 4000)
      req = Net::HTTP::Post.new('/portfolios/1/orders')
      req.set_form_data({
        'order[side]' => signal[:side],
        'order[symbol]' => signal[:symbol],
        'order[datetime]' => now.strftime('%Y-%m-%d %H:%M:%S'),
        'order[price]' => signal[:price],
        'order[volume]' => signal[:volume],
        'client' => 'klass_trade_client'
      })
      http.request req
    elsif (now.hour == 12 and now.min >= 29) or (now.hour == 16 and now.min >= 29)
      EM.stop
    end
  }
}
