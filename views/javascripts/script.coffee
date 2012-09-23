window.playerCount = 2
window.players = null

$(document).bind 'pageinit', ->
  # Initialize listeners
  $("#player_count_buttons a").bind "click", playerButtonClick
  $("a.save_players").bind "click", savePlayers
  $("a.calculate_score").bind "click", calculateScore
  $("a.abandon").bind "click", resetForm
  $("a.resume").bind "click", populatePlayersFromResume
  $("#player_list li input[type=text]").bind "change", savePlayers
  $("#scorecard_container .player h3.ui-collapsible-heading").bind "click", ->
    $.mobile.silentScroll(0)
  $(".house_construction input").bind "click", houseConstructionClick

  # Setup data
  playerButtonClick.call($("#player_count_buttons a").eq(playerCount - 1))


$(document).bind 'pagechange', (something, data) ->
  # If the page is reloaded, we won't have the in-memory collection of players/scores but it will remember the current page. Redirect them in this case.
  if currentPageId() != "index" && currentPageId() != "players" && window.players == null
    $.mobile.changePage $("#index")

  if currentPageId() == "scorecard"
    houseConstructionClick.call($(".house_construction input"))

  if currentPageId() == "index"
    setResumeButton()

$(document).delegate 'a.top', 'click', ->
    $.mobile.silentScroll(0)
    return false


window.log = (message) ->
  window.console.log(message) if(window.console && window.console.log)


window.toSentence = (array) ->
  result = ""

  for index in [0...array.length]
    element = array[index]

    if result == ""
      result = element
    else if index == array.length - 1
      result = result + " and " + element
    else
      result = result + ", " + element

  result


window.playerButtonClick = ->
  $("#player_count_buttons a").removeClass("ui-btn-active")
  $(this).addClass("ui-btn-active")

  window.playerCount = $(this).data("player-count")

  $("#player_list li").each (index, player) ->
    if $(this).data("player-number") <= window.playerCount
      $(this).show()
    else
      $(this).hide()


window.setResumeButton = ->
  container = $("#resume_button")

  if $.cookies.get("players")
    container.find("span.names").html(toSentence($.cookies.get("players")))
    container.show()
  else
    container.hide()


window.populatePlayersFromResume = ->
  names = $.cookies.get("players")
  window.playerCount = names.length

  $("#player_list li").each (index) ->
    row = $(this)
    if index < names.length
      row.find("input").val(names[index])


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

    if index < window.players.length
      current.find("h3 span.player_name").html(window.players[index].name)
      current.show()
    else
      current.find("h3 span.player_name").html("")
      current.hide()

  $.cookies.set("players", (window.players.map (p) -> p.name), 365)


window.houseConstructionClick = ->
  action = if $(this).val() == "wood" then "disable" else "enable"
  $(this).closest("div.player").find("input.rooms").slider(action)


window.resetForm = ->
  container = $("#scorecard_container")

  container.find("input.fields, input.pastures, input.wheat, input.vegetable, input.sheep, input.boar, input.cattle, input.unused, input.stables, input.rooms, input.family").each ->
    field = $(this)
    field.val(field.attr("min"))
    field.slider("refresh")

  container.find(".house_construction input").each ->
    field = $(this)
    if field.hasClass("wood")
      field.attr("checked", true)
    else
      field.attr("checked", false)

    field.checkboxradio("refresh")

  container.find("input.rooms").slider("disable")

  container.find("input.cards, input.bonus").val(0)


window.calculateScore = ->
  $("#scorecard_container div.player").each (index, form) ->
    if index < window.players.length
      form = $(form)
      score = 0

      for field, values of window.scoreMappings
        value = window.parseValue(form, field)

        if value >= values.length
          score = score + values.last()
        else
          score = score + values[value]

      score = score + (window.parseValue(form, "unused") * -1)
      score = score + (window.parseValue(form, "family") * 3)
      score = score + window.parseValue(form, "stables")
      score = score + window.parseValue(form, "cards")
      score = score + window.parseValue(form, "bonus")
      
      switch form.find(".house_construction input:checked").val()
        when "stone" then score = score + window.parseValue(form, "rooms") * 2
        when "clay" then score = score + window.parseValue(form, "rooms")

      window.players[index].score = score

  $("#result_table li").each (index, row) ->
    row = $(row)
    player = window.players[index]

    if index < window.players.length
      row.find("h2.name").html(player.name)
      row.find("h2.score").html(player.score)

      if index == (window.players.length - 1)
        row.addClass("ui-corner-bottom")
      else
        row.removeClass("ui-corner-bottom")

      row.show()
    else
      row.hide()

  high_score = -100
  winners = []

  for player in players
    if player.score == high_score
      winners.push player
    else if player.score > high_score
      high_score = player.score
      winners = [player]

  if winners.length == 1
    $("#winner").html(winners[0].name + " wins with " + winners[0].score + " points!")
  else
    $("#winner").html(toSentence(winner.name for winner in winners) + " tie with " + winners[0].score + " points!")
      

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


