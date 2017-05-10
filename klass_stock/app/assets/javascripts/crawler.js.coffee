puts = _.bind(console.log, console)

companiesCrawlerEN = ->
  $('table').eq(51).find('tr[valign="top"]').each ->

    symbol = $(this).find('td').eq(0).text()
    name = $(this).find('td').eq(1).text()
    market = $(this).find('td').eq(2).text()

    data = { symbol: $.trim(symbol), name: $.trim(name), market: $.trim(market) }

    $.ajax({
      url: 'http://localhost:3000/crawler/create',
      dataType: 'jsonp',
      data: data,
      success: (data) -> puts(data),
      error: (data) -> puts(data)
    })

companiesCrawlerTH = ->
  $('table').eq(53).find('tr[valign="top"]').each ->

    symbol = $(this).find('td').eq(0).text()
    name_th = $(this).find('td').eq(1).text()

    data = { symbol: $.trim(symbol), name_th: $.trim(name_th) }

    $.ajax({
      url: 'http://localhost:3000/crawler/update',
      dataType: 'jsonp',
      data: data,
      success: (data) -> puts(data),
      error: (data) -> puts(data)
    })


  # $('table').eq(52).find('td[class!="submenu"]').not(':first').each ->
  # page = $(this).find('a').text()
  # url = 'http://www.set.or.th/set/commonslookup.do?prefix='+page+'&language=en&country=US'
  # window.location = url


window.run = ->
  # companiesCrawlerEN()
  companiesCrawlerTH()
  null


# javascript:if(!window.jQuery||confirm('Overwrite\x20current\x20version?\x20v'+jQuery.fn.jquery))(function(d,s){s=d.createElement('script');s.src='https://ajax.googleapis.com/ajax/libs/jquery/1.8/jquery.min.js';(d.head||d.documentElement).appendChild(s)})(document);
# javascript:if(!window.jQuery||confirm('Overwrite\x20current\x20version?\x20v'+jQuery.fn.jquery))(function(d,s){s=d.createElement('script');s.src='http://code.jquery.com/jquery.js';(d.head||d.documentElement).appendChild(s)})(document);
