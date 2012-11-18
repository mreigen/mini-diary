module Video
  @service_url = ""
  @default_key = ""
  @already_read_yaml = false
  @config = {
    :view_key => "",
    :update_key => "",
    :ingest_key => ""
  }
  
  # will need to be moved to a Http class or something similar
  def self.get(url = nil)
    return if url.blank?
    uri = URI.parse(url)
    Net::HTTP.get(uri)
  end

  def self.get_base_url
    self.read_from_yaml
    @service_url
  end

  def self.get_default_key
    self.read_from_yaml
    @default_key
  end
  
  def self.read_from_yaml
    return if @already_read_yaml
    yml = File.open("#{RAILS_ROOT}/config/settings.yml") { |ym| YAML::load(ym) }
    @default_key = yml["default_key"]
    @service_url = yml["service_url"]
    @already_read_yaml = true
  end
  
  def self.get_key(type = nil, params = nil, license_key = nil)
    self.read_from_yaml
    license_key = get_default_key if license_key.nil?
    return "" if type.blank? || license_key.blank?
    
    url = "#{get_base_url}/api/"
    
    if type == "view"
      url += "view_key"
    elsif type == "update"
      url += "update_key"
    elsif type == "ingest"
      url += "ingest_key"
    end
    
    url += "?licenseKey="
    url += license_key
    url += "&duration=1440"
    
    unless params.blank?
      params.each do |k, v|
        url += "&#{k}=#{v}"
      end
    end
    
    get url
  end
  
  def self.get_top(for_field, query = {})
    for_contributor = query[:contributor]
    for_contributor ||= ""
    limit = query[:limit]
    limit ||= 5
    search_query = query[:search_query]
    search_query ||= ""
    
    videos = JSON.parse(self.search({ 
                                      :contributor => for_contributor,
                                      :query => search_query,
                                      :status => "complete"
                                    }))
    #videos = videos["videos"]
    
    video_list = []
    
    videos.each do |v|
      v = v["attributes"]
      comment_count = 0
      rating_count = 0
      ratings = 0.0
      video_id = v["video_id"]
      next if video_id.blank?
      comment_data = self.get_comments(video_id)
      next if comment_data.blank?
      JSON.parse(comment_data).each do |c|
        comment_count += 1 unless c["text"].blank?
        unless c["rating"].blank?
          rating_count +=1
          ratings += c["rating"]
        end
      end
      ratings /= rating_count unless rating_count == 0
      
      video_list.push({
        "guid" => video_id, 
        "title" => v["title"],
        "thumb-src" => self.get_screenshot(video_id),
        "comment-count" => comment_count, 
        "average-ratings" => ratings, 
        "rating-count" => rating_count, 
        #"share-count" => share_count
      })
    end
    
    case for_field
    when "comments"
      video_list.sort_by! { |h| h["comment-count"] }
    when "ratings"
      video_list.sort_by! { |h| h["average-ratings"] }
    end
    
    video_list.last(limit).reverse
  end
  
  def self.get_metadata(video_id)
    video = Helix::Video.find(video_id)
    video.attributes.to_json.html_safe
  end
  
  def self.search(query = {})
    videos = Helix::Video.find_all(query).to_json.html_safe
  end
  
  # temporary work around since requesting this url from javascript doesn't work properly
  # after getting the json feed from the url, pass it back to the javascript in the view as a raw json string
  def self.get_comments(video_id)
    video = Helix::Video.find(video_id)
    video.comments.to_json.html_safe
  end
  
  def self.get_screenshots(video_id)
    video = Helix::Video.find(video_id)
    video.screenshots.to_json.html_safe
  end
  
  def self.get_screenshot(video_id)
    "#{get_base_url}/videos/#{video_id.to_s}/screenshots/64w.jpg"
  end
  
  def self.post_comment(video_id, data)
    return if data[:time_code].blank? || data[:contributor].blank? || (data[:text].blank? && data[:rating].blank?)
    signature = get_key("update")
    
    url = "#{get_base_url}/videos/#{video_id.to_s}/comments.json"
    url += "?signature=#{signature}"
    
    uri = URI.parse(url)
    
    req = Net::HTTP::Post.new(uri.request_uri)
    params = {"comment[text]" => data[:text], "comment[rating]" => data[:rating], 'comment[time_code]' => data[:time_code], 'comment[contributor]' => data[:contributor]}
    req.set_form_data(params)

    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end
    
    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        true
      else
        false
      end
  end
  
  def self.create_share(video_id, data)
    signature = get_key("update")
    
    url = "#{get_base_url}/videos/#{video_id.to_s}/shares"
    url += "?signature=#{signature}"
    
    uri = URI.parse(url)
    
    req = Net::HTTP::Post.new(uri.request_uri)
    params = {"share[url]" => data[:url]}
    params.merge!({"share[duration]" => data[:duration]}) unless data[:duration].blank?
    params.merge!({"share[time_code]" => data[:time_code]}) unless data[:time_code].blank?
    req.set_form_data(params)

    res = Net::HTTP.start(uri.host, uri.port) do |http|
      http.request(req)
    end
    
    case res
      when Net::HTTPSuccess, Net::HTTPRedirection
        res.body
      else
        false
      end
  end
  
  module Widget
    def self.top(holder_id, type, contributor = "", limit = 5)
      comment_data = Video::get_top(type, 
                            {
                              :contributor => contributor, 
                              :limit => limit
                            })
      self.render(holder_id, type, comment_data).html_safe
    end
    
    def self.list(holder_id, query = {})
      contributor = query[:contributor]
      contributor ||= ""
      title = query[:title]
      title ||= ""
      search_query = query[:search_query]
      search_query ||= ""
      
      data = Video::get_top(title, 
                            {
                              :contributor => contributor, 
                              :limit => 99,
                              :search_query => search_query
                            })
      self.render(holder_id, title, data).html_safe
    end
    
    def self.render(holder_id, type, comment_data)
      html =<<EOF
      <script type="text/javascript">

        renderWidget('#{holder_id}', #{comment_data.to_json}, '#{type}');

        function renderWidget(holderId, data, type) {
          if (!holderId) return false;
          if (!data) return false;

          //availableTypes = "comments ratings shares";
          //if (availableTypes.indexOf(type) == -1) return false;

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
      </script>
EOF
      html.html_safe
    end
  end
  
end