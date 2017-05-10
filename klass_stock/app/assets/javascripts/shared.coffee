$ ->
  $('input[type="text"].symbol').on 'keyup', ->
    str = $(this).val().toUpperCase()
    $(this).val(str)
