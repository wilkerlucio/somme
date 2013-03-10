(function() {
  var $, EpisodeInfo, SearchFormatter;

  $ = jQuery;

  EpisodeInfo = (function() {

    function EpisodeInfo(element) {
      this.e = $(element);
    }

    EpisodeInfo.prototype.show = function() {
      return this.e.closest(".showTable").find(".showName").html();
    };

    EpisodeInfo.prototype.season = function() {
      return this.extractEpisodeNumber()[1];
    };

    EpisodeInfo.prototype.episode = function() {
      return this.extractEpisodeNumber()[2];
    };

    EpisodeInfo.prototype.extractEpisodeNumber = function() {
      return this.e.text().match(/^(\d+)x(\d+)/);
    };

    return EpisodeInfo;

  })();

  SearchFormatter = (function() {
    var zeroFill;

    function SearchFormatter(info) {
      this.info = info;
    }

    SearchFormatter.prototype.toString = function() {
      var episode, season;
      season = zeroFill(this.info.season(), 2);
      episode = zeroFill(this.info.episode(), 2);
      return "" + (this.info.show()) + " S" + season + "E" + episode + " 720p";
    };

    zeroFill = function(number, size) {
      number = number + "";
      while (number.length < size) {
        number = "0" + number;
      }
      return number;
    };

    return SearchFormatter;

  })();

  $(".row td").each(function() {
    var formatter, info, search;
    info = new EpisodeInfo(this);
    formatter = new SearchFormatter(info);
    search = formatter.toString();
    return $(this).append(" | <a href=\"http://isohunt.com/torrents/?ihq=" + search + "\" class=\"episodeinfo\" target=\"_blank\">Search on ISOHunt</a>");
  });

}).call(this);
