namespace :scrape do
  
  desc "Scrape Events from lastfm.de"
  task :lastfm => :environment do 
    require 'nokogiri'
    require 'open-uri'
    
    location = (ENV.include?("location")) ? ENV["location"] : "Hamburg"

    # last.fm key
    key = "8705f01e19cfaf87d0a3c448c474bb52"
    
    search_venue_url = "http://ws.audioscrobbler.com/2.0/?method=venue.search&api_key=#{key}&venue=#{location}"
    search_doc = Nokogiri::XML(open(search_venue_url))
    
    search_doc.xpath("//results/venuematches/venue").each do |venue|
    
      venue_id = venue.xpath(".//id").text
    
      url = "http://ws.audioscrobbler.com/2.0/venue/#{venue_id}/events.rss"
      doc = Nokogiri::HTML(open(url))
    
      doc.xpath("//rss/channel/item").each do |item|
        title = item.xpath(".//title").text
        guid = item.xpath(".//guid").text
        datestart = item.xpath(".//dtstart").text
        dateend = item.xpath(".//dtend").text
        puts "scraping '#{title}' from #{guid}"
      
        # open that URL and scrape Eventdata
        if Event.count(:conditions => { :scrapingid => guid }) == 0
      
          begin
            eventdoc = Nokogiri::HTML(open(guid))
            eventdoc.css("style,script").remove
      
            title = (eventdoc.at_css(".summary") || eventdoc.at_css(".summary a")).text
            venue = eventdoc.at_css(".org").text
            street = eventdoc.at_css(".street-address").text rescue 'nicht angegeben'
            zipcode = eventdoc.at_css(".postal-code").text rescue 'NA'
            city = eventdoc.at_css(".locality").text
            country = eventdoc.at_css(".country-name").text
            phone = eventdoc.at_css(".tel").text rescue nil
            homepage = eventdoc.at_css(".url").text rescue nil
      
            description = eventdoc.at_css("#wikiAbstract").text.strip_html.strip rescue "keine Beschreibung vorhanden"
        
            user = User.find "venti"
        
            # Event speichern
            begin
              metro = Metro.find(city)
              if metro
                location = metro.locations.find_by_name(venue)
                if location.nil?
                    begin
                      location = metro.locations.create(
                        :name => venue, 
                        :street => street, 
                        :zip => zipcode, 
                        :url => homepage, 
                        :email => nil, 
                        :description => nil, 
                        :phone => phone, 
                        :lat => nil, :lng => nil)
                        puts "Location #{venue} #{location.id} erfolgreich erstellt."
                    rescue
                      puts "Location #{venue} konnte nicht angelegt werden"
                    end
                end
                if location && location.valid?
                  #testen, ob Event schon vorhanden ist
                  event = location.events.create(
                    :scrapingid => guid,
                    :title => title, 
                    :description => description, 
                    :date_start => datestart.to_time, 
                    :date_end => dateend.to_time, 
                    :user_id => user.id, 
                    :category_id => 2
                  )
                  if event.valid?
                    puts "Event #{title} successful created!"
                  else
                    puts "Event #{title} konnte nicht gespeichert werden!"
                  end
                end
              else
                puts "metro #{city} konnte nicht gefunden werden"
              end
            rescue Exception => e
              puts "Event #{title} konnte nicht importiert werden - #{e.message} - #{e.backtrace}"
            end
        
          rescue Exception => e
            puts "Fehler beim Scrapen von #{title} - #{guid} - #{e.message} - #{e.backtrace}"
          end

          sleep 5
      
        else
          puts "Event mit ID '#{guid}' bereits vorhanden"
        end
            
      
      end

    end

  end
  
end