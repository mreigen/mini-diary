var JSHelix = function(params) {
  this.baseUrl = "";
  this.signature = "";
  this.companyId = "";
  
  if (!params.signature) {
    console.log("Missing signature");
    return false;
  }
  this.signature = params.signature;
  
  if (!params.company_id) {
    console.log("Missing company id");
    return false;
  }
  this.companyId = params.company_id;
  
  if (!params.base_url) {
    console.log("Missing base url");
    return false;
  }
  this.baseUrl = params.base_url;
};

JSHelix.prototype.search = function(query, callback) {
  var searchUrl = this.baseUrl;
  searchUrl += "/companies/" + this.companyId;
  searchUrl += "/videos.json?signature=" + this.signature;
  searchUrl += "&query=" + query;
  
  JSHelix.ajax(searchUrl).done(function(data) {
    callback(data);
  });
}

// class function
JSHelix.ajax = function(url) {
  var deferObj = jQuery.Deferred();
  jQuery.ajax({
    url: url,
    dataType: "jsonp",
    jsonp: "jsonp_callback",
    success: function(data) {
      deferObj.resolve(data);
    }
  });
  return deferObj;
}

JSHelix.prototype.getScreenshotUrl = function(videoId) {
  return this.baseUrl + "/videos/" + videoId + "/screenshots/64w.jpg";
}

JSHelix.prototype.renderWidget = function (holderId, query, type) {
  if (typeof holderId == "undefined") return false;
  if (typeof query == "undefined") return false;
  
  var scope = this;
  
  this.search(query, function(data) {
    // manipulate the data
    data = data.videos;
    data_array = [];
    for(var i = 0; i < data.length; i++) {
      var video = data[i];
      data_array.push({
        "guid": video.video_id,
        "title": video.title,
        "thumb-src": scope.getScreenshotUrl(video.video_id),
        "comment-count": 0,
        "average-ratings": 0,
        "rating-count": 0
      });
    }
    renderWith(data_array);
  });
  
  function renderWith(data) {
    // if jQuery has not been loaded, load jquery.
    if (typeof jQuery == "undefined") {
      var script = document.createElement('script');
      script.src = 'http://ajax.googleapis.com/ajax/libs/jquery/1.8.2/jquery.min.js';
      script.type = 'text/javascript';
      script.onload = handleReadyStateChange;
      document.getElementsByTagName('head')[0].appendChild(script);
    } else {
      handleReadyStateChange();
    }

    function handleReadyStateChange() {
      // load widget css
      // only ONCE
      if (jQuery("head").find("[id*='widget-css']").length == 0) {
        jQuery("head").append("<link>");
        var css = jQuery("head").children(":last");
        css.attr({
          id: "widget-css",
          rel:  "stylesheet",
          type: "text/css",
          href: "/stylesheets/widget.css"
        });  
      }

      //data = data["videos"];

      var topCommentsDiv = jQuery("<div id='top-comments'/>");
      var widgetTitle = jQuery("<h3>" + type + "</h3>");
      topCommentsDiv.append(widgetTitle);
    
      if (data.length == 0) {
        topCommentsDiv.append("<div id='status'>No video found</div>");
      }
    
      // start loop
      for (var i = 0; i < data.length; i++) {
        var videoData = data[i];
        var title = videoData["title"];
        var stillSrc = videoData["thumb-src"];
        var commentCount = videoData["comment-count"];
        var averageRatings = videoData["average-ratings"];
        var shareCount = videoData["share-count"];

        var videoElemDiv = jQuery("<div class='video-elem well'/>");
        var videoThumbDiv = jQuery("<div class='video-thumb'/>");
        var videoThumbImg = jQuery("<a href='/videos/" + videoData["guid"] + "'><img class='media-object' src='" + stillSrc + "'/></a>");
        videoThumbDiv.append(videoThumbImg);

        var videoTitleDiv = jQuery("<a href='/videos/" + videoData["guid"] + "'><div class='video-title'>" + title + "</div></a>");
        videoElemDiv.append(videoThumbDiv)
                    .append(videoTitleDiv);

        if (type == "comments") {
          var videoCommentCountDiv = jQuery("<div class='video-comment-count'>" 
                                      + "Comments: " 
                                      + commentCount 
                                      + "</div>");
          videoElemDiv.append(videoCommentCountDiv);
        } else if (type == "ratings") {
          var videoRatingCountDiv = jQuery("<div class='video-rating-count'>" 
                                      + "Average rating: "
                                      + averageRatings 
                                      + "</div>");
          videoElemDiv.append(videoRatingCountDiv);
        } else if (type == "shares") {
          var videoShareCountDiv = jQuery("<div class='video-share-count'>" 
                                      + shareCount 
                                      + "</div>");
          videoElemDiv.append(videoShareCountDiv);
        }
        topCommentsDiv.append(videoElemDiv);
      }
      // end loop
      jQuery("#" + holderId).append(topCommentsDiv);
    }
  }
}