require 'rubygems'
require 'hpricot'
require 'open-uri'


# This Module is an extension to official del.icio.us API.
# The main purpose here is to provide methods like 
# get popular, hot and recent links using scraping. 

# Author::    Thiago Bueno Silva  (mailto:tbueno@tbueno.com)
# License::   Distributes under the same terms as Ruby
module Delicious
  
  #Possible types of lists
  FRESH = 0
  POPULAR = 1
  RECENT = 2
  SEARCH = 3
  BASE_URL = 'http://del.icio.us' 
	
  POPULAR_URL = BASE_URL+'/popular'
  HOT_LIST_URL = BASE_URL+'/?view=hotlist'
  RECENT_URL = BASE_URL+'/recent'
  SEARCH_URL = BASE_URL+'/search?context=all&p='
  
  FRESH_QUERY = POPULAR_QUERY = "//ul[@id='bookmarklist']/li/div"	
  SEARCH_QUERY = "//div/[@id='bd']/div[@id='yui-main']/div[@id='content']/ul/li/div"
	
  class Collector
    @list_type = 0
  
   
    def fresh
      @list_type = FRESH
      get_links BASE_URL, FRESH_QUERY
    end
    
    def hot_list
      @list_type = FRESH
      get_links HOT_LIST_URL, FRESH_QUERY
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
      (doc/query).each do |result|        
        text = (result/"div[@class='data']/h4/a[@href").first.inner_text       
        url =  (result/"div[@class='data']/h4/a[@href").first['href']
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
       name = (result/"div[@class='meta']/a/span").first.inner_text.split.last         
      elsif @list_type == RECENT
        name = (result/"div[@class='meta']/a[@class='user").first['href'].gsub("/", "")	
      end
      Delicious::Person.new(name)
    end
  
    def get_people(result)
      (result/"div[@class='data']/div/div/a/span").inner_text
    end
    
    def get_tags(result)
      tags = []
      query = (result/"div[@class='tagdisplay']/ul/li/a/span").each do |span|
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



