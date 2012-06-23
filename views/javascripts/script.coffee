window.playerCount = 2
window.players = null

$(document).bind 'pageinit', ->
  # Initialize listeners
  $("#player_count_buttons a").bind "click", playerButtonClick
  $("a.save_players").bind "click", savePlayers
  $("#player_list li input[type=text]").bind "change", savePlayers

  # Setup data
  playerButtonClick.call($("#player_count_buttons a").eq(playerCount - 1))


$(document).bind 'pagechange', (something, data) ->
  # If the page is reloaded, we won't have the in-memory collection of players/scores but it will remember the current page. Redirect them in this case.
  if currentPageId() != "index" && currentPageId() != "players" && window.players == null
    $.mobile.changePage $("#index")



window.playerButtonClick = ->
  $("#player_count_buttons a").removeClass("ui-btn-active")
  $(this).addClass("ui-btn-active")

  window.playerCount = $(this).data("player-count")

  $("#player_list li").each (index, player) ->
    if $(this).data("player-number") <= window.playerCount
      $(this).show()
    else
      $(this).hide()
  

window.savePlayers = ->
  window.players = []

  console.log "saving players"

  $("#player_list li").each (index, player) ->
    if index + 1 <= window.playerCount
      console.log "saved player " + index
      window.players.push
        name: $(player).find("input[type=text]").val()


  container = $("#scorecard_container")
  prototype = $("#scorecard_prototype")
  first = true

  container.html("")

  for player in window.players
    console.log "creating form for player " + player.name
    current = prototype.clone()
    current.find("h3").html(player.name)
    current.removeClass("hidden")

    if first
      console.log "uncollapsing the first player"
      current.data("collapsed", "false")
      first = false

    container.append(current)


window.currentPageId = ->
  $.mobile.activePage.attr("id")



# JSON.stringify()