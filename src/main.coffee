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

class ISOHuntSearch
  constructor: ->

  search: (query) ->
    $.ajax(url: @queryUrl(query), dataType: "html").then (html) ->
      results = []

      $(html).find("#serps").find("tr[onclick]").each ->
        results.push(new ISOHuntSearchResult(this))

      results

  queryUrl: (query) -> "http://isohunt.com/torrents/?ihq=#{query}"

class ISOHuntSearchResult
  constructor: (element) -> @node = $(element)

  age:        -> @node.children("td:nth-child(2)").text()
  name:       -> @node.find("td:nth-child(3) a[id]").html().replace(/^.+?<br>/, "")
  size:       -> @node.children("td:nth-child(4)").text()
  seeders:    -> @node.children("td:nth-child(5)").text()
  leechers:   -> @node.children("td:nth-child(6)").text()
  torrentUrl: -> "http://isohunt.com" + @node.find("td:nth-child(3) a[id]").attr("href")

class ResultBuilder
  constructor: (sibling) ->
    row = $('<tr><td><div class="ned"></div>')
    row.insertAfter(sibling.parentNode)
    @node = row.find(".ned")
    @node.css(paddingLeft: "7px", borderLeft: "2px solid #000", margin: "3px")

  showText: (text) -> @node.html(text)
  showResults: (results) ->
    @node.html("")

    for result in results.slice(0, 5)
      @node.append(@buildResult(result))

  buildResult: (result) ->
    row = $("<div>")
    link = $("<a target=\"_blank\">#{result.name()}</a>")
    link.appendTo(row)
    $.when(result.torrentUrl()).then (url) -> link.attr("href", url)
    row

searchProvider = new ISOHuntSearch()

$(".row td").each ->
  self = $(this)
  info = new EpisodeInfo(this)
  formatter = new SearchFormatter(info)
  resultDisplayer = new ResultBuilder(this)
  query = formatter.toString()

  self.append(" | <a href=\"http://isohunt.com/torrents/?ihq=#{query}\" class=\"episodeinfo ihsearch\" target=\"_blank\">Search on ISOHunt</a>")
  self.find(".ihsearch").click (e) ->
    e.preventDefault()

    resultDisplayer.showText("Loading download options...")
    searchProvider.search(query).then (results) -> resultDisplayer.showResults(results)
