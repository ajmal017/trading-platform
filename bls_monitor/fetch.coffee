fetch = ->
  try
    #now = new Date
    #hour = now.getHours()
    #min = now.getMinutes()
    #return unless (hour == 9 and min >= 55) or
    #               hour == 10 or
    #               hour == 11 or
    #              (hour == 12 and min <= 30) or
    #              (hour == 14 and min >= 25) or
    #               hour == 15 or
    #              (hour == 16 and min <= 30)

    content = top.frames[1].document
    rows = $(content).find('div.marketWatch').find('tr')
    for row in rows
      cols = $(row).children('td')
      symbol = $.trim(cols.eq(0).text())
      if symbol isnt '' and symbol isnt 'STOCK'
        data = {
          symbol: symbol
          bid_volume: cols.eq(2).text().replace(',', '').replace('T', '000')
          bid_price: cols.eq(3).text().replace(',', '')
          offer_price: cols.eq(5).text().replace(',', '')
          offer_volume: cols.eq(6).text().replace(',', '').replace('T', '000')
          last_price: cols.eq(7).text().replace(',', '')
          client: 'klass_trade_client'
        }
        if parseFloat(data.bid_price) > 0 and parseFloat(data.offer_price) > 0
          $.ajax({
            url: "https://localhost:4001/intraday-quotes/create"
            dataType: 'jsonp'
            data: data
            success: (data) ->
            error: (data) ->
          })

  catch error
    console.debug('Exception: ' + error)
