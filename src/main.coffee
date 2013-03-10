$ = jQuery

class EpisodeInfo
  constructor: (element) -> @e = $(element)

  show: -> @e.closest(".showTable").find(".showName").html()
  season: -> @extractEpisodeNumber()[1]
  episode: -> @extractEpisodeNumber()[2]

  extractEpisodeNumber: -> @e.text().match(/^(\d+)x(\d+)/)

class SearchFormatter
  constructor: (@info) ->

  toString: ->
    season = zeroFill(@info.season(), 2)
    episode = zeroFill(@info.episode(), 2)

    "#{@info.show()} S#{season}E#{episode} 720p"

  zeroFill = (number, size) ->
    number = number + "" # ensure it's a string

    number = "0" + number while number.length < size
    number

$(".row td").each ->
  info = new EpisodeInfo(this)
  formatter = new SearchFormatter(info)
  search = formatter.toString()

  $(this).append(" | <a href=\"http://isohunt.com/torrents/?ihq=#{search}\" class=\"episodeinfo\" target=\"_blank\">Search on ISOHunt</a>")
