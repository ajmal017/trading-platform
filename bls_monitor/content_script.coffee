injectScript = ->
  script = document.createElement("script")
  script.type = "text/javascript"
  script.src = "https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js"
  document.getElementsByTagName("head")[0].appendChild(script)

  script = document.createElement("script")
  script.type = "text/javascript";
  func = 'var fetch=function(){var e;e=function(){var e,t,r,a,c,o,i,l,n,p;try{for(t=top.frames[1].document,o=$(t).find(\"div.marketWatch\").find(\"tr\"),p=[],l=0,n=o.length;n>l;l++)c=o[l],e=$(c).children(\"td\"),i=$.trim(e.eq(0).text()),\"\"!==i&&\"STOCK\"!==i?(r={symbol:i,bid_volume:e.eq(2).text().replace(\",\",\"\").replace(\"T\",\"000\"),bid_price:e.eq(3).text().replace(\",\",\"\"),offer_price:e.eq(5).text().replace(\",\",\"\"),offer_volume:e.eq(6).text().replace(\",\",\"\").replace(\"T\",\"000\"),last_price:e.eq(7).text().replace(\",\",\"\"),client:\"klass_trade_client\"},p.push(parseFloat(r.bid_price)>0&&parseFloat(r.offer_price)>0?$.ajax({url:\"https://localhost:4001/intraday-quotes/create\",dataType:\"jsonp\",data:r,success:function(){},error:function(){}}):void 0)):p.push(void 0);return p}catch(s){return a=s,console.debug(\"Exception: \"+a)}}};';
  script.innerHTML = '(function(){'+func+'setInterval(function(){fetch()},10000)})();'
  document.getElementsByTagName("head")[0].appendChild(script)

$ ->
  injectScript()

# inject jQuery into console
# javascript:function(d,s){s=d.createElement('script');s.src='https://ajax.googleapis.com/ajax/libs/jquery/2.1.1/jquery.min.js';(d.head||d.documentElement).appendChild(s)};
