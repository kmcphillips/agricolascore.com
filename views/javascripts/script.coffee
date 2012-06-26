window.playerCount = 2
window.players = null

$(document).bind 'pageinit', ->
  # Initialize listeners
  $("#player_count_buttons a").bind "click", playerButtonClick
  $("a.save_players").bind "click", savePlayers
  $("a.calculate_score").bind "click", calculateScore
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

  $("#player_list li").each (index, player) ->
    if index + 1 <= window.playerCount
      window.players.push
        name: $(player).find("input[type=text]").val()
        score: 0

  container = $("#scorecard_container")

  for current, index in container.find("div.player")
    current = $(current)

    resetForm(current)

    if index < window.players.length
      player = window.players[index]
      current.find("h3 span.player_name").html(player.name)
      current.show()
    else
      current.find("h3 span.player_name").html("")
      current.hide()


window.resetForm = (current) ->
  # todo: reset form


window.calculateScore = ->
  $("#scorecard_container div.player").each (index, form) ->
    if index < window.players.length
      form = $(form)
      score = 0

      for field, values of window.scoreMappings
        value = window.parseValue(field)

        if value >= values.length
          score = score + values.last()
        else
          score = score + values[value]

      score = score + (window.parseValue("unused") * -1)
      score = score + (window.parseValue("family") * 3)
      score = score + window.parseValue("stables")
      score = score + window.parseValue("cards")
      score = score + window.parseValue("bonus")
      # TODO: house rooms

      window.players[index].score = score

  $("#result_table li").each (index, row) ->
    row = $(row)
    player = window.players[index]

    if index < window.players.length
      row.find("h2.name").html(player.name)
      row.find("h2.score").html(player.score)
      row.show()
    else
      row.hide()

      
window.parseValue = (form, field) ->
  value = parseInt $(form).find("input." + field).val()
  value = 0 if isNaN(value) || value < 0
  value


window.currentPageId = ->
  $.mobile.activePage.attr("id")



# JSON.stringify()


## Score mappings. Array index is the count, value is the score.
window.scoreMappings = 
  wheat: [-1,1,1,1,2,2,3,3,4]
  vegetable: [-1,1,2,3,4]
  sheep: [-1,1,1,1,2,2,3,3,4]
  boar: [-1,1,1,2,2,3,3,4]
  cattle: [-1,1,2,2,3,3,4]
  fields: [-1,-1,1,2,3,4]
  pastures: [-1,1,2,3,4]


