namespace :scrape do

  require 'scrubyt'

  desc "scrape all events from eventicus homepage"
  task :eventicus_test => :environment do
    
    Scrubyt.logger = Scrubyt::Logger.new
    event_data = Scrubyt::Extractor.define do

      fetch 'http://localhost:3001/events'

      #alle div's finden, in denenn die Events dargestellt werden
      event_row "//div[@class='event-summary']" do
        
        title "/div[1]/h3/a"
        
        date "/div[3]" do
          day "/strong/span[1]"
          month "/strong/span[2]"
          time "/div"
        end
        
        #Den Link zum Event finden
        event_link "/div[1]/h3/a", :generalize => false do
          
          event_details do
            event_location "//div[@class='event-location']" do
              venue "/div[1]/span[1]"
              street "/div[1]/div[2]/span[1]"
              metro "/div[1]/div[2]/span[2]/a"
              state "/div[1]/div[2]/span[3]"
              zip "/div[1]/div[2]/span[4]"
              country "/div[1]/div[2]/span[5]"
            end
            event_desctiption "//div[@class='event-description']" do
              description "/div[1]"
            end
          end
          
        end
        
      end
    end

    #saving the data to mysql, requires the environment line above
    event_data_hash = event_data.to_hash
    event_data_hash.each do |item|
      puts item.inspect
    end
    
  end
  
  
  desc "scrape all events from upcoming.org homepage"
  task :upcoming => :environment do
    
    Scrubyt.logger = Scrubyt::Logger.new
    event_data = Scrubyt::Extractor.define do

      fetch 'http://upcoming.yahoo.com/search/?search_placeid=.CuNPxmbApgQChfYbQ--&rt=0'
      #fetch 'http://upcoming.yahoo.com/search/?quick_date=this_weekend&search_placeid=.CuNPxmbApgQChfYbQ--&rt=1'
      #alle li's finden, in denenn die Events dargestellt werden
      event_link "//a[@class='url summary']", :generalize => false do
        event_details do
          event "//div[@id='event']" do
            title "/h1[1]/div"
          end
          event_metadata "//div[@id='eventMetadata']" do
            datetime "/div[2]" do
              date_start "/abbr[1]/@title"
              date_end "/abbr[2]/@title"
            end
            location "/div[3]" do
              venue "/span[1]/a"
              address "/div[1]/div[1]" do
                street "/span[1]"
                metro "/span[2]"
                state "/span[3]"
                zip "/span[4]"
              end
            end
            category "/div[4]/span"
          end
          description_data "//div[@id='eventMetadata']" do
            description :type => :html_subtree
          end
        end
      end
      
    end

    #saving the data to mysql, requires the environment line above
    TzTime.zone = TZInfo::Timezone.new("Europe/Berlin")
    event_data_hash = event_data.to_hash
    puts event_data_hash.inspect
    event_data_hash.each do |item|
      
        #Event nur speichern, wenn es diesen noch nicht gibt
        event = Event.find_by_title item[:title]
        if event.nil? && item[:venue] && item[:metro] && item[:date_start]
          #Event Daten
          event = Event.new
          event.title = item[:title]
          if item[:description].match(/"description"/)
            event.description = item[:description].gsub(/>,/,'>').gsub(/<div.*"description"><\/div>/,'').gsub(/<div class="clearb.*>/,'')
          else
            event.description = "keine Beschreibung vorhanden"
          end
          event.date_start = item[:date_start].to_time
          if item[:date_end]
            event.date_end = item[:date_end].to_time
          else
            event.date_end = event.date_start + 2.hours
          end
          event.user = User.find ["venti","webmatze","frankm","demode"].rand
      
          #location Daten
          location = Location.find_by_name item[:venue] rescue nil
          if location.nil?
            location = Location.new
            location.name = item[:venue]
            location.street = item[:street] if item[:street]
            location.zip = item[:zip] || "-"

            if location.metro.nil?
              metro = Metro.find_by_name item[:metro] rescue nil
              if metro.nil?
                metro = Metro.new
                metro.name = item[:metro]
                metro.country = 'Deutschland'
                metro.state = item[:state] if item[:state]
                metro.save!
              end
              location.metro = metro
            end
          
            location.save!
          end
          event.location = location
          
          category = Category.find_by_name item[:category] rescue nil
          if category.nil?
            category = Category.find_by_name "Other"
          end
          
          event.category = category
                
          event.save!
      
        end
      
      
    end
    
  end


  desc "scrape all events from venteria.de homepage"
  task :venteria => :environment do
    
    Scrubyt.logger = Scrubyt::Logger.new
    event_data = Scrubyt::Extractor.define do

      fetch 'http://venteria.com/events'

      #alle li's finden, in denenn die Events dargestellt werden
      events "//li[@class='vevent']" do
        
        #link finden und aufrufen
        event_link "/div[2]/h2/a", :generalize => false do 
          
          event_details do
            event_title "//div[@id='event']" do
              title "/div[1]/h1"
            end
            event_date "//div[@id='date']" do
              date_start "/p/abbr[1]/@title"
              date_end "/p/abbr[2]/@title"
            end
            event_description "//div[@id='description']" do
              description(:type => :html_subtree)
            end
            event_location "//div[@id='location']" do
              location "/div", :type => :html_subtree do
                venue(/^([^<]*)/, { :type => :regexp })
                street(/^[^<]*<br[^>]*>([^<]*)/, { :type => :regexp })
                zip(/^[^<]*<br[^>]*>[^<]*<br[^>]*>([^<]*) /, { :type => :regexp })
                metro(/^[^<]*<br[^>]*>[^<]*<br[^>]*>[^<]* ([^<]*)/, { :type => :regexp })
              end
            end
          end
          
        end
        
      end
      
    end

    #saving the data to mysql, requires the environment line above
    TzTime.zone = TZInfo::Timezone.new("Europe/Berlin")
    event_data_hash = event_data.to_hash
    event_data_hash.each do |item|
      
      begin
        #Event nur speichern, wenn es diesen noch nicht gibt
        event = Event.find_by_title item[:title]
        if event.nil? && item[:venue] && item[:metro] && item[:date_start]
          #Event Daten
          event = Event.new
          event.title = item[:title]
          event.description = item[:description].gsub(/<h5>[^<]*<\/h5>/,'')
          event.date_start = item[:date_start].to_time
          if item[:date_end]
            event.date_end = item[:date_end].to_time
          else
            event.date_end = event.date_start + 2.hours
          end
          event.user = User.find ["venti","webmatze","matze002"].rand
      
          #location Daten
          location = Location.find_by_name item[:venue] rescue nil
          if location.nil?
            location = Location.new
            location.name = item[:venue]
            location.street = item[:street] if item[:street]
            location.zip = item[:zip] if item[:zip]

            if location.metro.nil?
              metro = Metro.find_by_name item[:metro] rescue nil
              if metro.nil?
                metro = Metro.new
                metro.name = item[:metro]
                metro.country = 'Deutschland'
                metro.state = item[:state] if item[:state]
                metro.save
              end
              location.metro = metro
            end
          
            location.save
            event.location = location
          end
                
          event.save
      
        end
      rescue
      end
      
      
    end
    
  end

  desc "test"
  task :test => :environment do
    
    Scrubyt.logger = Scrubyt::Logger.new
    event_data = Scrubyt::Extractor.define do

      fetch 'http://localhost:3001/scrapetests/venteria_event.htm'

      event_date "//div[@id='date']" do
        date_start "/p/abbr[1]/@title"
        date_end "/p/abbr[2]/@title"
      end
      
    end

    #saving the data to mysql, requires the environment line above
    event_data_hash = event_data.to_hash
    event_data_hash.each do |item|
      puts item.inspect
    end
    
  end
  
end