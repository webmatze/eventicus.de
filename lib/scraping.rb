require 'open-uri'
require 'json'

class Scraping
  
  YAHOOURL = 'http://query.yahooapis.com/v1/public/yql?'
  
  def mauclub
    mau_query = "select * from html where url=\"http://www.mauclub.de/index.php?mode=aktuell\" and xpath='//td[@id=\"content\"]/table/tr/td/span[@class=\"vorschautext\"]/a[1]'"
    
    data = Scraping.parse(mau_query)
    data["a"].each do |a|
      href = a["href"]
      if href.starts_with? 'http'
        
      end
    end
    
  end
  
  def self.parse(query, format = "json")
    url = URI.encode(YAHOOURL + "format=#{format}&q=" + query)
    raw_data = open(url).read
    case format
      when 'json' then
        data = JSON.parse(raw_data)
        data["query"]["results"]
      when 'xml' then
        doc = REXML::Document.new(raw_data)
      else
        raw_data
    end
  end
  
end