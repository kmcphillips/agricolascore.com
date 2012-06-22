window.playerCount = 2


$(document).bind 'pageinit', ->
  # Initialize listeners
  $("#player_count_buttons a").bind "click", playerButtonClick

  # Setup data
  playerButtonClick.call($("#player_count_buttons a").eq(playerCount - 1))


window.playerButtonClick = ->
  $("#player_count_buttons a").removeClass("ui-btn-active")
  $(this).addClass("ui-btn-active")

  count = $(this).data("player-count")

  $("#player_list li").each (index, player) ->
    if $(this).data("player-number") <= count
      $(this).show()
    else
      $(this).hide()
  