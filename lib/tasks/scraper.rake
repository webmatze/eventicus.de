namespace :scrape do
  
  desc "Scrape Events from lastfm.de"
  task :lastfm => :environment do 
    require 'nokogiri'
    require 'open-uri'
    
    location = "germany"
    url = "http://ws.audioscrobbler.com/2.0/geo/#{location}/events.rss"
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
      
          title = (eventdoc.at_css(".summary") || eventdoc.at_css(".summary a")).text
          venue = eventdoc.at_css(".org").text
          street = eventdoc.at_css(".street-address").text
          zipcode = eventdoc.at_css(".postal-code").text
          city = eventdoc.at_css(".locality").text
          country = eventdoc.at_css(".country-name").text
          phone = eventdoc.at_css(".tel").text rescue nil
          homepage = eventdoc.at_css(".url").text rescue nil
      
          description = eventdoc.at_css("#wikiAbstract").text rescue "keine Beschreibung vorhanden"
        
          user = User.find ["venti","webmatze","matze002"].rand
        
          # Event speichern
          begin
            location = Location.find :first, :conditions => { :zip => zipcode, :name => venue }
            if location.nil?
              metro = Metro.find :first, :conditions => { :name => city, :country => country }
              if metro.nil?
                metro = Metro.find_by_name city
              end
              if metro
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
                    puts "Location #{venue} erfolgreich erstellt."
                rescue
                  puts "Location #{venue} konnte nicht angelegt werden"
                end
              else
                puts "metro #{city} konnte nicht gefunden werden"
              end
            end
            if location
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
              puts "Event #{title} successful created!"
            end
          rescue Exception => e
            puts "Event #{title} konnte nicht importiert werden - #{e.message} - #{e.backtrace}"
          end
        
        rescue Exception => e
          puts "Fehler beim Scrapen von #{title} - #{guid}"
        end
      
      else
        puts "Event mit ID '#{guid}' bereits vorhanden"
      end
            
      sleep 5
      
    end
  end
  
end