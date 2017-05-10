_$ = jQuery.noConflict()

base =
  buy: (_symbol, _volume, _price, _pin) ->
    this.uiBuy()
    this.uiSymbol(_symbol)
    this.uiVolume(_volume)
    this.uiPrice(_price)
    this.uiPin(_pin)
    this.uiSubmit()
  sell: (_symbol, _volume, _price, _pin) ->
    this.uiSell()
    this.uiSymbol(_symbol)
    this.uiVolume(_volume)
    this.uiPrice(_price)
    this.uiPin(_pin)
    this.uiSubmit()

settrade =
  uiBuy: ->
    side = _$('input.buyRadio').first()
    side.prop('checked', true) if side.attr('name') is 'txtBorS'
  uiSell: ->
    side = _$('input.sellRadio').first()
    side.prop('checked', true) if side.attr('name') is 'txtBorS'
  uiSymbol: (_symbol) ->
    symbol = _$('input.symbol').eq(2)
    symbol.val(_symbol) if symbol.attr('name') is 'txtSymbol'
  uiVolume: (_volume) ->
    volume = _$('input.volume').first()
    volume.val(_volume) if volume.attr('name') is 'txtQty'
  uiPrice: (_price) ->
    price = _$('input.price').first()
    price.val(_price) if price.attr('name') is 'txtPrice'
  uiPin: (_pin) ->
    pin = _$('input.pin').first()
    pin.val(_pin) if pin.attr('name') is 'txtPIN_new'
  uiSubmit: ->
    _$('input.submitBtn').first().click()
_$.extend(settrade, base)

run = ->
  ws = new WebSocket('ws://0.0.0.0:8080')

  ws.onopen = ->
    ws.send('SAWASDEE')

  ws.onmessage = (e) ->
    signal = JSON.parse(e.data)
    if signal
      if signal.side
        client = settrade
        pin = atob('MDAwMDAw')
        if signal.side is 'B'
          client.buy(signal.symbol, signal.volume, signal.price, pin)
          logger(1, signal)
        else if signal.side is 'S'
          client.sell(signal.symbol, signal.volume, signal.price, pin)
          logger(1, signal)
      else if signal.code
        if signal.code is 'WOR1'
          logger(0, "I'm working")
        else if signal.code is 'WOR3'
          ws.send('WOR4')

logger = (level, msg) ->
  if level is 0
    console.debug(new Date(), msg)
  else if level is 1
    console.log(new Date(), msg)

injectScript = ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.innerHTML = "window.confirm=function(){console.log('hey');return false};window.alert=function(){return false};"
  document.getElementsByTagName("head")[0].appendChild(script)

  # NOTE: worse performance than above.
  # script = _$(document.createElement('script')).attr('type', 'text/javascript')
  # script.html "window.confirm=function(){return true};window.alert=function(){return true};"
  # _$(document.head).append(script)

_$ ->
  injectScript()
  #run()
