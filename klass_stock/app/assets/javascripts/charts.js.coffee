$ ->
  return if typeof symbol == 'undefined'

  $.getJSON "/charts/#{symbol}.json", (data) ->
    ohlc = []
    volume = []

    for d in data['quotes']
      ohlc.push([d[0], d[1], d[2], d[3], d[4]])
      volume.push([d[0], parseInt(d[5])])

    groupingUnits = [
      ['day', [1]],
      ['week', [1]],
      ['month', [1, 3, 6]]
    ]

    colors = {
      lighter_blue: '#BAD0E8'
      red: '#BF2E2E'
      green: '#3B9C38'
      black: '#333333'
    }

    $('#container').highcharts 'StockChart',
        rangeSelector:
          buttons: [
            {type: 'ytd', text: 'YTD'},
            {type: 'month', count: 1, text: '1m'},
            {type: 'month', count: 3, text: '3m'},
            {type: 'month', count: 6, text: '6m'},
            {type: 'year', count: 1, text: '1y'},
            {type: 'all', text: 'All'}
          ]
          selected: 2

        title:
          text: "#{company}"

        yAxis: [{
          title:
            text: 'OHLC'
          height: 610
          lineWidth: 2
        }, {
          title:
            text: ''
          top: 475
          height: 200
          offset: 0
          lineWidth: 2
          gridLineWidth: 0
          labels:
            enabled: false
        }]
        #, {
        #   title:
        #     text: 'MACD'
        #   top: 470
        #   height: 200
        #   offset: 0
        #   lineWidth: 2
        # },
        # {
        #   title:
        #     text: 'ADX'
        #   top: 680
        #   height: 120
        #   offset: 0
        #   lineWidth: 2
        # }]

        plotOptions:
          spline:
            lineWidth: 1
          tooltip:
            xDateFormat: '<b>%Y-%m-%d</b>'
          candlestick:
            color: colors.red
            lineColor: colors.red
            upColor: colors.green
            upLineColor: colors.green

        tooltip:
          valueDecimals: 2
          pointFormat: '<span style="color:#333">{series.name}</span>: {point.y}<br/>'
          xDateFormat: '<b>%Y-%m-%d</b>'
          enabled: true
          positioner: -> {x: 65, y: 75}

        series: [{
          type: 'candlestick'
          name: "#{symbol}"
          data: ohlc
          dataGrouping:
            units: groupingUnits
          tooltip:
            xDateFormat: '<b>%Y-%m-%d</b>'
        },
        {
          name: 'MA10-O'
          type: 'spline'
          color: colors.red
          data: data['ma0']
          dataGrouping:
            units: groupingUnits
        },
        {
          name: 'MA10-C'
          type: 'spline'
          color: colors.green
          data: data['ma1']
          dataGrouping:
            units: groupingUnits
        },
        {
          type: 'spline'
          name: 'Upper'
          dashStyle: 'DashDot'
          color: colors.black
          data: data['bbands_upper']
          dataGrouping:
            units: groupingUnits
        },
        {
          type: 'spline'
          name: 'Middle'
          dashStyle: 'DashDot'
          color: colors.black
          data: data['bbands_middle']
          dataGrouping:
            units: groupingUnits
        },
        {
          type: 'spline'
          name: 'Lower'
          dashStyle: 'DashDot'
          color: colors.black
          data: data['bbands_lower']
          dataGrouping:
            units: groupingUnits
        },
        {
           type: 'column'
           name: 'Vol'
           data: volume
           yAxis: 1
           color: colors.lighter_blue
           dataGrouping:
             units: groupingUnits
           tooltip:
             valueDecimals: 0
           zIndex: -1
        }]
        # {
        #   type: 'spline'
        #   name: 'MACD'
        #   data: data['macd']
        #   yAxis: 2
        #   color: colors.green
        #   dataGrouping:
        #     units: groupingUnits
        # },
        # {
        #   type: 'spline'
        #   name: 'Signal'
        #   data: data['macd_signal']
        #   yAxis: 2
        #   color: colors.red
        #   dataGrouping:
        #     units: groupingUnits
        # },
        # {
        #   type: 'areaspline'
        #   name: 'Histo'
        #   data: data['macd_histogram']
        #   yAxis: 2
        #   color: colors.lighter_blue
        #   dataGrouping:
        #     units: groupingUnits
        #   zIndex: -1
        # },
        # {
        #   type: 'line'
        #   name: 'ADX'
        #   data: data['adx']
        #   yAxis: 2
        #   color: colors.black
        #   dataGrouping:
        #     units: groupingUnits
        # },
        # {
        #   type: 'line'
        #   name: 'DI+'
        #   data: data['plus_di']
        #   yAxis: 2
        #   color: colors.green
        #   dataGrouping:
        #     units: groupingUnits
        # },
        # {
        #   type: 'line'
        #   name: 'DI-'
        #   data: data['minus_di']
        #   yAxis: 2
        #   color: colors.red
        #   dataGrouping:
        #     units: groupingUnits
        # }]
