require 'rubygems'
require 'hpricot'
require 'open-uri'


# This Module is an extension to official del.icio.us API.
# The main purpose her is to provide functions like 
# get popular, hot and recent links. 
#
# Author::    Thiago Bueno Silva  (mailto:tbueno@gmail.com)
# License::   Distributes under the same terms as Ruby
module Delicious
  
  #Possible types of lists
  HOT_LIST = 0
  POPULAR = 1
  RECENT = 2
  SEARCH = 3
  BASE_URL = 'http://del.icio.us'
 # HOT_LIST_QUERY = "//div[@class='hotlist']/ol/li"
	
  POPULAR_URL = BASE_URL+'/popular'
  HOT_LIST_QUERY,POPULAR_QUERY = "//ul[@id='bookmarklist']/li/div"
	
  RECENT_URL = BASE_URL+'/recent'
	
  SEARCH_URL = BASE_URL+'/search?context=all&p='
  SEARCH_QUERY = "//div/[@id='bd']/div[@id='yui-main']/div[@id='content']/ul/li/div"
	
  class Collector
    @list_type = 0
  
    #Return the links from <i>'what's hot right now on del.icio.us'</i> section.
    def hot_list
      @list_type = HOT_LIST
      get_links BASE_URL, HOT_LIST_QUERY
    end
	
    def popular(tag='')
      @list_type = POPULAR
      get_links POPULAR_URL+'/'+tag, POPULAR_QUERY
    end
	
    def recent(min=2)
      @list_type = RECENT
      get_links RECENT_URL+'?min='+min.to_s, POPULAR_QUERY
    end
	
    def search(term)
      @list_type = SEARCH
      get_links SEARCH_URL+term+"&lc=1", SEARCH_QUERY		
    end

    private
    def get_links(base_url, query)
      links = []
     		
      doc = Hpricot(open(base_url))  
      doc.search(query).each do |result|        
        text = result.search("div[@class='data']/h4/a[@href").first.inner_text       
        url =  result.search("div[@class='data']/h4/a[@href").first['href']     
      
        posted_by = get_posted_by(result)	
        people = get_people(result).to_i
        tags = get_tags(result)
        links << Delicious::Link.new( text, url, posted_by, people, tags)
  			
      end
      links		
    end
	
    def get_posted_by(result)
      name = " "
   
      if @list_type == POPULAR or @list_type == SEARCH 
        name = result.search("div[@class='meta']/span/a[@class='user").first['href'].gsub("/", "")	        
      elsif @list_type == RECENT
        name = result.search("div[@class='meta']/a[@class='user").first['href'].gsub("/", "")	
      end
      Delicious::Person.new(name)
    end
  
    def get_people(result)
      result.search("div[@class='data']/div/a/span").inner_text
    end
    
    def get_tags(result)
      tags = []
      query = result.search("div[@class='tagdisplay']/ul/li/a/span").each do |span|
          tags << span.inner_text
      end           
      tags
    end
  end
  ####### Collector Class end #############
  
  class Link

    attr_reader :text, :url, :posted_by, :people, :tags

    def initialize(text, url, posted_by, people, tags)
      @text = text
      @url = url
      @posted_by = posted_by
      @people = people
      @tags = tags		
    end

    #Comparator method. The links should be ordered by the number of people that saved them.
    def <=> (link)      
      if @people > link.people
        return 1
      elsif @people < link.people
        return -1
      end      
      0      
    end

    def equal?(link)     
      link.url == @url
    end

  end
  ####### Link Class end #############
  
  class Person
    
    attr_reader :name, :url
    
    def initialize(name)
      @name = name
      @url = BASE_URL+'/'+name
    end
  end
  ########### Person Class end ############
  
  class Tag
    attr_reader :name, :url
    
    def initialize(name)
      @name = name
      @url = POPULAR_URL +'/'+name
    end
  end
  
  
end

d = Delicious::Collector.new
links = d.hot_list
links.each do |link|
  
  puts '------------------------------------------'
  puts "Text: #{link.text}"
  puts "URL: #{link.url}"
  puts "People: #{link.people.to_s}"
  puts "Posted By: #{link.posted_by.name}"
  puts "Tags:  #{link.tags * ','}"
  
end
